package slicol.starling.sdk.fsm
{
	public class FSMCondition
	{
		public static const ExitTime:String = "ExitTime";
		public static const OP_Greater:String = "greater";
		public static const OP_Less:String = "less";
		public static const OP_Equal:String = "equal";
		
		public var name:String = "";
		public var value:String = "";
		public var op:String;
		
		public function FSMCondition()
		{
		}
		
		public function dispose():void
		{
			
		}
		
		public function get validXML():XML
		{
			var xml:XML = <Condition/>;
			xml.@name = name;
			xml.@value = value;
			xml.@op = op;
			return xml;
		}
		
		
		public function check(params:FSMValueList):Boolean
		{
			var param:FSMValue = params[name];
			if(param)
			{
				switch(param.type)
				{
					case FSMValue.TYPE_Bool:		return (value == param.value);
						
					case FSMValue.TYPE_Number:
						
						switch(op)
						{
							case OP_Greater: 	return (Number(value) < Number(param.value));
							case OP_Less:		return (Number(value) > Number(param.value));
							default:			return (Number(value) == Number(param.value));
						}
						
					case FSMValue.TYPE_Trigger:	
						
						if(param.value == "true")
						{
							param.value = "false";
							return true;
						}
						return false;
						
					case FSMValue.TYPE_String:
						return value == param.value;
				}
			}
			
			return false;
		}
	}
}