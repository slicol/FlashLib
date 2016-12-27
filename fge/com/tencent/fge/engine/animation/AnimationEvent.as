package com.tencent.fge.engine.animation
{
	/*=============================================================================
	* Class:    AnimationEvent
	* Desc:      
	*============================================================================*/
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class AnimationEvent extends Event
	{	
		//define some event name and string. eg:
		public static const PLAY_END:String = "playEnd";
		
		public function AnimationEvent(type:String = PLAY_END, 
								  bubbles:Boolean=false, 
								  cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new AnimationEvent(type, bubbles, cancelable);
		}
		
		
		public static function dispatch(target:IEventDispatcher, type:String = PLAY_END,
										bubbles:Boolean=false, cancelable:Boolean=false):void
		{
			target.dispatchEvent(new AnimationEvent(type, bubbles, cancelable));
		}
		
		public static function addCommonEventListener(target:IEventDispatcher, listener:Function):void
		{
			//add common event listener. eg:
			target.addEventListener(PLAY_END, listener);
		}
		
		public static function removeCommonEventListener(target:IEventDispatcher, listener:Function):void
		{
			//remove common event listener. eg:
			target.removeEventListener(PLAY_END, listener);
		}
	}
}