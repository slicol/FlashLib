package com.tencent.fge.framework.cachemanager.interfaces
{
	import com.tencent.fge.framework.cachemanager.data.CacheData;
	
	import flash.events.IEventDispatcher;

	public interface ICache extends IEventDispatcher
	{
		function initialize():void;
		function finalize():void;
 		function write(id:String, ver:int, data:*):Boolean;
		function read(id:String):CacheData;
		function set enabled(value:Boolean):void;
	}
}