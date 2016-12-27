package com.tencent.fge.framework.mutexmanager.interfaces
{
	

	public interface IMutex
	{
		function create(strMid:String):void;
			
		function get mid():String;
		
		function get ref():int;
		function get status():String;
		
		function acquire(type:String, orderID:String, listener:Function = null, priority:int = 0):String;
		function release(orderID:String):String;
	}
}