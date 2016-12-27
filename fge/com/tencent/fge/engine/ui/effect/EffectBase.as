package com.tencent.fge.engine.ui.effect
{
	import caurina.transitions.Tweener;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public class EffectBase
	{
		protected var m_target:DisplayObject;
		protected var m_time:Number = 0;
		protected var m_listener:Function;
		protected var m_delay:Number = 0;
		
		public function EffectBase(target:DisplayObject)
		{
			m_target = target;
		}
		
		public function set listener(value:Function):void
		{
			
		}
		
		public function set duration(value:Number):void
		{
			m_time = value;
		}
		
		public function set delay(value:Number):void
		{
			m_delay = value;
		}
		
		public function play(listener:Function = null):void
		{
			m_listener = listener;
		}
		
		protected function onTweenComplete():void
		{			
			if(m_listener != null)
			{
				m_listener();
				m_listener = null;
			}
		}
		
	}
}