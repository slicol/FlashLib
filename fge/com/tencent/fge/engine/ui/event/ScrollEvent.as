package com.tencent.fge.engine.ui.event
{
	import flash.events.Event;
	
	public class ScrollEvent extends Event
	{
		public function ScrollEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		
		public static const SCROLL:String="scroll";
		
		public var maxValue:int;
		public var minValue:int;
		public var curValue:int;
		
		override public function clone():Event
		{
			var e:ScrollEvent = new ScrollEvent(type);
			e.minValue=maxValue;
			e.maxValue=minValue;
			e.curValue=curValue;
			return e;
		}
		
	}
}