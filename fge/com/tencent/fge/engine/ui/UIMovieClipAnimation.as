package com.tencent.fge.engine.ui
{
	import com.tencent.fge.utils.SWFUtil;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class UIMovieClipAnimation extends UIMovieClipCtlBase
	{
		private var m_continuous:Boolean = false;
		private var m_stopall:Boolean = false;
		private var m_renderableWhenStop:Boolean = false;
		
		public function UIMovieClipAnimation(ui:MovieClip=null, continuous:Boolean = false, stopall:Boolean = false, renderableWhenStop:Boolean = true)
		{
			super(ui);
			m_continuous = continuous;
			m_stopall = stopall;
			m_renderableWhenStop = renderableWhenStop;
		}
		
		override public function play():void
		{
			super.play();
			ui.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			super.renderable = true;
		}
		
		override public function gotoAndPlay(frame:Object, scene:String=null):void
		{
			super.gotoAndPlay(frame, scene);
			ui.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			super.renderable = true;
		}
		
		private function onEnterFrame(e:Event):void
		{
			if(ui.currentFrame >= ui.totalFrames)
			{
				if(m_continuous)
				{
					gotoAndPlay(1);
				}
				else
				{	
					stop();
				}
			}
		}
		
		override public function gotoAndStop(frame:Object, scene:String=null):void
		{
			super.gotoAndStop(frame, scene);
			ui.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			if(m_stopall)
			{
				stopAll();
			}
			else
			{
				if(!m_renderableWhenStop)
				{
					super.renderable = false;
				}
			}
		}
		
		override public function stop():void
		{
			super.stop();			
			ui.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			if(m_stopall)
			{
				stopAll();
			}
			else
			{
				if(!m_renderableWhenStop)
				{
					super.renderable = false;
				}				
			}
		}
		
		public function stopAll():void
		{
			SWFUtil.killAllAnimation(ui);
			
			if(!m_renderableWhenStop)
			{
				super.renderable = false;
			}
		}
		
		
		
	}
}