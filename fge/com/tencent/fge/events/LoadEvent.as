package com.tencent.fge.events
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class LoadEvent extends Event
	{	
		//define some event name and string. eg:
		public static const COMPLETE:String = "complete";
		public static const ERROR:String = "error";
		public static const UNLOAD:String = "unload";
		public static const PROGRESS:String = "progress";
		
		public var progress:Number = 0;
		
		public function LoadEvent(type:String = COMPLETE, 
								  bubbles:Boolean=false, 
								  cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var e:LoadEvent = new LoadEvent(type, bubbles, cancelable);
			e.progress = this.progress;
			return e;
		}
		
		
		
	}
}