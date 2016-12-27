package com.tencent.fge.framework.pluginsystem.events
{
	import flash.events.Event;
	
	public class PluginEvent extends Event
	{
		public static const LOAD_COMPLETE:String = "loadComplete";
		public static const LOAD_PROGRESS:String = "loadProgress";
		public static const LOAD_ERROR:String = "loadError";
		
		public var plgId:String = "";
		public var plgResTotal:Number = 0;
		public var plgResLoaded:Number = 0;
		public var plgResError:Number = 0;
		public var curResPath:String = "";
		public var curResBytesTotal:Number = 0;
		public var curResBytesLoaded:Number = 0;
		
		
		public function PluginEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var evt:PluginEvent = new PluginEvent(type);
			
			evt.plgId = this.plgId;
			evt.plgResTotal = this.plgResTotal;
			evt.plgResLoaded = this.plgResLoaded;
			evt.plgResError = this.plgResError;
			evt.curResPath = this.curResPath;
			evt.curResBytesTotal = this.curResBytesTotal;
			evt.curResBytesLoaded = this.curResBytesLoaded;

			return evt;
		}		
	}
}