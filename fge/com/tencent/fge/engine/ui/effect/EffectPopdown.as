package com.tencent.fge.engine.ui.effect
{
	import caurina.transitions.Tweener;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public class EffectPopdown extends EffectBase
	{
		protected var m_targetX:int;
		protected var m_targetY:int;
		protected var m_oriX:int;
		protected var m_oriY:int;
		protected var m_oriSX:Number = 1;
		protected var m_oriSY:Number = 1;
		protected var m_oriAlpha:Number = 1;
		
		public function EffectPopdown(target:DisplayObject)
		{
			super(target);
			m_oriX = m_target.x;
			m_oriY = m_target.y;
			m_oriSX = m_target.scaleX;
			m_oriSY = m_target.scaleY;
			m_oriAlpha = m_target.alpha;
		}
		
		public function set rect(value:Rectangle):void
		{
			m_targetX = value.x + value.width/2;
			m_targetY = value.y + value.height/2;
		}
		
		override public function play(listener:Function = null):void
		{
			super.play(listener);
			
			Tweener.addTween(m_target, {time:m_time, alpha:0, scaleX:0, scaleY:0, x:m_targetX, y:m_targetY, transition:"easeInBack", onComplete:onTweenComplete});
		}
		
		override protected function onTweenComplete():void
		{
			m_target.visible = false;
			m_target.x = m_oriX;
			m_target.y = m_oriY;
			m_target.scaleX = m_oriSX;
			m_target.scaleY = m_oriSY;
			m_target.alpha = m_oriAlpha;
			
			super.onTweenComplete();
		}
		
	}
}