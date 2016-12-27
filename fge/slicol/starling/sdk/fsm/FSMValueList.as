package slicol.starling.sdk.fsm
{
	import flash.utils.Dictionary;
	
	dynamic public class FSMValueList extends Dictionary
	{
		private var m_tag:XML = <ValueList/>;
		private var m_xml:XML;
		
		public function FSMValueList(xmlTag:XML)
		{
			super(false);
			m_tag = xmlTag;
			m_xml = new XML(m_tag);
		}
		
		public function loadXml(xml:XML):void
		{
			m_xml = xml;
			if(!m_xml)
			{
				m_xml = new XML(m_tag);
			}
			
			var xlItems:XMLList = m_xml..Item;
			for each(var xmlItem:XML in xlItems)
			{
				var item:FSMValue = new FSMValue;
				item.name = xmlItem.@name;
				item.type = xmlItem.@type;
				item.value = xmlItem.@value;
				
				this[item.name] = item;
			}
		}
		
		public function getType(name:String):String
		{
			if(this.hasOwnProperty(name))
			{
				var item:FSMValue = this[name];
				return item.type;
			}
			return FSMValue.TYPE_String;
		}
		
		public function rename(data:FSMValue):Boolean
		{
			var pThis:Dictionary = this;
			var oldName:String = "";
			for(var key:* in pThis)
			{
				if(pThis[key] == data)
				{
					oldName = key;
					break;
				}
			}
			
			if(!oldName)
			{
				return false;
			}
			
			if(!pThis.hasOwnProperty(data.name))
			{
				delete pThis[oldName];
				pThis[data.name] = data;
				return true;
			}
			else
			{
				data.name = oldName;
				return false;
			}
		}
		
		public function hasValue(name:String):Boolean
		{
			return this.hasOwnProperty(name);
		}
		
		public function getValue(name:String):String
		{
			var pThis:Dictionary = this;
			var item:FSMValue = pThis[name];
			if(item)
			{
				return item.value;
			}
			return null;
		}
		
		public function checkValue(name:String, type:String, defaultValue:String = ""):void
		{
			if(name && !this.hasOwnProperty(name))
			{
				addValue(type, defaultValue, name);
			}
		}
		
		public function setValue(name:String, value:String, autoAddAndType:String = ""):void
		{
			var pThis:Dictionary = this;
			var item:FSMValue = pThis[name];
			if(item)
			{
				item.value = value;
			}
			else
			{
				if(autoAddAndType)
				{
					item = new FSMValue(name, autoAddAndType, value);
					pThis[name] = item;
				}
			}
			
			
		}
		
		public function addValue(type:String, value:String = "", name:String = ""):FSMValue
		{
			if(!name || this.hasOwnProperty(name))
			{
				name = getNoUseName();
			}
			
			var item:FSMValue = new FSMValue(name,type,value);	
			var pThis:Dictionary = this;
			pThis[item.name] = item;
			return item;
		}
		
		public function removeValue(name:String):void
		{
			if(this.hasOwnProperty(name))
			{
				delete this[name];
			}
		}
		
		
		public function getNoUseName():String
		{
			var i:int = 0;
			var name:String = "Param #" + i;
			while(this.hasOwnProperty(name))
			{
				++i;
				name = "Param #" + i;
			}
			return name;
		}
		
		public function get validXML():XML
		{
			m_xml = new XML(m_tag);
			
			for(var name:String in this)
			{
				var item:FSMValue = this[name];
				var xmlItem:XML = <Item/>;
				xmlItem.@name = name;
				xmlItem.@type = item.type;
				xmlItem.@value = item.value;
				
				m_xml.appendChild(xmlItem);
			}
			
			return m_xml;
		}
	}
}