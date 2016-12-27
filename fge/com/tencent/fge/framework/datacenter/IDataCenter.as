package com.tencent.fge.framework.datacenter
{
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;

	public interface IDataCenter extends IEventDispatcher
	{
		function addDataListener(sDataName:String, listener:Function, bAsy:Boolean = true):void;
		function removeDataListener(sDataName:String, listener:Function):void;
		function writeInt32(sName:String, xValue:int):Boolean;
		function writeInt64(sName:String, xValue:String):Boolean;
		function writeNumber(sName:String, xValue:Number):Boolean;
		function writeString(sName:String, xValue:String):Boolean;
		function writeBytes(sName:String, xValue:ByteArray):Boolean;
		function readInt32(sName:String):int;
		function readInt64(sName:String):String;
		function readNumber(sName:String):Number;
		function readString(sName:String):String;
		function readBytes(sName:String):ByteArray;
	}
}