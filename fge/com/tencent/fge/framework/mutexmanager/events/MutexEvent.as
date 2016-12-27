package com.tencent.fge.framework.mutexmanager.events
{
	import flash.events.Event;
	
	public class MutexEvent extends Event
	{
		public static const AVAILABLE:String = "AVAILABLE";
		
		public var m_mid:String;
		
		public function MutexEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/*---------------------------------------------------------
		* Setter and Getter: mid
		*--------------------------------------------------------*/
		public function set mid(value:String):void { m_mid = value; }
		public function get mid():String { return m_mid; }
		
		
	}
}