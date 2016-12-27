package com.tencent.fge.debug
{
	import com.tencent.fge.foundation.log.client.Log;
	

	public class Debugger
	{
		public static var DEBUG_CPU:Boolean = false;
		public static var DEBUG_LOCAL:Boolean = false;
		
		public function Debugger()
		{
		}
		
		private static var s_cpuVampire:CpuVampire;
		public static function cpuVampire(enabled:Boolean, deltaTime:int = 250, iteration:int = 100000):void
		{
			if(null == s_cpuVampire)
			{
				s_cpuVampire = new CpuVampire;
			}
			
			if(false == enabled)
			{
				s_cpuVampire.stop();
			}
			else
			{
				if(0 < deltaTime)
				{
					s_cpuVampire.setDeltaTime(deltaTime);
				}
				if(0 < iteration)
				{
					s_cpuVampire.setIteration(iteration);
				}
				
				s_cpuVampire.start();
			}
		}
		
		
		public static function traceStack():String
		{
			try
			{
				throw new Error("trace stack");
			}
			catch(err:Error)
			{
				if(null != err)
				{
					var strStack:String = err.getStackTrace();
					Log.trace("traceStack", "stack=\n" + strStack);
				}
				
				return strStack;
			}
			
			return "";
		}
	}
}


import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

/**
 * ...
 * @author DonaldWu
 */

 

/*=============================================================================
*	Class:	CpuVampire
*	Desc:	a vampire which sucks the CPU's blood, Hahahahahahaha....
*============================================================================*/
class CpuVampire
{
	private var m_timer:Timer;
	private var m_iteration:int;
	
	
	public function CpuVampire()
	{
		m_timer = new Timer(250, 0);
		m_iteration = 100000;
	}
	
	 
	public function setDeltaTime(deltaTime:int):void
	{
		m_timer.delay = deltaTime;
	}
	
	 
	public function setIteration(iteration:int):void
	{
		m_iteration = iteration;
	}
	
	public function start():void
	{
		m_timer.addEventListener(TimerEvent.TIMER, onTimer);
		m_timer.reset();
		m_timer.start();
	}
	 
	public function stop():void
	{
		m_timer.stop();
		m_timer.removeEventListener(TimerEvent.TIMER, onTimer);
	}
	
	private function onTimer(e:TimerEvent):void
	{
		var d:Number = 0.002 * getTimer();
		var result:Number = 0.03 * getTimer();
		var i:int;
		for(i = m_iteration; i > 0; --i)
		{
			result += 0.001 * getTimer();
			d += 0.02 * getTimer();
			result += Math.sqrt(d);
			result += Math.pow(result, 0.3);
			result += 0.007 * getTimer();
			d += 0.003 * getTimer();
			result += Math.sqrt(d);
			result += Math.pow(result, 0.4);
		}
	}
}