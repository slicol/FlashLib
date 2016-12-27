package com.tencent.fge.framework.resmanager.events
{
	import flash.events.Event;
	
	public class ResEvent extends Event
	{
		public static const LOAD_SUCCESS:String = "loadSuccess";
		public static const LOAD_FAILED:String = "loadFailed";
		public static const LOAD_PROGRESS:String = "loadProgress";

		public var bytesTotal:Number = 0;
		public var bytesLoaded:Number = 0;
		public var path:String = "";
		
		public function ResEvent(type:String, 
								bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var evt:ResEvent = new ResEvent(this.type, this.bubbles, this.cancelable);
			evt.path = this.path;
			evt.bytesLoaded = this.bytesLoaded;
			evt.bytesTotal = this.bytesTotal;
			return evt;
		}
	}
}