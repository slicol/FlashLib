package com.tencent.fge.framework.pluginsystem.events
{
	import flash.events.Event;
	
	public class PluginSystemEvent extends Event
	{
		public static const PLGSYS_LOAD_COMPLETE:String = "plgsysLoadComplete";

		
		public function PluginSystemEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		
	}
}