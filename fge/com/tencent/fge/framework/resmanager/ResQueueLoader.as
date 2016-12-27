package com.tencent.fge.framework.resmanager
{
	import com.tencent.fge.framework.resmanager.data.ResType;
	import com.tencent.fge.framework.resmanager.loader.ResLoader;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class ResQueueLoader
	{
		private var m_queue:Array = new Array();
		private var m_timer:Timer = new Timer(10,1);
		private var m_idle:Boolean = true;
		private var m_ldrWorker:ResLoader;
		private var m_hlpWorker:QueueHelper;
		
		private var m_allListener:Function;
		private var m_resType:String;
		
		public function ResQueueLoader(resType:String = "")
		{
			m_resType = resType;
		}
		
		public function initialize(allListener:Function):void
		{
			m_timer.addEventListener(TimerEvent.TIMER, onTimerNext);
			m_allListener = allListener;
		}
		
		public function finalize():void
		{
			m_timer.removeEventListener(TimerEvent.TIMER, onTimerNext);
			
			if(m_ldrWorker)
			{
				m_ldrWorker.removeAllEventListener(onLoaderEvent);
				m_ldrWorker.unload();
				m_ldrWorker = null;
			}
		}
		
		public function load(url:String, allListener:Function = null):void
		{
			if(url == null || url == "")
			{
				return;
			}
			
			if(allListener == null)
			{
				allListener = m_allListener;
			}
			
			var hlp:QueueHelper;
			hlp = new QueueHelper;
			hlp.url = url;
			hlp.allListener = allListener;
			m_queue.push(hlp);
			

			if(m_idle)
			{
				m_idle = false;
				m_timer.start();
			}
		}
		
		private function loadWorker():void
		{
			if(m_queue.length > 0)
			{
				m_hlpWorker = m_queue[0];

				m_ldrWorker = new ResLoader(m_resType);
				m_ldrWorker.load(m_hlpWorker.url, "0");
				m_ldrWorker.addAllEventListener(onLoaderEvent);
				
				m_queue.splice(0,1);
			}
			else
			{
				m_idle = true;
			}
			
		}
		
		private function onTimerNext(e:Event):void
		{
			loadWorker();
		}
		
		private function onLoaderEvent(e:Event):void
		{
			if(e.type != ProgressEvent.PROGRESS)
			{
				m_timer.start();
				
				if(m_ldrWorker)
				{
					m_ldrWorker.removeAllEventListener(onLoaderEvent);
				}
				
				if(m_hlpWorker && m_hlpWorker.allListener != null)
				{
					m_hlpWorker.allListener(e);
				}

			}
		}
	}
}


class QueueHelper
{
	public var url:String = "";
	public var allListener:Function;
}