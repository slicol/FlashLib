package com.tencent.fge.framework.resmanager.interfaces
{
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;

	public interface IAtomLoader extends IEventDispatcher
	{
		function addAllEventListener(listener:Function):void;
		function removeAllEventListener(listener:Function):void;
		function unload():void;
		function cleanMemory():void;
		function get url():String;
		function get value():*;
		function get bytes():ByteArray;
		function get applicationDomain():ApplicationDomain;
		function get size():uint;
		function get usepack():Boolean;
	}
}