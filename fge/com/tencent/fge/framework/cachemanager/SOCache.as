package com.tencent.fge.framework.cachemanager
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.cachemanager.data.CacheData;
	import com.tencent.fge.framework.cachemanager.events.CacheEvent;
	import com.tencent.fge.framework.cachemanager.interfaces.ICache;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	[Event(name="prePending", type="com.tencent.fge.framework.cachemanager.events.CacheEvent")]
	[Event(name="cacheError", type="com.tencent.fge.framework.cachemanager.events.CacheEvent")]
	public class SOCache extends EventDispatcher implements ICache
	{
		public static var ms_enabled:Boolean = false;
		
		private var m_flushTimer:Timer;
		private var m_dataChanged:Boolean;
		private var m_domain:String;
		private var m_sharedObject:SharedObject;
		private var m_resList:Object;
		private var m_sharedObjectName:String;

		public function SOCache(name:String="TNT", domain:String=null, target:IEventDispatcher=null)
		{
			super(target);
			m_domain=domain;
			m_sharedObjectName=name;

		}

		public function finalize():void
		{
			if(m_flushTimer)
			{
			m_flushTimer.removeEventListener(TimerEvent.TIMER, onFlush);
			}
		}

		public function initialize():void
		{
			requestResList();
			this.enabled = SOCache.ms_enabled;
		}

		private function requestResList():void
		{
			m_sharedObject=SharedObject.getLocal(m_sharedObjectName, m_domain);
			if (m_sharedObject.data.resList != undefined)
			{
				m_resList = m_sharedObject.data.resList;
				enabled = true;
			}
			else
			{
				m_resList = new Dictionary;
				m_sharedObject.data.resList = m_resList;
			}
		}

		public function write(id:String, ver:int, data:*):Boolean
		{
			if (m_resList == null)
			{
				Log.error("SOCache.write", "Warning user shareObject is no allow to save");
				return false;
			}

			m_resList[id]=ver;
			m_sharedObject.data[id]= data;
			m_dataChanged=true;
			return true;
		}

		public function read(id:String):CacheData
		{
			var cacheData:CacheData;
			
			if (m_resList == null)
			{
				Log.error("SOCache.read", "Warning user shareObject is no allow to save");
				return null;
			}

			if (m_resList[id] != undefined)
			{
				cacheData=new CacheData();
				cacheData.id = id;
				cacheData.ver = m_resList[id];
				cacheData.data = m_sharedObject.data[id];
			}

			return cacheData;
		}

		public function remove(id:String):void
		{
			if (m_resList == null)
			{
				Log.warn("SOCache.write", "Warning user shareObject have no allow to save");
				return;
			}

			delete m_resList[id];
			delete m_sharedObject.data[id];
		}
		
		public function set enabled(value:Boolean):void
		{
			if(value)
			{
				startFlushTimer();
			}
			else
			{
				stopFlushTimer();
			}
		}

		private function startFlushTimer():void
		{
			m_flushTimer=new Timer(300000);
			m_flushTimer.addEventListener(TimerEvent.TIMER, onFlush);
			m_flushTimer.start();
		}
		
		private function stopFlushTimer():void
		{
			if(m_flushTimer)
			{
				m_flushTimer.stop();
				m_flushTimer.removeEventListener(TimerEvent.TIMER, onFlush);
				m_flushTimer = null;
			}
		}

		private function onFlush(evt:TimerEvent):void
		{
			if (m_dataChanged != true)
			{
				return;
			}

			try
			{
				m_sharedObject.flush();
			}
			catch (e:Error)
			{
				Log.error("SOCache.onFlush", e);
				this.dispatchEvent(new CacheEvent(CacheEvent.CACHE_ERROR));
				return;
			}

			m_dataChanged = false;
		}
	}
}