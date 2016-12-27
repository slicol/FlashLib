/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   FiniteStateMachine.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2009-11
#   Comment     :   一个基于AS3的有限状态机的实现。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-11 文件创建 
#
*************************************************************************/

package com.tencent.fge.foundation.fsm
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;

	public class FiniteStateMachine extends EventDispatcher
	{
		private var m_mapName2State:Dictionary = new Dictionary(true);
		private var m_mapState:MapState = new MapState;
		private var m_curState:FSMState;
		private var m_startState:FSMState;
		
		public function FiniteStateMachine(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function parseStateTable(table:XML):Boolean
		{
			
			return true;
		}
		
		public function startup():void
		{
			this.setState(m_startState, null, null);
		}

		public function hasState(state:FSMState):Boolean
		{
    		return m_mapState.hasKey(state);
		}
		
		public function addState(state:FSMState):void //增加状态
    	{
			if(!this.hasState(state))
			{
				this.m_mapState[state] = new Event_State_Table();
				this.m_mapName2State[state.name] = state;
			}
    	}
    	
    	public function getState(name:String):FSMState
    	{
    		return m_mapName2State[name];
    	}
    	
	    public function setState(dest:FSMState, evt:String, userData:Object = null):void //设置当前状态
	    {
	    	if(!this.hasState(dest))
	    	{
	    		//错误处理
	    		return;
	    	}
	    	
	    	if(m_curState)
	    	{
	    		m_curState.leave(this, evt, userData);
	    	}
			m_curState = dest;//设置为当前状态
			m_curState.enter(this, evt, userData);
		}
		
		public function currentState():FSMState
		{
			return m_curState;
		}
		
		public function numStates():int
		{
			return this.m_mapState.size();
		}
		
		public function clearStates():void
		{
			m_curState = new FSMState;
			m_mapState = new MapState;
		}
		
		public function addTransition(src:FSMState, evt:String, dest:FSMState):void //增加src状态的事件状态跃迁记录
	    {
			if (src == dest)//源状态与目标状态相同,无意义
			{
				//错误处理
				return;
			}
	       
			if(!this.hasState(src))//找不到源状态
			{
				//错误处理
				return;
			}
	       
			if(!this.hasState(dest))//目标状态不在状态映射表中,不合法
	       	{
				//错误处理
				return;
	       	}
	       
	       var est:Event_State_Table = m_mapState[src];
	       var evt2state:MapEvent2State = est.transitions;
	       evt2state[evt] = dest;//增加跃迁记录
	    }
		
		public function numTransitions(src:FSMState):int//返回某状态的跃迁记录数
		{
			var est:Event_State_Table = m_mapState[src];
			if(est)
			{
				return est.size();
			}
			return 0;
		}
		
		public function processEvent(evt:String, userData:Object = null):void
		{
			var est:Event_State_Table = m_mapState[m_curState];
			if(est == null)//源状态不存在
			{
				//错误处理
				return;
			}
			
			var evt2state:MapEvent2State = est.transitions;
			var dest:FSMState = evt2state[evt];
			if(dest == null)//触发事件不存在
			{
				//错误处理
				return;
			}
			
			m_curState.leave(this, evt, userData);//退出旧状态的函数调用
			m_curState = dest;//新状态为当前状态
			m_curState.enter(this, evt, userData);//进入新状态的函数调用
		}

		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	
	}
}

import flash.utils.Dictionary;

//此结构体,用于保存每一种状态的事件状态跃迁映射表,以及用户自定义数据
class Event_State_Table
{
	public var transitions:MapEvent2State = new MapEvent2State;
	public var userData:Object;
	
	public function size():int
	{
		var i:int = 0;
		for each(var key:Object in transitions)
		{
			++i;
		}
		return i;
	}
	
	public function hasKey(key:*):Boolean
	{
		var tmp:* = transitions[key];
		return tmp != null;
	}	
}

dynamic class MapEvent2State extends Dictionary
{
	public var value:Dictionary;
	public function MapEvent2State(weakKeys:Boolean=false)
	{
		super(weakKeys);
		//value = new Dictionary(weakKeys);
		value = this;
	}
		
	//对每一种状态而言,都对应这样的一个事件状态跃迁映射表
    //typedef std::map<event_type,state_type> event_state_map;
    public function hasKey(key:*):Boolean
	{
		var tmp:* = value[key];
		return tmp != null;
	}	
}

dynamic class MapState extends Dictionary
{
	public var value:Dictionary;
	public function MapState(weakKeys:Boolean=false)
	{
		super(weakKeys);
		//value = new Dictionary(weakKeys);
		value = this;
	}
	
	public function size():int
	{
		var i:int = 0;
		for each(var key:Object in value)
		{
			++i;
		}
		return i;
	}
	
	public function hasKey(key:*):Boolean
	{
		var tmp:* = value[key];
		return tmp != null;
	}	
}