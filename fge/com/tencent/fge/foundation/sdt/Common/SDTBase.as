package com.tencent.fge.foundation.sdt.Common
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class SDTBase
	{
		private var m_data:SDData = null;
		private var m_dataChk:SDData = null;
		private var m_listener:SDListenerInterface = null;
		private var m_safeTimer:Timer;
				
		public function SDTBase(check:Boolean = false, security:uint = 0, 
			listener:SDListenerInterface = null)
		{
			if(check)
			{
				m_dataChk = new SDData;
			}
			
        	if(security > 0)
        	{
        		var tmp:int = 60000 / security;
        		tmp = tmp < 200 ? 200 : tmp;
        		m_safeTimer = new Timer(tmp);
        		m_safeTimer.addEventListener(TimerEvent.TIMER, onSafeTimer);
        		m_safeTimer.start();
        	}			
		}
		
        protected function onSafeTimer(e:Event):void
        {
        	if(m_data)
        	{
        		if(!m_data.refresh())
        		{
        			warn("数据刷新错误!")
        		}	
        	}
        }
		
		public function dispose(): void
		{
			if (m_data)
			{
				m_data.dispose();
				m_data = null;
			}
			
			if(m_dataChk)
			{
				m_dataChk.dispose();
				m_dataChk = null;
			}
		}
        
        protected function setValue(data: Object):void
        {
			if (m_data)
			{
				m_data.dispose();
			}
			
        	m_data = SDData.createByBytes(data, m_listener);
			
        	if(m_dataChk)
        	{
				m_dataChk.dispose();
        		m_dataChk = SDData.createByBytes(data, null);
        	}        	
        }
        
        protected function getValue(): Object
        {
            var bytes: Object;
            if(m_data)
            {
            	bytes = m_data.readStringBytes();
            }
			
            if(m_dataChk)
            {
				var bytesChk: Object = m_dataChk.readStringBytes();
            	if(!SDCore.compareBytes(bytes, bytesChk))
            	{
					SDCore.freeBytes(bytesChk);
            		error("数据较验错误!");
					return null;
            	}
				SDCore.freeBytes(bytesChk);
            }
            return bytes;        	
        }
        
        public function serialize():String
        {
            return m_data.serialize();
        }
        
        public function deserialize(s:String):void
        {
        	m_data = SDData.createBySerialize(s, m_listener);
        }        
        
        private function error(text:String):void
        {
        	if(m_listener)
        	{
        		m_listener.onError(text);
        	}
        }
        
        private function warn(text:String):void
        {
        	if(m_listener)
        	{
        		m_listener.onWarn(text);
        	}
        }
        
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	  
	}
}