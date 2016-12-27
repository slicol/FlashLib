package slicol.starling.sdk.fsm
{
	import com.tencent.fge.foundation.signals.Signal;
	
	import flash.utils.Dictionary;

	public class FSM
	{
	
		private var m_stateSN:int = 0;
		
		public var onLoadUrlComplete:Signal = new Signal(FSM);
		public var onLoadUrlError:Signal = new Signal(String, String);
		
		private var m_xml:XML = new XML;
		private var m_stateClass:Class;
		private var m_customStateParam:*;
		
		private var m_mapStates:Dictionary = new Dictionary;
		private var m_parameters:FSMValueList = new FSMValueList(<ParamList/>);
		
		private var m_current:FSMState;
		private var m_default:FSMState;
		private var m_anystate:FSMState;

		
		public static var isEditMode:Boolean = false;
		
		
		
		public function FSM(stateClass:Class, xml:XML = null, customStateParam:* = null)
		{
			m_stateClass = stateClass;
			m_customStateParam = customStateParam;
			
			loadXml(xml);
		}
		
		
		
		
		public function loadUrl(url:String):void
		{
			var ldr:FSMLoader = new FSMLoader;
			ldr.onComplete.addOnce(onFSMLoader);
			ldr.onError = this.onLoadUrlError;
			ldr.load(url);
			
			function onFSMLoader(ldr:FSMLoader):void
			{
				loadXml(ldr.content);
				this.onLoadUrlComplete.dispatch(this);
			}
		}
		
		public function loadXml(xml:XML):void
		{
			if(xml)
			{
				removeAll();
				
				m_xml = xml;

				m_parameters.loadXml(m_xml.ParamList[0]);
				
				var xlStates:XMLList = xml..State;
				for(var i:int = 0; i < xlStates.length(); ++i)
				{
					var xmlState:XML = xlStates[i];
					var state:FSMState = new m_stateClass(this, xmlState, m_customStateParam);
					m_mapStates[state.name] = state;
				}
			}
			else
			{
				m_xml = <FSM default=''/>;
			}
			
			
			m_default = getState(m_xml["@default"]);
			m_current = m_default;
			
			m_anystate = getState("AnyState");
			if(!m_anystate)
			{
				m_anystate = addState(<State name='AnyState'/>);
			}
			
			if(!m_parameters.hasValue(FSMCondition.ExitTime))
			{
				m_parameters.addValue(FSMValue.TYPE_Number, "0", FSMCondition.ExitTime);
			}
			
			if(m_current)
			{
				m_current.enter();
			}
		}
		
		
		public function removeAll():void
		{			
			m_current = null;
			m_default = null;
			
			for each(var state:FSMState in m_mapStates)
			{
				state.dispose();
			}
			m_mapStates = new Dictionary;
		}
		

		public function get validXML():XML
		{
			m_xml = <FSM default=''/>;
			
			if(m_default)
			{
				m_xml["@default"] = m_default.name;
			}
			
			m_xml.appendChild(m_parameters.validXML);
			
			for each(var state:FSMState in m_mapStates)
			{
				m_xml.appendChild(state.validXML);
			}
			
			return m_xml;
		}
		
		public function get parameters():FSMValueList
		{
			return m_parameters;
		}
		
		public function get anystate():FSMState
		{
			return m_anystate;
		}

		[Editor]
		public function addState(xmlState:XML = null):FSMState
		{
			var state:FSMState = new m_stateClass(this, xmlState, m_customStateParam);
			if(!m_mapStates.hasOwnProperty(state.name))
			{
				m_mapStates[state.name] = state;
			}
			return state;
		}
		
		
		[Editor]
		public function removeState(name:String):void
		{
			if(m_mapStates.hasOwnProperty(name))
			{
				var state:FSMState = m_mapStates[name];
				
				if(m_current == state)
				{
					m_current = null;
				}
				
				if(m_default == state)
				{
					m_default = null;
				}
				
				delete m_mapStates[name];
				state.dispose();
			}
		}
		
		[Editor]
		public function getState(name:String):FSMState
		{
			return m_mapStates[name];
		}
		
		public function rename(data:FSMState):Boolean
		{
			var oldName:String = "";
			var newName:String = data.name;
			
			for(var name:String in m_mapStates)
			{
				if(m_mapStates[name] == data)
				{
					oldName = name;
					break;
				}
			}
			
			if(!oldName)
			{
				return false;
			}
			
			if(!m_mapStates.hasOwnProperty(newName))
			{
				delete m_mapStates[oldName];
				m_mapStates[newName] = data;
				
				for each(data in m_mapStates)
				{
					data.renameTransition(oldName, newName);
				}
				
				return true;
			}
			else
			{
				data.name = oldName;
				return false;
			}
		}
		
		
		public function getDefaultState():FSMState
		{
			return m_default;
		}
		
		public function setDefaultState(name:String):FSMState
		{
			m_default = getState(name);
			return m_default;
		}
		
		
		[Editor]
		public function getStateList():Vector.<FSMState>
		{
			var list:Vector.<FSMState> = new Vector.<FSMState>;
			for each(var state:FSMState in m_mapStates)
			{
				list.push(state);
			}
			return list;
		}
		
		[Editor]
		public function addTransition(from:String, to:String):FSMTransition
		{
			var state:FSMState = m_mapStates[from];
			if(state)
			{
				return state.addTransition(to);
			}
			return null;
		}
		
		[Editor]
		public function removeTransition(trans:FSMTransition):void
		{
			var state:FSMState = m_mapStates[trans.from];
			if(state)
			{
				return state.removeTransition(trans);
			}
		}
		
		
		//------------------------------------------------------------------------------
		public function setCurrentState(name:String = ""):void
		{
			var next:FSMState = getState(name);
			if(next)
			{
				if(m_current && m_current != next)
				{
					m_current.leave();
				}
			}
			
			m_current = next;
			if(m_current)
			{
				m_current.enter();
			}
		}
		
		public function setParam(name:String, value:*):void
		{
			m_parameters.setValue(name, String(value));
		}
		
		public function getParam(name:String):*
		{
			return m_parameters.getValue(name);
		}
		
		public function update():void
		{
			var next:FSMState;
			
			if(!m_current)
			{
				next = m_anystate.getNextState(m_parameters);
				m_current = next?next : m_default;
				
				if(m_current)
				{
					m_current.enter();
				}
			}
			else
			{
				m_current.update();
				m_parameters.setValue(FSMCondition.ExitTime, m_current.progress.toString());
				
				next = m_anystate.getNextState(m_parameters);
				next = next || m_current.getNextState(m_parameters);
				if(next && next != m_current)
				{
					m_current.leave();
					
					m_current = next;
					m_current.enter();
				}
			}
		}
		
		
		//------------------------------------------------------------------------------
		
		public function getNewStateName():String
		{
			++m_stateSN;
			var name:String = "New State " + m_stateSN;
			while(getState(name))
			{
				++m_stateSN;
				name = "New State " + m_stateSN;
			}
			return name;
		}
		
	}
}