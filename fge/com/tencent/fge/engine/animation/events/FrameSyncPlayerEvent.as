package com.tencent.fge.engine.animation.events
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class FrameSyncPlayerEvent extends Event
	{
		public static const FINISHED:String = "finished";
		
		public var mc:MovieClip;
		
		public function FrameSyncPlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}