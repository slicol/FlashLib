package slicol.starling.sdk.fsm
{
	import com.tencent.fge.foundation.signals.Signal;
	
	import flash.utils.Dictionary;

	public class FSMState
	{
		private var m_name:String = "";
		protected var m_progress:Number = 0;
		
		private var m_propertys:FSMValueList = new FSMValueList(<PropertyList/>);

		private var m_xml:XML;
		private var m_fsm:FSM;
		private var m_listTransitions:Vector.<FSMTransition> = new Vector.<FSMTransition>;
		
		/**
		 * 状态事件，参数格式：(type:String, args:Object)
		 * @param Type, 事件类型
		 * @param Args, 事件参数
		 **/
		public var onStateEvent:Signal = new Signal(String, Object);
		
		public function FSMState(fsm:FSM, xml:XML = null, customParam:* = null)
		{
			m_fsm = fsm;
			m_xml = xml;
			
			if(m_xml)
			{
				m_name = m_xml.@name;
				
				m_propertys.loadXml(xml.PropertyList[0]);
				
				var xlTrans:XMLList = m_xml..Transition;
				for(var i:int = 0; i < xlTrans.length(); ++i)
				{
					var xmlTran:XML = xlTrans[i];
					var trans:FSMTransition = new FSMTransition(m_name, "", xmlTran);
					m_listTransitions.push(trans);
				}
			}
			else
			{
				m_name = fsm.getNewStateName();
				m_xml = <State name=''/>;
				m_xml.@name = m_name;
			}
		}
		

		public function set name(v:String):void{m_name = v;}
		public function get name():String{return m_name;}		
		public function get listTransitions():Vector.<FSMTransition>{return m_listTransitions;}
		public function get progress():Number{return m_progress;}
		public function get propertys():FSMValueList{return m_propertys;}
		public function get xml():XML{return m_xml;}
		
		
		
		public function get validXML():XML
		{
			m_xml = <State name=''/>;
			m_xml.@name = m_name;
			
			m_xml.appendChild(m_propertys.validXML);

			for each(var trans:FSMTransition in m_listTransitions)
			{
				if(m_fsm.getState(trans.to))
				{
					m_xml.appendChild(trans.validXML);
				}
			}
			
			return m_xml;
		}
			
		
		public function dispose():void
		{
			onStateEvent.removeAll();
			for each(var trans:FSMTransition in m_listTransitions)
			{
				trans.dispose();
			}
			m_listTransitions.length = 0;
		}
		
		internal function renameTransition(oldTo:String, newTo:String):void
		{
			for each(var trans:FSMTransition in m_listTransitions)
			{
				if(trans.to == oldTo)
				{
					trans.to = newTo;
				}
			}
		}
		
		[Editor]
		public function addTransition(to:String):FSMTransition
		{
			var trans:FSMTransition;
			
			if(m_fsm.getState(to))
			{
				trans = new FSMTransition(m_name, to, null);
				m_listTransitions.push(trans);
			}
			
			return trans;
		}
		
		[Editor]
		public function removeTransition(trans:FSMTransition):void
		{
			var i:int = m_listTransitions.indexOf(trans);
			if(i >= 0)
			{
				m_listTransitions.splice(i,1);
				trans.dispose();
			}
		}
		
		
		public function getNextState(params:FSMValueList):FSMState
		{
			for(var i:int = 0; i < m_listTransitions.length; ++i)
			{
				var trans:FSMTransition = m_listTransitions[i];
				if(trans.checkCondition(params))
				{
					var next:FSMState = m_fsm.getState(trans.to);
					if(next)
					{
						return next;
					}
					else
					{
						if(FSM.isEditMode)
						{
							removeTransition(trans);
						}
					}
				}
			}
			return null;
		}
		
		
		public function leave():void
		{
			
		}
		
		public function enter():void
		{
			m_progress = 0;
		}
		
		public function update():void
		{
			m_progress += 0.1;
			if(m_progress >= 1)
			{
				m_progress = 0;
			}
		}
		
	}
}