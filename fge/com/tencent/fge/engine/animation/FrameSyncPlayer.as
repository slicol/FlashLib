package com.tencent.fge.engine.animation
{
	import com.tencent.fge.engine.animation.events.FrameSyncPlayerEvent;
	import com.tencent.fge.engine.ui.UISystem;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author DonaldWu
	 */
	
	/*=============================================================================
	*	Class:	MCFrameSyncPlayer
	*	Desc:	MCFrameSyncPlayer is a singleton.
	*============================================================================*/
	public class FrameSyncPlayer extends EventDispatcher
	{
		//{ region singleton
		private static var ms_instance:FrameSyncPlayer = null;
		private static var ms_bSigletonCreated:Boolean = false;
		private static var ms_iCountInstances:int = 0;
		
		public function FrameSyncPlayer() 
		{   
			++ms_iCountInstances;   
			if(!ms_bSigletonCreated || ms_iCountInstances != 1)
			{
				--ms_iCountInstances;
				throw new Error( "Access FrameSyncPlayer by FrameSyncPlayer.singleton!" );
			}
		}
		
		public static function get singleton():FrameSyncPlayer
		{
			if(FrameSyncPlayer.ms_instance == null)
			{
				FrameSyncPlayer.ms_bSigletonCreated = true;
				FrameSyncPlayer.ms_instance = new FrameSyncPlayer;
				FrameSyncPlayer.ms_instance.initialize();
			}
			
			return ms_instance;
		}
		//} endregion
		
		
		
		
		private var m_stage:Stage;
		private var m_fps:int;
		
		private static const s_frameTolerance:int = 5;
		private var m_lstPlayerHelper:Vector.<FrameSyncMc>;
		
		public function initialize():void 
		{
			m_stage = UISystem.getInstance().stage;
			m_fps = m_stage.frameRate;
			// add additional initialization here
		}
		
		
		
		public function finalize():void
		{
			// finalize the singleton
		}
		public function play(mc:MovieClip, startFrame:int, endFrame:int):void
		{
			if(null == m_lstPlayerHelper)
			{
				m_lstPlayerHelper = new Vector.<FrameSyncMc>;
			}
			
			var oneFrameSyncMc:FrameSyncMc;
			var isPlayerHelperFound:Boolean = false;
			var i:int;
			for(i = 0; i < m_lstPlayerHelper.length; ++i)
			{
				if(mc == m_lstPlayerHelper[i].mc)
				{
					oneFrameSyncMc = m_lstPlayerHelper[i];
					isPlayerHelperFound = true;
					break;
				}
			}
			
			if(false == isPlayerHelperFound)
			{
				oneFrameSyncMc = new FrameSyncMc;
				m_lstPlayerHelper.push(oneFrameSyncMc);
			}
			
			oneFrameSyncMc.mc = mc;
			oneFrameSyncMc.startFrame = startFrame;
			oneFrameSyncMc.endFrame = endFrame;
			oneFrameSyncMc.startTime = getTimer();
			oneFrameSyncMc.endTime = oneFrameSyncMc.startTime +
				(oneFrameSyncMc.endFrame - oneFrameSyncMc.startFrame) * 1000 / m_fps;
			
			m_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			mc.gotoAndPlay(startFrame);
		}
		
		public function stop(mc:MovieClip):void
		{
			if(null == m_lstPlayerHelper)
			{
				return;
			}
			
			var i:int;
			var oneFrameSyncMc:FrameSyncMc;
			var isPlayerHelperFound:Boolean = false;
			for(i = 0; i < m_lstPlayerHelper.length; ++i)
			{
				if(mc == m_lstPlayerHelper[i].mc)
				{
					oneFrameSyncMc = m_lstPlayerHelper[i];
					isPlayerHelperFound = true;
					break;
				}
			}
			
			if(true == isPlayerHelperFound)
			{
				oneFrameSyncMc.mc.stop();
				m_lstPlayerHelper.splice(i, 1);
			}
		}
		
		private function onEnterFrame(e:Event):void
		{
			var currTime:int = getTimer();
			
			var i:int;
			var oneFrameSyncMc:FrameSyncMc;
			for(i = m_lstPlayerHelper.length - 1; i >= 0; --i)
			{
				oneFrameSyncMc = m_lstPlayerHelper[i] as FrameSyncMc;
				
				//	check time
				if(oneFrameSyncMc.endTime >= currTime)
				{
					//	reach end time
					//	force to stop
					playerFinishWorker(i);
				}
				else
				{
					//	check frame
					var timeElapsed:int = currTime - oneFrameSyncMc.startTime;
					var syncedFrame:int = oneFrameSyncMc.startFrame + timeElapsed * m_fps / 1000;
					if(syncedFrame >= oneFrameSyncMc.endFrame)
					{
						//	reach end frame
						//	force to stop
						playerFinishWorker(i);
					}
					else
					{
						if(Math.abs(oneFrameSyncMc.mc.currentFrame - syncedFrame) <= s_frameTolerance)
						{
							oneFrameSyncMc.mc.gotoAndPlay(syncedFrame);
						}
					}
				}
			}
			
			if(0 == m_lstPlayerHelper.length)
			{
				m_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}
		 
		private function playerFinishWorker(index:int):void
		{
			var oneFrameSyncMc:FrameSyncMc = m_lstPlayerHelper[index];
			
			try
			{
				oneFrameSyncMc.mc.gotoAndStop(oneFrameSyncMc.endFrame);
			}catch(e:Error){}
			
			m_lstPlayerHelper.splice(index, 1);
			
			var mcFinishedEvent:FrameSyncPlayerEvent;
			mcFinishedEvent = new FrameSyncPlayerEvent(FrameSyncPlayerEvent.FINISHED);
			mcFinishedEvent.mc = oneFrameSyncMc.mc;
			dispatchEvent(mcFinishedEvent);
			
		}
	}
}

import flash.display.MovieClip;


class FrameSyncMc
{
	public var mc:MovieClip;
	public var startFrame:int;
	public var endFrame:int;
	
	public var startTime:int;
	public var endTime:int;
}