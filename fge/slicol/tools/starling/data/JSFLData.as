package slicol.tools.starling.data
{
	import flash.utils.describeType;

	public class JSFLData
	{
		private var m_serialize:String = "";
		
		public function JSFLData()
		{
		}
		
		public function set value(v:JSFLData):void
		{
			var xml:XML = describeType(this);
			
			var xlAccessor:XMLList = xml..accessor;
			for(var i:int = 0; i < xlAccessor.length(); ++i)
			{
				var xmlAccessor:XML = xlAccessor[i];
				var pname:String = xmlAccessor.@name;
				var paccess:String = xmlAccessor.@access;
				if(paccess == "readwrite" && pname != "serialize")
				{
					this[pname] = v[pname];
				}
			}
			
	
		}
		
		public function get serialize():String
		{
			return m_serialize;
		}
		
		public function set serialize(v:String):void
		{
			m_serialize = v;
			if(!m_serialize)
			{
				return;
			}
			
			if(m_serialize.substr(0,1) == "{")
			{
				m_serialize = m_serialize.substr(1);
			}
			
			if(m_serialize.substr(m_serialize.length - 1,1) == "}")
			{
				m_serialize = m_serialize.substr(0, m_serialize.length - 1);
			}
			
			var args:Array = m_serialize.split(",");
			
			for(var i:int = 0; i < args.length; ++i)
			{
				var property:Array = args[i].split(":");
				
				if(this[property[0]] is Number || this[property[0]] is int || this[property[0]] is uint)
				{
					this[property[0]] = Number(property[1]);
				}
				else if(this[property[0]] is Boolean)
				{
					this[property[0]] = Boolean(property[1]);
				}
				else
				{
					this[property[0]] = property[1];
				}
			}
		}
	}
}