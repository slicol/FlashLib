package com.tencent.fge.framework.pluginsystem.events
{	
	import flash.events.Event;
	
	public class ExtensionPointEvent extends Event
	{
		public static const LOAD_COMPLETE:String = "loadComplete";
		public static const LOAD_ERROR:String = "loadError";
		
		public var id:String = "";
		
		public function ExtensionPointEvent(type:String, id:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.id = id;
		}
		
		override public function clone():Event
		{
			var e:ExtensionPointEvent = new ExtensionPointEvent(type, this.id);
			return e;
		}
	}
}