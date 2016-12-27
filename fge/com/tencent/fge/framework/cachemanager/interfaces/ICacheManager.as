package com.tencent.fge.framework.cachemanager.interfaces
{
	import flash.events.IEventDispatcher;

	public interface ICacheManager extends IEventDispatcher
	{
		function getCache(name:String="TNT", domain:String = "", type:String = "so"):ICache;
		function pend():Boolean;
	}
}