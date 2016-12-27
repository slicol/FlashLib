package com.tencent.fge.engine.ui.effect
{
	import caurina.transitions.Tweener;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	public class EffectPopup extends EffectBase
	{
		protected var m_targetX:int;
		protected var m_targetY:int;
		protected var m_targetSX:Number = 1;
		protected var m_targetSY:Number = 1;
		protected var m_targetAlpha:Number = 1;
		
		public function EffectPopup(target:DisplayObject)
		{
			super(target);
			m_targetX = m_target.x;
			m_targetY = m_target.y;
			m_targetSX = m_target.scaleX;
			m_targetSY = m_target.scaleY;
			m_targetAlpha = m_target.alpha;
		}
		
		public function set rect(value:Rectangle):void
		{
			m_target.x = value.x + value.width/2;
			m_target.y = value.y + value.height/2;
		}
		

		
		override public function play(listener:Function = null):void
		{
			super.play(listener);
			
			m_target.scaleX = 0;
			m_target.scaleY = 0;
			m_target.alpha = 0;
			m_target.visible = true;
			
			Tweener.addTween(m_target, {time:m_time, delay:m_delay, alpha:m_targetAlpha, scaleX:m_targetSX, scaleY:m_targetSY, x:m_targetX, y:m_targetY, transition:"easeOutBack", onComplete:onTweenComplete});
		}

	}
}