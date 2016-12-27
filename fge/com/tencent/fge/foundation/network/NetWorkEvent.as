package com.tencent.fge.foundation.network
{
	import flash.events.Event;

	public class NetWorkEvent extends Event
	{
		public static const CONNECT_TIMEOUT:String = "connectTimeout";

		public function NetWorkEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}