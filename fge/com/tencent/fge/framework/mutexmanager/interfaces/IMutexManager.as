package com.tencent.fge.framework.mutexmanager.interfaces
{
	import flash.events.IEventDispatcher;
	
	public interface IMutexManager
	{
		function generateOrder(mid:String):String;
		function acquire(mid:String, type:String, orderID:String, listener:Function = null, priority:int = 0):String;
		function release(mid:String, orderID:String):String;
		function acquireWeak(mid:String, type:String, listener:Function = null, priority:int = 0):String;
		function releaseWeak(mid:String):String;
	}
}