package com.tencent.fge.events
{
	/*=============================================================================
	* Class:    UpdateEvent
	* Desc:      
	*============================================================================*/
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class UpdateEvent extends Event
	{	
		//define some event name and string. eg:
		public static const UPDATE:String = "upate";
		
		public function UpdateEvent(type:String = UPDATE, 
								  bubbles:Boolean=false, 
								  cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new UpdateEvent(type, bubbles, cancelable);
		}
		
		
		public static function dispatch(target:IEventDispatcher, type:String = UPDATE,
										bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			target.dispatchEvent(new UpdateEvent(type, bubbles, cancelable));
		}
		
		public static function addCommonEventListener(target:IEventDispatcher, listener:Function):void
		{
			//add common event listener. eg:
			target.addEventListener(UPDATE, listener);
		}
		
		public static function removeCommonEventListener(target:IEventDispatcher, listener:Function):void
		{
			//remove common event listener. eg:
			target.removeEventListener(UPDATE, listener);
		}
	}
}