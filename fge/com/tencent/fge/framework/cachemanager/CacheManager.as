package com.tencent.fge.framework.cachemanager
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.cachemanager.data.CacheType;
	import com.tencent.fge.framework.cachemanager.events.CacheEvent;
	import com.tencent.fge.framework.cachemanager.interfaces.ICache;
	import com.tencent.fge.framework.cachemanager.interfaces.ICacheManager;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.utils.Dictionary;

	[Event(name="pending", type="com.tencent.fge.framework.cachemanager.events.CacheEvent")]
	[Event(name="prePending", type="com.tencent.fge.framework.cachemanager.events.CacheEvent")]
	[Event(name="pendingFaild", type="com.tencent.fge.framework.cachemanager.events.CacheEvent")]
	[Event(name="cacheError", type="com.tencent.fge.framework.cachemanager.events.CacheEvent")]
	[Event(name="pendingSuccess", type="com.tencent.fge.framework.cachemanager.events.CacheEvent")]
	public class CacheManager extends EventDispatcher implements ICacheManager
	{
		private static var ms_instance:CacheManager;
		private var m_defaultShareObject:SharedObject;
		private var m_lstCache:Dictionary = new Dictionary;

		public function CacheManager(target:IEventDispatcher=null)
		{
			super(target);
		}

		public static function getInstance():CacheManager
		{
			if (ms_instance == null)
			{
				ms_instance=new CacheManager;
			}
			return ms_instance;
		}

		public static function initialize():Boolean
		{
			return getInstance().initialize();
		}


		public function initialize():Boolean
		{
			return true;
		}

		public static function finalize():void
		{
			getInstance().finalize();
		}

		public function finalize():void
		{
			for each (var cache:ICache in m_lstCache)
			{
				cache.finalize();
				cache.removeEventListener(CacheEvent.CACHE_ERROR, onCacheError);
			}
		}
		
		
		public static function getCache(name:String="TNT", domain:String=null, type:String=CacheType.SO):ICache
		{
			return getInstance().getCache(name, domain, type);
		}

		//获取缓存管理器
		public function getCache(name:String="TNT", domain:String=null, type:String=CacheType.SO):ICache
		{
			var cache:ICache = m_lstCache[name];
			if(cache == null)
			{
				if(type == CacheType.SO)
				{
					cache = new SOCache(name, domain);
					m_lstCache[name] = cache;
					cache.addEventListener(CacheEvent.CACHE_ERROR, onCacheError);
					cache.initialize();
				}
			}
			return cache;
		}

		//弹出询问面板
		public function pend():Boolean
		{
			var ret:Boolean = false;
			
			//获取一默认ShareObject调用写入函数使flash player弹出询问框
			m_defaultShareObject=SharedObject.getLocal("com.tencent.tnt.defaultSo");
			
			var flushStatus:String;
			try
			{
				flushStatus=m_defaultShareObject.flush(1024 * 20);
			}
			catch (error:Error)
			{
				Log.error("CacheManager.pend", error);
				this.dispatchEvent(new CacheEvent(CacheEvent.CACHE_ERROR));
			}

			
			if (flushStatus != null)
			{
				if (flushStatus == SharedObjectFlushStatus.PENDING)
				{
					ret = true;
					m_defaultShareObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
				}
				else if(flushStatus== SharedObjectFlushStatus.FLUSHED)
				{
					pendComplete();
				}
			}	
			
			return ret;
		}
		//等待用户操作询问面板
		private function onFlushStatus(evt:NetStatusEvent):void
		{
			evt.target.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);

			if (evt.info.code == "SharedObject.Flush.Failed")
			{
				this.dispatchEvent(new CacheEvent(CacheEvent.PENDING_FAILED));
				return;
			}
			
			this.dispatchEvent(new CacheEvent(CacheEvent.PENDING_SUCCESS));
			pendComplete();
		}
		
		//当第一次登录且用户允许写入数据缓存后
		private function pendComplete():void
		{
			m_defaultShareObject.data.exist = true;
			SOCache.ms_enabled = true;
			for each(var cache:ICache in m_lstCache)
			{
				cache.enabled = true;
			}
			m_defaultShareObject.flush();
		}
		
		//数据写入缓存失败
		private function onCacheError(evt:Event):void
		{
			this.dispatchEvent(evt.clone());
		}

	}
}