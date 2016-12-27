package com.tencent.fge.engine.animation
{
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class FramePlayer extends Bitmap
	{
		private var m_frameTimer:Timer;
		private var m_frameIndex:int;
		private var m_frameCount:int;
		private var m_frameArray:Array;
		public function FramePlayer()
		{
		}
		
		public function create(frameData:Array, frameRate:int):void
		{
			m_frameTimer = new Timer(1000/frameRate);
			m_frameTimer.addEventListener(TimerEvent.TIMER, onFrameTimer);
			m_frameCount = frameData.length;
			m_frameArray = frameData;
		}
		
		public function destroy():void
		{
			m_frameArray = null;
			m_frameTimer.stop();
			m_frameTimer.removeEventListener(TimerEvent.TIMER, onFrameTimer);
			m_frameTimer = null;
			this.bitmapData = null;
		}
		
		public function play():void
		{
			m_frameTimer.start();
		}
		
		public function pause():void
		{
			m_frameTimer.stop();
			drawFrame();
		}
		
		public function stop():void
		{
			m_frameIndex = 0;
			m_frameTimer.stop();
			drawFrame();
		}
		
		public function gotoAndPlay(frameIndex:int):void
		{
			m_frameIndex = frameIndex;
			m_frameTimer.start();
		}
		
		public function gotoAndStop(frameIndex:int):void
		{
			m_frameIndex = frameIndex;
			m_frameTimer.stop();
			drawFrame();
		}

		
		
		private function onFrameTimer(e:Event):void
		{
			drawFrame();
			m_frameIndex++;
		}
		
		private function drawFrame():void
		{
			if(m_frameIndex >= m_frameCount)
			{
				m_frameIndex = 0;
			}
			this.bitmapData = m_frameArray[m_frameIndex];
		}

	}
}