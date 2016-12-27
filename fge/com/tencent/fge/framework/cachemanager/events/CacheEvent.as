package com.tencent.fge.framework.cachemanager.events
{
	import flash.events.Event;

	public class CacheEvent extends Event
	{
		public static const PENDING:String="pending";
		public static const PRE_PENDING:String="prePending";
		public static const PENDING_FAILED:String="pendFaild";
		public static const CACHE_ERROR:String="cacheError";
		public static const PENDING_SUCCESS:String="pendingSuccess";
		public function CacheEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		override public function clone():Event{
			return new CacheEvent(this.type);
		}
	}
}