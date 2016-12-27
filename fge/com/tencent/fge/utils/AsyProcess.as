package com.tencent.fge.utils
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class AsyProcess
	{
		private var m_asyTimer:Timer;
		private var m_lstAsyInvoke:Array = new Array;
		
		public function AsyProcess(asyDelay:int)
		{
			m_asyTimer = new Timer(asyDelay);
			m_asyTimer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		public function asyInvoke(fun:Function, ...arg):void
		{
			var invoke:Invoke = new Invoke(fun);
			invoke.arg = arg;
			m_lstAsyInvoke.push(invoke);
			
			if(!m_asyTimer.running)
			{
				m_asyTimer.start();
			}
		}
		
		public function asyInvokeUnique(fun:Function, ...arg):void
		{
			var invoke:Invoke;
			
			for(var i:int = 0; i < m_lstAsyInvoke.length; ++i)
			{
				invoke = m_lstAsyInvoke[i];
				if(invoke.fun == fun)
				{
					invoke.arg = arg;
					break;
				}
			}
			
			if(i >= m_lstAsyInvoke.length)
			{
				invoke = new Invoke(fun);
				invoke.arg = arg;
				m_lstAsyInvoke.push(invoke);
			}
			
			if(!m_asyTimer.running)
			{
				m_asyTimer.start();
			}
		}
		
		private function onTimer(e:Event):void
		{
			var lst:Array = m_lstAsyInvoke.concat();
			for(var i:int = 0; i < lst.length; ++i)
			{
				var invoke:Invoke = lst[i];
				invoke.execute();
			}
			
			m_lstAsyInvoke = [];
		}
		
		
		
		
		
	}
}