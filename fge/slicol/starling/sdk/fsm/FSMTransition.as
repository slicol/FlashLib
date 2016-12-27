package slicol.starling.sdk.fsm
{
	public class FSMTransition
	{
		private var m_xml:XML;
		private var m_from:String = "";
		private var m_to:String = "";
		
		private var m_listConditions:Vector.<FSMCondition> = new Vector.<FSMCondition>;
		
		public function FSMTransition(from:String, to:String, xml:XML = null)
		{
			m_from = from;
			m_to = to;
			m_xml = xml;
			
			if(xml)
			{
				m_to = xml.@to;
				
				var xlCond:XMLList = xml.children();
				for(var i:int = 0; i < xlCond.length(); ++i)
				{
					var xmlCond:XML = xlCond[i];
					addCondition(xmlCond.@name, xmlCond.@value, xmlCond.@op);
				}
			}
			else
			{
				m_xml = <Transition to=''/>;
				m_xml.@to = to;
			}
			
		}
		
		public function get name():String{return m_from + ">" + m_to;}
		public function get from():String{return m_from;}
		public function get to():String{return m_to;}
		public function set to(v:String):void{m_to = v;}
		public function get listConditions():Vector.<FSMCondition>{return m_listConditions;}
		
		public function get validXML():XML
		{
			m_xml = <Transition to=''/>;
			m_xml.@to = m_to;
		
			for each(var cond:FSMCondition in m_listConditions)
			{
				m_xml.appendChild(cond.validXML);
			}
			
			return m_xml;
		}
		
		public function dispose():void
		{
			for each(var cond:FSMCondition in m_listConditions)
			{
				cond.dispose();
			}
			m_listConditions.length = 0;
		}
		

		
		public function addCondition(name:String, value:String, op:String):FSMCondition
		{
			var cond:FSMCondition = new FSMCondition();
			cond.name = name;
			cond.value = value;
			cond.op = op;
			m_listConditions.push(cond);
			return cond;
		}
		
		public function removeCondition(cond:FSMCondition):void
		{
			var i:int = m_listConditions.indexOf(cond);
			if(i >= 0)
			{
				m_listConditions.splice(i,1);
			}
		}
		
		public function checkCondition(params:FSMValueList):Boolean
		{
			var ret:Boolean = true;
			
			for(var i:int = 0; i < m_listConditions.length; ++i)
			{
				var cond:FSMCondition = m_listConditions[i];
				if(!cond.check(params))
				{
					ret = false;
					break;
				}
			}
			
			return ret;
		}
	}
}