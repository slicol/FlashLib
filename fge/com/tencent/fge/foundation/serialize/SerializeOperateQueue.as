/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   SerializeOperateQueue.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2009-6
#   Comment     :   实现一个通用的串行操作队列类，对一系列操作的时序进行控制，
 * 					使其按照串行的顺序挨个地执行。它是一个相对通用的类，
 * 					其目标是为了适应所有的操作。
#  	Modify      :   2009-6 文件创建 
#
*************************************************************************/

package com.tencent.fge.foundation.serialize
{
	import com.tencent.fge.foundation.log.client.Log;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	[Event(name="execute", type="com.tencent.QQPet.Serialize.SerializeOperateQueueEvent")]

	public class SerializeOperateQueue extends EventDispatcher
	{
		private var m_arrWaitOperate:Array;
		private var m_arrInOperating:Array;
		
		private var m_timAsyPump:Timer;
		private var m_timSerPump:Timer;
		private var m_nTimeout:int;
		private var m_bRuning:Boolean;

		private var m_bAsyPumpWhenComplete:Boolean = true;
		
		private var log:Log;
		
		
		/**
		 * 用于通过指定一些辅助参数来构造该类的实例。
		 * 
		 * name 是为了给该列队命名，可以取任意值，
		 * 因为一个程序中可能会有多个串行操作要求，取个名字是为了日志输出时便于识别。
		 * 
		 * operate 操作名。给该队列所要串行化的操作取一个名字。其作用同上。
		 * 
		 * timeout 操作等待超时时间。如果一个操作迟迟没有完成，那么不能永远等下去吧。
		 * 如果超时了，则会将超时的操作压入队列尾，下一次再进行操作。
		 * 
		 * serTime 串行的最大时间。类似于timeout，但是该时间到了后，不会将对应操作压入队列尾。
		 * 请尽量设置为一个比较大的值。该参数基本上可以保留。只作当Timeout无效时使用。
		 * 
		 * asyTime 异步时间。上一个操作与下一个操作之间的最小时间时隔。异步化，是为了防止堆栈溢出。
		 * 
		 */
		
		public function SerializeOperateQueue(name:String, operate:String, 
			timeout:int, serTime:Number = Number.MAX_VALUE, asyTime:Number = 130)
		{
			super();
			log = new Log("SerializeOperateQueue["+name+"]["+operate+"]");
			
			m_nTimeout = timeout;
			m_timAsyPump = new Timer(asyTime, 1);
			m_timAsyPump.addEventListener(TimerEvent.TIMER, onAsyPumpTimer);
			m_timSerPump = new Timer(serTime, 1);
			m_timSerPump.addEventListener(TimerEvent.TIMER, onSerPumpTimer);
			
			reset();
		}
		
		
		
		public function reset():void
		{
			log.trace("reset");
			m_arrWaitOperate = new Array;
			m_arrInOperating = new Array;
			m_timAsyPump.stop();
			m_timSerPump.stop();
			m_bRuning = false;
			m_bAsyPumpWhenComplete = true;
		}
		
		public function isRuning():Boolean
		{
			return m_bRuning;
		}
		
		
		
		/**
		 * 向队列之尾压入一个操作
		 * 
		 * target 操作的目标或者对象。
		 * param 操作的参数。
		 * 以上两参数可类比于Window编程里的WParam 和 LParam
		 * tryCount 操作重试次数。用于当超时时，操作重新压入队列的判断依据
		 * 
		 */
		 
		public function pushBack(target:Object, param:Object, tryCount:int = 3):void
		{
			log.trace("pushBack", target, "tryCount:", tryCount, "QueueRuning:", m_bRuning);
			
			if(tryCount > 0)
			{				
				var i:int = getOperateIndexByTarget(this.m_arrWaitOperate, target);
				log.trace("pushBack", "getOperateIndexByTarget, WaitOperate", i);
				
				if(i < 0)
				{
					var op:Operate = new Operate;
					op.target = target;
					op.param = param;
					op.count = tryCount;
					op.initialize(this.m_nTimeout, this.onTimeout);
					m_arrWaitOperate.push(op);
				}
				else
				{
					m_arrWaitOperate[i].count = tryCount;
				}
			}

			
			if(!this.m_bRuning) 
			{
				m_timAsyPump.stop();
				m_timAsyPump.start();
			}
		}
		

		
		private function getOperateIndexByTarget(lstOperate:Array, target:Object):int
		{
			for(var i:int = 0; i < lstOperate.length; ++i)
			{
				var op:Operate = lstOperate[i];
				if(op.target == target)
				{
					return i;
				}
			}
			return -1;
		}
		
		private function getOperateIndex(lstOperate:Array, op:Operate):int
		{
			for(var i:int = 0; i < lstOperate.length; ++i)
			{
				if(op == lstOperate[i])
				{
					return i;
				}
			}
			return -1;
		}
		
		
		
		//外面可以随时取消一个操作，只要知道操作的对象
		public function cancelOperate(target:Object):void
		{
			var i:int = -1;
			var op:Operate;
			
			i = this.getOperateIndexByTarget(m_arrInOperating, target);
			if(i >= 0)
			{
				op = m_arrInOperating[i];

				log.trace("cancelOperate", "InOperating.target", op.target,	"cancel.target", target);
				
				op.finalize();
				m_arrInOperating.splice(i, 1);
				m_timAsyPump.start();
			}
			
			i = this.getOperateIndexByTarget(m_arrWaitOperate, target);
			if(i >= 0)
			{
				op = m_arrWaitOperate[i];
				
				log.trace("cancelOperate", "WaitOperate.target", op.target, "cancel.target", target);
				
				op.finalize();
				m_arrWaitOperate.splice(i, 1);
			}
		}
		
		
		//外面可以告知队列：一个操作已经完成了。好让队列执行下一个操作
		public function completeOperate(target:Object):void
		{
			var i:int = -1;
			var op:Operate;
			
			i = this.getOperateIndexByTarget(m_arrInOperating, target);
			
			if(i >= 0)
			{
				op = m_arrInOperating[i];
				
				log.trace("completeOperate", "InOperating.target", op.target, "complete.target", target);
				
				op.finalize();
				m_arrInOperating.splice(i, 1);
				
				if(m_bAsyPumpWhenComplete)
				{
					m_timAsyPump.start();
				}
				else
				{
					this.pump();
				}

			}
			else
			{
				log.trace("completeOperate", "InOperating 没有该操作：", target);
			}
			
		}
		
		
		//如果外面确认一个操作失败了，那么，也可以告诉队列。好让队列执行下一个操作
		public function turnOverFailOperate(target:Object):void
		{
			var i:int = -1;
			
			i = this.getOperateIndexByTarget(m_arrInOperating, target);
			
			if(i >= 0)
			{
				var op:Operate = this.m_arrInOperating[i];
				
				log.trace("turnOverFailOperate", "InOperating.target", op.target, 
					"Fail.target", target);
					
				
				m_arrInOperating.splice(i, 1);
				
				this.pushBack(op.target, op.param, op.count);
				op.finalize();
				
				m_timAsyPump.start();
			}
			else
			{
				log.trace("turnOverFailOperate", "InOperating 没有该操作：", target);
			}
			
		}
		
		private function turnOverTimeoutOperate(op:Operate):void
		{
			var i:int = -1;
			
			i = this.getOperateIndex(this.m_arrInOperating, op);
			
			if(i >= 0)
			{
				log.trace("turnOverTimeoutOperate", "InOperating.target", op.target);
				
				m_arrInOperating.splice(i, 1);
				this.pushBack(op.target, op.param, op.count);
				op.finalize();
			}
			else
			{
				log.trace("turnOverTimeoutOperate", "InOperating 没有该操作：", op.target);
			}
			
			pump();
		}
		
		private function pump():void
		{
			log.trace("pump", "Runing:", m_bRuning);
						
			var op:Operate = popFront();
			if(op != null)
			{
				m_bRuning = true;
				
				op.start();
				op.count--;
				
				var i:int = this.getOperateIndexByTarget(this.m_arrInOperating, op.target);
				if(i >= 0)
				{
					this.m_arrInOperating[i].count = op.count;
				}
				else
				{
					this.m_arrInOperating.push(op);
				}				
				
				var e:SerializeOperateQueueEvent = new SerializeOperateQueueEvent;
				e.opTarget = op.target;
				e.opParam = op.param;
				
				this.dispatchEvent(e);
				this.m_timSerPump.start();
			}
			else
			{
				log.trace("pump", "Queue已经空了!");
				this.m_bRuning = false;
				this.m_timSerPump.stop();
			}
		}
		
		
		
		private function popFront():Operate
		{
			if(m_arrWaitOperate.length > 0)
			{
				var tmp:Operate = m_arrWaitOperate[0];
				m_arrWaitOperate.splice(0, 1);
				return tmp;
			}
			return null;
		}
		
		private function front():Operate
		{
			if(m_arrWaitOperate.length > 0)
			{
				return m_arrWaitOperate[0];
			}
			return null;
		}
		
		
		private function onTimeout(op:Operate):void
		{
			turnOverTimeoutOperate(op);
		}

		private function onAsyPumpTimer(e:Event):void
		{
			log.trace("onAsyPumpTimer");
			this.pump();
		}
		
		private function onSerPumpTimer(e:Event):void
		{
			log.trace("onSerPumpTimer");
			this.pump();
		}
		
		
		
		//=========================Getter/Setter==========================//
		public function set asyPumpWhenComplete(value:Boolean):void
		{
			this.m_bAsyPumpWhenComplete = value;
		}

		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	
	}
}
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	


class Operate 
{
	public var target:Object;
	public var param:Object;
	public var count:int;
	
	private var m_timer:Timer;
	private var m_nTimeout:int;
	private var m_pTimerProc:Function;
	
	public function initialize(timeout:int, timerProc:Function):void
	{
		this.m_nTimeout = timeout;
		this.m_timer = new Timer(timeout, 1);
		this.m_pTimerProc = timerProc;
		this.m_timer.addEventListener(TimerEvent.TIMER, onTimer);
	}
	
	public function finalize():void
	{
		stop();
		this.m_timer.removeEventListener(TimerEvent.TIMER, onTimer);
		this.m_nTimeout = 0;
		this.m_timer = null;
		this.m_pTimerProc = null;
	}
	
	public function start():void
	{
		this.m_timer.start();
	}
	
	public function stop():void
	{
		this.m_timer.stop();
	}
	
	private function onTimer(e:Event):void
	{
		this.m_pTimerProc(this);
	}
}