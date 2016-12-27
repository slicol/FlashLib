/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   TcpConnector.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-4
#   Comment     :   这里是内置的，基于Socket的Tcp连接器的现实。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-4 文件创建 
#
*************************************************************************/


package com.tencent.fge.foundation.network
{
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class TcpConnector extends Socket implements IConnector
	{			
		private var m_host:String = "";
		private var m_port:int = 0;
		private var m_connecting:Boolean = false;
		private var m_asyTimer:Timer = new Timer(100,1);
		
		private var log:Log = new Log("TcpConnector");
		
		public function TcpConnector(target:IEventDispatcher=null)
		{
			super();
		}
		
		public function initialize():Boolean
		{

			return true;
		}
		
		public function finalize():void
		{

		}
		
		public function sendData(bytes:ByteArray):Boolean
		{
			if(this.connected)
			{
				super.writeBytes(bytes);
				super.flush();
				return true;
			}
			return false;
		}
		
		public function readData(data:ByteArray, offset:uint):uint
		{
			var size:uint = this.bytesAvailable;
			this.readBytes(data, offset);
			return size;
		}
		
		override public function flush():void
		{
			throw Error("不要再去调用flush了！");
			return;
		}
		
		public function setTimeout(timeout:int):void
		{
		}
		
		override public function connect(host:String, port:int):void
		{
			if(super.connected)
			{
				m_connecting = false;
				if(!m_asyTimer.running)
				{
					m_asyTimer.addEventListener(TimerEvent.TIMER, onAsyTimer);
					m_asyTimer.start();
				}
			}
			else
			{
				m_host = new String(host);
				m_port = port;
				this.addSockeEventListener();
				super.connect(host, port);				
			}
		}
		
		override public function close():void
		{
			m_asyTimer.removeEventListener(TimerEvent.TIMER, onAsyTimer);
			m_asyTimer.reset();
			this.removeSockeEventListener();
			try
			{
				super.close();
			}
			catch(e:Error)
			{
				
			}
		}
		
		public function get host():String{return m_host;}
		public function get port():int{return m_port;}
		
		
		//-------------------------------------------------------
		private function addSockeEventListener():void
		{
			this.addEventListener(Event.CLOSE, onClose);
			this.addEventListener(Event.CONNECT, onConnect);
			this.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			//this.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			
		}
		
		private function removeSockeEventListener():void
		{
			this.removeEventListener(Event.CLOSE, onClose);
			this.removeEventListener(Event.CONNECT, onConnect);
			this.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
			//this.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			this.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		}
		
		private function onSecurityError(e:SecurityErrorEvent):void
		{
			//若对 Socket.connect() 的调用尝试连接到调用方安全沙箱外部的服务器或端口号低于 1024 端口，则进行调度。 
			//SecurityErrorEvent.SECURITY_ERROR 常量定义 securityError 事件对象的 type 属性值。
			log.error("onSecurityError:" + e); 
		}
		
		private function onIoError(e:IOErrorEvent):void
		{
			//在出现输入/输出错误并导致发送或加载操作失败时调度。 
			//定义 ioError 事件对象的 type 属性值。 
			log.error("onIoError:" + e); 
		}
		
		private function onConnect(e:Event):void
		{
			log.debug("onConnect:" + e); 
		}
		
		private function onClose(e:Event):void
		{
			log.warn("onClose:" + e); 
		}
		

		
		
		private function onAsyTimer(e:Event):void
		{
			log.trace("onAsyTimer:" + e);
			m_asyTimer.removeEventListener(TimerEvent.TIMER, onAsyTimer);
			m_asyTimer.reset();
			this.dispatchEvent(new Event(Event.CONNECT));
		}
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";			
	}
}








