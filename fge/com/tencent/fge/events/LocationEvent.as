package com.tencent.fge.events
{
	import flash.events.Event;
	
	public class LocationEvent extends Event
	{
		public static const LOCATION:String = "location";
		
		public var x:Number = 0;
		public var y:Number = 0;
		
		public function LocationEvent(type:String, x:Number, y:Number, 
									  bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.x = x;
			this.y = y;
		}
		
		override public function clone():Event
		{
			var e:LocationEvent = new LocationEvent(this.type, x, y);
			return e;
		}
		
		
	}
}