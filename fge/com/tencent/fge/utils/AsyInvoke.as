/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   AsyInvoke.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2009-11
#   Comment     :   一个基于AS3实现的用于异步调用一个函数的类
 * 					（目前通过延时10MS来实现异步）。
 * 
 * 					
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-11 文件创建 
#
*************************************************************************/

package com.tencent.fge.utils
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class AsyInvoke extends Invoke
	{		
		private var m_asyDelay:uint = 10;
		private var m_autoRelease:Boolean = false;
		
		public function get asyDelay():uint{return m_asyDelay;}
		public function set asyDelay(value:uint):void
		{
			m_asyDelay = value > 10 ? value : 10;
		}
		
		public static function execute(fun:Function, delay:int, ...arg):void
		{
			var asyInvoke:AsyInvoke = new AsyInvoke(fun, null);
			asyInvoke.arg = arg;
			asyInvoke.asyDelay = delay;
			asyInvoke.execute();
			asyInvoke.m_autoRelease = true;
		}
		
		public function AsyInvoke(fun:Function, ...arg)
		{
			super(fun);
			super.arg = arg;
		}
		
		override public function execute():void
		{
			var timer:Timer = new Timer(m_asyDelay,1)
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		protected function onTimer(e:Event):void
		{
			var timer:Timer = e.target as Timer;
			timer.stop();
			timer.reset();
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			super.execute();
			if(m_autoRelease)
			{
				this.release();
			}
		}
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	      		
	}
}