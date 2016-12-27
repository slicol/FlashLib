/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   FSMState.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2009-11
#   Comment     :   一个基于AS3的有限状态机中的状态类。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-11 文件创建 
#
*************************************************************************/


package com.tencent.fge.foundation.fsm
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class FSMState extends EventDispatcher
	{
		protected var m_fsm:FiniteStateMachine;
		protected var m_evtTransition:String;
		
		public function FSMState(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function get name():String
		{
			return "FSMState";
		}
		
		public function enter(fsm:FiniteStateMachine, evt:String, userData:Object):void
		{
			m_fsm = fsm;
			m_evtTransition = evt;
		}
		
		public function leave(fsm:FiniteStateMachine, evt:String, userData:Object):void
		{
			m_fsm = fsm;
			m_evtTransition = evt;
		}
		
	}
}