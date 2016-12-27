package com.tencent.fge.foundation.network
{
	import com.tencent.fge.foundation.log.client.ILog;
	
	internal final class ProtocolHelper
	{
		private var m_pid:uint;
		private var m_protocol:BaseProtocol;
		private var m_sender:IProtocolSender;
		
		private var m_lstWait:Array = new Array;
		private var log:ILog;
		
		public function ProtocolHelper(pid:uint, sender:IProtocolSender, log:ILog)
		{
			m_pid = pid;
			m_sender = sender;
			this.log = log;
		}
		
		internal function attachProtocol(ptl:BaseProtocol):Boolean
		{
			if(m_protocol != null) return false;
			if(ptl == null) return false;
			
			m_protocol = ptl;
			m_protocol.attachProtocolSender(m_sender);
			
			for(var i:int = 0; i < m_lstWait.length; ++i)
			{
				var listener:Function = m_lstWait[i];
				addProtocolListener(listener);
			}
			m_lstWait = new Array;
			return true;
		}
		
		internal function get protocol():BaseProtocol{return m_protocol;}
		
		internal function get dec():int
		{
			if(m_protocol)
			{
				return m_protocol.dec;
			}
			else
			{
				log.error("dec", 
					"无法加解密一条未注册的协议:" + m_pid.toString() + "(0x"+m_pid.toString(16)+")");
				var ePtl:ProtocolEvent = new ProtocolEvent(ProtocolEvent.PTL_NOT_REG);
				return -1;
			}
		}
		
		internal function addProtocolListener(listener:Function):void
		{
			if(m_protocol == null)
			{
				for(var i:int = 0; i < m_lstWait.length; ++i)
				{
					if(m_lstWait[i] == listener)
					{
						return;
					}
				}
				
				m_lstWait.push(listener);
			}
			else
			{
				m_protocol.addEventListener(ProtocolEvent.PTL_TIMEOUT, listener);
				m_protocol.addEventListener(ProtocolEvent.PTL_SINK, listener);
				m_protocol.addEventListener(ProtocolEvent.PTL_ERROR, listener);
				//this.addEventListener(ProtocolEvent.PTL_NOT_REG, listener);
			}
		}
		
		internal function removeProtocolListener(listener:Function):void
		{
			if(m_protocol == null)
			{
				for(var i:int = 0; i < m_lstWait.length; ++i)
				{
					if(m_lstWait[i] == listener)
					{
						m_lstWait.splice(i,1);
						break;
					}
				}
			}
			else
			{
				m_protocol.removeEventListener(ProtocolEvent.PTL_TIMEOUT, listener);
				m_protocol.removeEventListener(ProtocolEvent.PTL_SINK, listener);
				//this.removeEventListener(ProtocolEvent.PTL_NOT_REG, listener);
			}
		}
		
		internal function dispatchProtocol(pkg:ProtocolPackage):void
		{
			if(m_protocol == null)
			{
				log.error("dispatchProtocol", 
					"发现一条未注册的协议:" + m_pid.toString() + "(0x"+m_pid.toString(16)+")");
				var ePtl:ProtocolEvent = new ProtocolEvent(ProtocolEvent.PTL_NOT_REG);
				ePtl.protocolId = m_pid;
				m_sender.dispatchEvent(ePtl);
			}
			else
			{
				m_protocol.clearTimeout();
				m_protocol.dispatchProtocol(pkg.head, pkg.data);
				m_protocol.cleanup();
			}
		}
		
		internal function startTimeout():void
		{
			if(m_protocol) m_protocol.startTimeout();
		}
		
		internal function clearTimeout():void
		{
			if(m_protocol) m_protocol.clearTimeout();
		}
		
		internal function startErrorTimeout(errCode:uint):void
		{
			if(m_protocol) m_protocol.startErrorTimeout(errCode);
		}
		
		internal function toString():String
		{
			if(m_protocol == null)
			{
				return "ProtocolHelper(" + 
					"id:"+m_pid.toString()+"(0x"+m_pid.toString(16)+"))";
			}
			else
			{
				return m_protocol.toString();
			}
		}
		
		internal function toProtocolString():String
		{
			if(m_protocol == null)
			{
				return "ProtocolHelper(" + 
					"id:"+m_pid.toString()+"(0x"+m_pid.toString(16)+"))";
			}
			else
			{
				return m_protocol.toProtocolString();
			}
		}
	}
}

