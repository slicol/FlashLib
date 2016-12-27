package com.tencent.fge.framework.eventsystem
{
	internal class EventListener
	{
		public var m_type:String;
		public var m_listener:Function;
		public var m_listenerName:String;
		public var m_objName:String;
		public var m_useCapture:Boolean = false;
		public var m_priority:int = 0;
		public var m_useWeakReference:Boolean = false;
		
		public function EventListener()
		{
		}
		
		public static function sortOnPriority(a:EventListener, b:EventListener):Number
		{
			if(a.m_priority > b.m_priority) return 1;
			else if(a.m_priority < b.m_priority) return -1;
			else return 0;
		}
		
		
		public function hasListener(item:*, index:int, array:Array):Boolean
		{
			var order:EventListener = item as EventListener;
			if(order.m_listener == this.m_listener)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}
}