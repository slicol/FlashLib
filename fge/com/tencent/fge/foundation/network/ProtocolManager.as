/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   ProtocolManager.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-4
#   Comment     :   一个基于AS的通用网络层和协议框架的实现。
 * 					它内置了一个基于Socket的连接器，已经足够一般的AS项目使用
 * 					它还支持外定义网络连接器，可以实现基于Http的连接器。
 * 					它提供一个几乎可以通用的协议框架。支持外定义协议头。
 * 					该框架支持在一个应用，创建多个协议管理器。每一个协议管理器都可以对应
 * 					自己的协议头。
 * 					它支持传统的1对多的协议处理模式，也支持1对1的协议处理模式。
 * 					1对多，是指一条协议可以由一个逻辑发出，其回包可以由多个逻辑接收和处理。
 * 					1对1，是指一条协议由一个逻辑发出后，其回包只会被这个逻辑接收和处理。	
 * 
 * 					这里是协议框架的实现。
 * 				
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-4 文件创建 
#
*************************************************************************/


package com.tencent.fge.foundation.network
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.utils.ByteArrayUtil;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	[Event(name="ptlNotReg", type="com.tencent.fge.foundation.network.ProtocolEvent")]
	
	public class ProtocolManager extends EventDispatcher implements IProtocolSender
	{
		public static var LOG_PROTOCOL:Boolean = true;
		public static var LOG_SOCKETDATA:Boolean = true;
		
		private static var ms_lstManager:Dictionary = new Dictionary;
		
		//用于实现1对多的协议收发功能 
		private var m_lstProtocolHelper:Dictionary = new Dictionary;
		
		//用于实现1对1的协议收发功能
		private var m_lstProtocolIndex:Dictionary = new Dictionary;
		
		private var m_conn:IConnector;
		private var m_buff:ByteArray;
		private var m_head:IProtocolHead;
		private static var m_index:uint;
		private var m_name:String = "";
				
		private var log:Log = new Log(this);
		
		public function ProtocolManager(name:String)
		{
			super();
			m_name = name;
		}
		
		public static function initialize():Boolean
		{
			return true;
		}
		
		public static function finalize():void
		{
		}
		
				
		public static function getProtocolManager(
			name:String, type:String="default"):ProtocolManager
		{
			var pm:ProtocolManager = ms_lstManager[name];
			if(pm == null)
			{
				pm = new ProtocolManager(name);
				ms_lstManager[name] = pm;
			}
			return pm;		
		}
		
				
		public function initialize(head:IProtocolHead):Boolean
		{
			log.attachClassName("ProtocolManager("+m_name+")");
			log.debug("initialize");
			m_head = head;
			m_buff = new ByteArray();
			return true;
		}
		
		public function finalize():void
		{
			log.debug("finalize");
			
			if(m_conn != null)
			{
				m_conn.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
				m_conn = null;
			}
			
			m_buff = null;
			m_head = null;
		}
		
		public function setConnector(conn:IConnector):void
		{
			log.debug("setConnector", conn);
			
			if(m_conn != null)
			{
				m_conn.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
				m_conn = null;
			}
			
			m_conn = conn;
			
			if(m_conn != null)
			{
				m_conn.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			}
		}

		public function regProtocol(ptlClass:Class, listener:Function = null):void
		{
			var protocol:BaseProtocol = new ptlClass;
			var pid:uint = protocol.pid;
			var hlp:ProtocolHelper = getProtocolHelper(pid);
			hlp.attachProtocol(protocol);
			log.debug("regProtocol", protocol.toProtocolString());
			
			if(listener != null)
			{
				addProtocolListener(pid, listener);
			}
		}

		public function addProtocolListener(pid:uint, listener:Function):void
		{
			log.debug("addProtocolListener", pid.toString() + "(0x"+pid.toString(16)+")", getQualifiedClassName(listener));
			var hlp:ProtocolHelper = getProtocolHelper(pid);
			hlp.addProtocolListener(listener);
		}
		
		public function removeProtocolListener(pid:uint, listener:Function):void
		{
			log.debug("removeProtocolListener", pid.toString() + "(0x"+pid.toString(16)+")", listener);
			var hlp:ProtocolHelper = m_lstProtocolHelper[pid];
			if(hlp != null)
			{
				hlp.removeProtocolListener(listener);
			}
		}
		
		
		//----------------------------------------------------


		protected function onSocketData(e:ProgressEvent):void
		{
			if(LOG_PROTOCOL)
			{
				log.trace("onSocketData", "Enter ============================================");
			}
			
			if(LOG_SOCKETDATA)
			{
				log.trace("onSocketData", "当前收到数据长度:", e.bytesLoaded, m_conn.bytesAvailable);
				log.trace("onSocketData", "当前BUFF数据长度(1)：" + m_buff.length);
				
				m_buff.position = m_buff.length;
				m_conn.readData(m_buff, m_buff.length);
				
				log.trace("onSocketData", "当前BUFF数据长度(2)：" + m_buff.length);
			}
			else
			{
				m_buff.position = m_buff.length;
				m_conn.readData(m_buff, m_buff.length);
			}
			

			var tryCnt:int = 0;
			
			while(1)
			{
				if(LOG_SOCKETDATA)
				{
					log.trace("onSocketData", "--------------------------------------------");
				}
				
				var pkg:ProtocolPackage = tryReadPackage(tryCnt++);
				if(pkg != null)
				{										
					var pid:uint = pkg.head.pid;
					var idx:uint = pkg.head.index;
					
					
					
					//这里原本是实现了一个1对1的协议发收功能的。
					//现在因为要做防重放外挂对抗，需要用到Index，所以关闭这个功能。
					//var protocol:BaseProtocol = this.m_lstProtocolIndex[idx];
					var protocol:BaseProtocol = null;
					
					if(protocol != null)
					{
						if(protocol.pid == pid)
						{
							if(LOG_SOCKETDATA)//输出字节日志
							{
								log.trace("onSocketData", protocol.toProtocolString(),
									"包体字节:" + ByteArrayUtil.toString(pkg.data));
							}
							
							if(LOG_PROTOCOL) 
							{
								log.trace("onSocketData", 
									"该包被指定对象处理：" + protocol.toString());
							}
							
							protocol.clearTimeout();
							
							pkg.data = m_head.decrypt(pkg.data, protocol.dec, pid);//解密

							if(pkg.data == null)
							{
								log.error("onSocketData",
									"该包无法被解密：" + protocol.toString());
							}
							else
							{
								protocol.dispatchProtocol(pkg.head, pkg.data);
								
								if(pkg.data.bytesAvailable > 0)
								{
									log.error("onSocketData", 
										"该包还有多余的字节未被读取：" + pkg.data.bytesAvailable);
								}								
							}
							
							protocol.cleanup();
							delete m_lstProtocolIndex[idx];
							continue;
							//return;
						}
					}
					//以上实现1对1的协议收发功能
							
					
					var hlp:ProtocolHelper = getProtocolHelper(pid);
					
					if(LOG_SOCKETDATA)//输出字节日志
					{
						log.trace("onSocketData", "包体字节：" + hlp.toProtocolString(),
							ByteArrayUtil.toString(pkg.data));
					}
					
					if(LOG_PROTOCOL) 
					{
						log.trace("onSocketData", 
							"该包被统一处理：" + hlp.toString());
					}
					

					pkg.data = m_head.decrypt(pkg.data, hlp.dec, pid);//解密
					
					//解密失败，则弃包
					if(pkg.data == null)
					{
						log.error("onSocketData",
							"该包无法被解密：" + hlp.toString());
					}
					else
					{
						hlp.dispatchProtocol(pkg);
						
						if(pkg.data.bytesAvailable > 0)
						{
							log.error("onSocketData", 
								"该包还有多余的字节未被读取：" + pkg.data.bytesAvailable);
						}								
					}
				}
				else
				{
					
					if(LOG_SOCKETDATA)//输出字节日志
					{
						m_buff.position = 0;
						log.error("onSocketData", "BUFF字节：\n" + 	ByteArrayUtil.toString(m_buff));
					}
					
					break;
				}
			}
			

			if(LOG_PROTOCOL)
			{
				log.trace("onSocketData", "Leave ============================================");
			}
		}
		
		public function sendProtocol(pid:uint, data:ByteArray, protocol:BaseProtocol = null):uint
		{	
			var ret:Boolean = false;
			var hlp:ProtocolHelper;
			hlp = this.getProtocolHelper(pid);
			
			//这个Index大有用处，
			//一方面可以实现1对1的协议收发，
			//一方面可以用于服务器防重发外挂。
			m_index ++;
			if(m_index > 0xffffffff) m_index = 1;
			

			//组包
			var bytes:ByteArray = new ByteArray;

			data = m_head.encrypt(data, hlp.dec, pid);//加密
			
			m_head.readBytes(bytes, m_index, pid, data);
			
			//发送
			if(m_conn != null)
			{
				ret = m_conn.sendData(bytes);
			}
			else
			{
				ret = false;
				log.error("sendProtocol", "Connector = NULL");
			}
			
			
			if(protocol != null)
			{
				throw new ArgumentError("ProtocolManager 暂时关闭了1对1的协议收发功能！");
				
				//这里是为了实现1对1的协议收发功能
				if(LOG_PROTOCOL) 
				{
					log.trace("sendProtocol", 
						"ret:" + ret.toString(),
						"index:" + m_index,
						"dataSize:" + data.length, 
						protocol.toString());
				}
				
				
				this.m_lstProtocolIndex[m_index] = protocol;
				
				
				if(ret)
				{
					protocol.startTimeout();
				}
				else
				{
					protocol.startErrorTimeout(ProtocolError.SEND_ERROR);
					log.error("sendProtocol", "发送协议失败！");
				}
			}
			else
			{
				//这里是实现1对多的协议收发功能
				if(LOG_PROTOCOL) 
				{
					log.trace("sendProtocol", 
						"ret:" + ret.toString(),
						"index:" + m_index,
						"dataSize:" + data.length, 
						hlp.toString());
				}
				
				if(ret)
				{
					hlp.startTimeout();
				}
				else
				{
					hlp.startErrorTimeout(ProtocolError.SEND_ERROR);
					log.error("sendProtocol", "发送协议失败！");
				}
			}
			
			return ret ? m_index : 0;
		}
		
		
		
		//----------------------------------------------------
		
		private function getProtocolHelper(pid:uint):ProtocolHelper
		{
			var hlp:ProtocolHelper = m_lstProtocolHelper[pid];
			if(hlp == null)
			{
				hlp = new ProtocolHelper(pid, this, log);
				m_lstProtocolHelper[pid] = hlp;
			}
			return hlp;
		}
		
		private function tryReadPackage(cnt:int):ProtocolPackage
		{
			var pkg:ProtocolPackage = null;
			
			m_buff.position = 0;
			if(m_buff.bytesAvailable >= m_head.headsize)
			{
				var tmphead:IProtocolHead = m_head.copy(m_buff);
				if(tmphead != null)
				{
					if(m_buff.bytesAvailable >= tmphead.datasize)
					{
						pkg = new ProtocolPackage;
						pkg.head = tmphead;
						pkg.data = new ByteArray;
						
						if(tmphead.datasize > 0)
						{
							m_buff.readBytes(pkg.data,0,tmphead.datasize);
						}
						
						//移位
						var newbuff:ByteArray = new ByteArray;
						m_buff.readBytes(newbuff);
						m_buff = newbuff;
					}
					else
					{
						log.error("tryReadPackage", "包体的长度不够：", m_buff.bytesAvailable, tmphead.datasize);
					}
				}
				else
				{
					//这里可能要报错！也就是出现了，队列前面的数据不是包头。
					log.error("tryReadPackage", "队列前面的数据不是包头");
				}
			}
			else
			{
				if(cnt == 0)
				{
					log.error("tryReadPackage", "包头的长度不够：", m_buff.bytesAvailable, m_head.headsize);
				}
			}
			
			return pkg;
		}
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";			
		
	}
}
