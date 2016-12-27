package com.tencent.fge.engine.animation
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Attenuator
	{
		private var m_target:DisplayObject;
		private var m_ampX:Number = 50;
		private var m_ampY:Number = 50;
		private var m_atteCoef:Number = 0.9;
		private var m_timeCoef:Number = 100;
		private var m_atteTimer:Timer = new Timer(100);
		private var m_targetX:Number = 0;
		private var m_targetY:Number = 0;
		
		private var m_x:Number = 0;
		private var m_y:Number = 0;
		private var m_attenuating:Boolean = false;
		
		private var m_targetLastBaseX:Number;
		private var m_targetLastBaseY:Number;
		private var m_targetLastResultX:Number;
		private var m_targetLastResultY:Number;
		
		public function Attenuator(target:DisplayObject)
		{
			m_target = target;
			m_targetX = m_target.x;
			m_targetY = m_target.y;
		}
		
		public static function attenuate(target:DisplayObject,
										 ampX:Number = 50, ampY:Number = 50, 
										 atteCoef:Number = 0.9, timeCoef:Number = 100):void
		{
			var atte:Attenuator = new Attenuator(target);
			atte.attenuate(ampX, ampY, atteCoef, timeCoef);
		}
		
		public function attenuate(ampX:Number = 50, ampY:Number = 50, 
								  atteCoef:Number = 0.9, timeCoef:Number = 100):void
		{
			if(!m_attenuating)
			{
				m_targetX = m_target.x;
				m_targetY = m_target.y;
				m_targetLastBaseX = m_target.x;
				m_targetLastBaseY = m_target.y;
				m_targetLastResultX = m_target.x;
				m_targetLastResultY = m_target.y;
			}
			
			m_ampX = ampX;
			m_ampY = ampY;
			m_atteCoef = atteCoef;
			m_timeCoef = timeCoef;
			m_atteTimer.delay = timeCoef;
			m_atteTimer.addEventListener(TimerEvent.TIMER, onAtteTimer);
			m_atteTimer.start();
			
			m_x = m_ampX;
			m_y = m_ampY;
		}
		
		
		private function onAtteTimer(e:Event):void
		{
			m_attenuating = true;
			var x:Number = m_x * m_atteCoef;
			var y:Number = m_y * m_atteCoef;
			
			var xDeltaWithoutAtte:Number = m_target.x - m_targetLastResultX;
			var yDeltaWithoutAtte:Number = m_target.y - m_targetLastResultY;
			
			m_targetLastBaseX += xDeltaWithoutAtte;
			m_targetLastBaseY += yDeltaWithoutAtte;
			m_target.x = m_targetLastBaseX + x;
			m_target.y = m_targetLastBaseY + y;
			
			m_targetLastResultX = m_target.x;
			m_targetLastResultY = m_target.y;
			
			m_y = -y;
			m_x = -x;
			if(x < 0.01 && x > -0.01 && y < 0.01 && y > -0.01)  
			{
				m_attenuating = false;
				m_atteTimer.stop();
				m_atteTimer.removeEventListener(TimerEvent.TIMER, onAtteTimer);
				
				//				m_target.x = m_targetLastBaseX;
				//				m_target.y = m_targetLastBaseY;
				
			}
		}
	}
}