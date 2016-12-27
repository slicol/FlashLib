package com.tencent.fge.foundation.signals
{
	public interface ISignal
	{
		function get numListeners():uint;
		
		function addOnce(listener:Function):void;
		
		function add(listener:Function):void;
		
		function dispatch(...valueObjects):void;
		
		function remove(listener:Function):void;
		
		function removeAll():void
	}
}