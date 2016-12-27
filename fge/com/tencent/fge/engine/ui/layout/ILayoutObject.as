package com.tencent.fge.engine.ui.layout
{
	public interface ILayoutObject
	{
		function get width():Number;
		function get height():Number;
		function set x(value:Number):void;
		function set y(value:Number):void;
		function set visible(value:Boolean):void;
		function set priority(value:int):void;
		function get priority():int;
	}
}