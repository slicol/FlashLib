package slicol.starling.sdk.fsm
{
	public class FSMValue
	{
		public static const TYPE_Number:String = "Number";
		public static const TYPE_Bool:String = "Bool";
		public static const TYPE_Trigger:String = "Trigger";
		public static const TYPE_String:String = "String";
		
		public var name:String = "";
		public var type:String = "";
		public var value:String = "";
		
		public function FSMValue(name:String = "", type:String = "", value:String = "")
		{
			this.name = name;
			this.type = type;
			this.value = value;
			
			if( this.type != TYPE_Number &&
				this.type != TYPE_Bool &&
				this.type != TYPE_Trigger &&
				this.type != TYPE_String)
			{
				this.type = TYPE_Number;
			}
			
			if(!this.value)
			{
				switch(this.type)
				{
					case TYPE_Number:this.value = "0";break;
					case TYPE_Bool:this.value = "false";break;
					case TYPE_Trigger:this.value = "false";break;
					case TYPE_String:this.value = "null";break;
					default:break;
				}
			}
		}
	}
}