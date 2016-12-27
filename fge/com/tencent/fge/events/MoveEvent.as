package com.tencent.fge.events
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class MoveEvent extends Event
	{	
		//define some event name and string. eg:
		public static const MOVE:String = "move";
		
		public var x:int = 0;
		public var y:int = 0;
		public var lastX:int = 0;
		public var lastY:int = 0;
		
		
		public function MoveEvent(type:String = MOVE, x:int = 0, y:int = 0, lastX:int = 0, lastY:int = 0,
								  bubbles:Boolean=false, 
								  cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.x = x;
			this.y = y;
			this.lastX = lastX;
			this.lastY = lastY;
		}
		
		override public function clone():Event
		{
			return new MoveEvent(type,x,y,lastX,lastY, bubbles, cancelable);
		}
		
		
		public static function dispatch(target:IEventDispatcher, type:String,
										x:int = 0, y:int = 0, lastX:int = 0, lastY:int = 0,
										bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			target.dispatchEvent(new MoveEvent(type,x,y,lastX,lastY, bubbles, cancelable));
		}
		
		public static function addCommonEventListener(target:IEventDispatcher, listener:Function):void
		{
			//add common event listener. eg:
			target.addEventListener(MOVE, listener);
		}
		
		public static function removeCommonEventListener(target:IEventDispatcher, listener:Function):void
		{
			//remove common event listener. eg:
			target.removeEventListener(MOVE, listener);
		}
	}
		
}