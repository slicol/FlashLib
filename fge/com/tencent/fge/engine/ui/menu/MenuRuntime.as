package com.tencent.fge.engine.ui.menu
{
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;

	public class MenuRuntime extends EventDispatcher
	{
		public var container:DisplayObjectContainer;
		public var containerWidth:Number;
		public var containerHeight:Number;
		public var menuTarget:Object;
		public var menu:Menu;
		public var name:String;
		public var listener:Function;
		public var cfg:MenuConfig;
		public var stage:DisplayObjectContainer;
		
		public function MenuRuntime()
		{
		}
	}
}