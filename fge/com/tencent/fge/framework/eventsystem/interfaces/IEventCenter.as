package com.tencent.fge.framework.eventsystem.interfaces
{
	import flash.events.Event;

	public interface IEventCenter
	{
		function addEventListener(type:String, listener:Function, priority:int=0, obj:* = null, listenerName:String = ""):void;
		function removeEventListener(type:String, listener:Function, obj:* = null, listenerName:String = ""):void;
		function dispatchEvent(event:Event, obj:* = null, dispatcherFuncName:String = ""):Boolean;
	}
}

//public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
//{
//}
//
//public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
//{
//}
//
//public function dispatchEvent(event:Event):Boolean
//{
//	return false;
//}
//
//public function hasEventListener(type:String):Boolean
//{
//	return false;
//}
//
//public function willTrigger(type:String):Boolean
//{
//	return false;
//}