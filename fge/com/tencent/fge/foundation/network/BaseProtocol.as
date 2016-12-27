/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   BaseProtocol.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-4
#   Comment     :   这里适用于该协议框架的协议基类。
 * 					所有具体协议，都需要继承该基类。
 * 				
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-4 文件创建 
#
*************************************************************************/

package com.tencent.fge.foundation.network
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;

	public class BaseProtocol extends EventDispatcher
	{
		public static const DEC_DEFAULT:int = 1;
		public static var LOG_FULLNAME:Boolean = false;
		
		protected var m_index:uint = 0;
		private var m_pid:uint = 0;
		private var m_timeout:Timer;
		private var m_errorTimeout:Timer;
		private var m_listener:Function = null;
		private var m_lastErrorCode:uint;
		private var m_classFullName:String;
		private var m_className:String;
		private var m_toProtocolString:String;
		private var m_dec:int = 0;

		public function BaseProtocol(pid:uint = 0, timeout:uint = 60, 
			errorTimeout:uint = 1, listener:Function = null, dec:int = DEC_DEFAULT)
		{
			super();
			m_dec = dec;
			
			m_classFullName = getQualifiedClassName(this);					
			if (m_classFullName == "com.tencent.fge.foundation.network::BaseProtocol") 
			{
				throw new ArgumentError("BaseProtocol can't be instantiated directly");
			}
			
			m_pid = pid;
			
			if(timeout > 0)
			{
				m_timeout = new Timer(timeout * 1000, 1);
				m_timeout.addEventListener(TimerEvent.TIMER, onTimeoutEvent);
			}
			
			if(errorTimeout > 0)
			{
				m_errorTimeout = new Timer(errorTimeout * 1000, 1);
				m_errorTimeout.addEventListener(TimerEvent.TIMER, onErrTimeoutEvent);
			}
			
			
			//原本实现1对1的协议收发，现在因要防重发，去除该功能。
			//m_listener = listener;
			
			if(listener != null)
			{
				throw new ArgumentError("BaseProtocol 暂时关闭了1对1的协议收发功能！");
			}
			
			if(m_listener != null)
			{
				this.addEventListener(ProtocolEvent.PTL_TIMEOUT, m_listener);
				this.addEventListener(ProtocolEvent.PTL_SINK, m_listener);
			}
		}
		
		internal function cleanup():void
		{
			if(m_listener != null)
			{
				this.removeEventListener(ProtocolEvent.PTL_TIMEOUT, m_listener);
				this.removeEventListener(ProtocolEvent.PTL_SINK, m_listener);
				m_listener = null;
			}
			this.clearTimeout();
			m_timeout = null;
			m_errorTimeout = null;
			m_lastErrorCode = 0;
		}
		
		public function get pid():uint{return m_pid;}
		public function get index():uint{return m_index;}
		public function get dec():int{return m_dec;}
		
		final internal function dispatchProtocol(head:IProtocolHead, bytes:ByteArray):void
		{
			var o:Object = decode(bytes);
			var ePtl:ProtocolEvent = new ProtocolEvent(ProtocolEvent.PTL_SINK);
			ePtl.protocolId = pid;
			ePtl.protocolData = o;
			ePtl.protocolIndex = head.index;
			this.dispatchEvent(ePtl);
		}
		
		final internal function attachProtocolSender(sender:IProtocolSender):void
		{
			bindProtocolSender(sender);
		}
		
		final internal function startErrorTimeout(errCode:uint):void
		{
			m_lastErrorCode = errCode;
			if(m_errorTimeout)
			{
				m_errorTimeout.reset();
				m_errorTimeout.start();
			}
		}
		
		final internal function startTimeout():void
		{
			if(m_timeout)
			{
				m_timeout.reset();
				m_timeout.start();
			}
		}
		
		final internal function clearTimeout():void
		{
			if(m_timeout)
			{
				m_timeout.reset();
				m_timeout.stop();
			}
			if(m_errorTimeout)
			{
				m_errorTimeout.reset();
				m_errorTimeout.stop();
			}
		}
		
		protected function bindProtocolSender(sender:IProtocolSender):void
		{
			throw Error("bindProtocolSender:必须由子类重写！");
		}
		
		protected function getSender():IProtocolSender
		{
			throw Error("getSender:必须由子类重写！");
			return null;
		}
		
		public function decode(bytes:ByteArray):Object
		{
			throw Error("decode:必须由子类重写！");
			return null;
		}
		
		public function encode(o:Object):ByteArray
		{
			throw Error("encode:必须由子类重写！");
			return null;
		}

		
		final public function send():uint
		{
			return sendData(this);
		}

		final protected  function sendData(data:Object):uint
		{
			var sender:IProtocolSender = this.getSender();
			var bytes:ByteArray;
			var ret:uint = 0;
			
			if(sender != null)
			{
				bytes = encode(data);
				if(bytes != null)
				{
					if(m_listener != null)
					{
						ret = sender.sendProtocol(pid, bytes, this);
					}
					else
					{
						ret = sender.sendProtocol(pid, bytes);
					}
				}
			}
			
			m_index = ret;
			
			return ret;
		}
		
		
		final private function onTimeoutEvent(e:Event):void
		{
			clearTimeout();
			
			var ePtl:ProtocolEvent = new ProtocolEvent(ProtocolEvent.PTL_TIMEOUT);
			ePtl.protocolId = pid;
			ePtl.protocolIndex = m_index;
			this.dispatchEvent(ePtl);
		
		}	
		
		final private function onErrTimeoutEvent(e:Event):void
		{
			clearTimeout();
			
			var ePtl:ProtocolEvent = new ProtocolEvent(ProtocolEvent.PTL_ERROR);
			ePtl.protocolId = pid;
			ePtl.protocolIndex = m_index;
			ePtl.protocolLastErrCode = m_lastErrorCode;
			this.dispatchEvent(ePtl);
		}
		
		public function get name():String
		{
			if(m_className != null) return m_className;
			
			var i:int = m_classFullName.lastIndexOf("::");
			m_className = m_classFullName.substring(i+2);
			return this.m_className;
		}
		
		public function toProtocolString():String
		{
			if(m_toProtocolString != null) return m_toProtocolString;
			
			if(LOG_FULLNAME)
			{
				m_toProtocolString = 
					"【" + m_classFullName + "["+pid.toString()+"(0x"+pid.toString(16)+")]】";
			}
			else
			{
				m_toProtocolString = 
					"【" + name + "["+pid.toString()+"(0x"+pid.toString(16)+")]】";
			}
				
			return m_toProtocolString;
		}
		
		public function toProtocolContent():String
		{
			return "";
		}
		
		override public function toString():String
		{
			return toProtocolString() + "【index:"+index.toString()+"】";
		}
		
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";			
	}
}