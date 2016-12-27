package com.tencent.fge.foundation.sdt.DataType
{
	import com.tencent.fge.foundation.sdt.Common.SDTBase;
	
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.getQualifiedClassName;

	dynamic public class SDTObject extends Proxy
	{
		protected var m_dynamic: Boolean;
		protected var m_sdtValues: Dictionary;
		protected var m_otherValues: Dictionary;
		
		public function SDTObject(dynamic: Boolean = false)
		{
			m_dynamic = dynamic;
			
			if (dynamic)
			{
				m_sdtValues = new Dictionary();
				m_otherValues = new Dictionary();
			}
		}
		
		private function setValue(property: String, value: *): void
		{
			if (m_sdtValues.hasOwnProperty(property))
			{
				m_sdtValues[property].value = value;
			}
			else if (m_otherValues.hasOwnProperty(property))
			{
				m_otherValues[property] = value;
			}
			else
			{
				var sdtValue: SDTBase = null;
				if (value is Boolean)
				{
					sdtValue = new SDTBoolean(value);
				}
				else if (value is int)
				{
					sdtValue = new SDTInt(value);
				}
				else if (value is uint)
				{
					sdtValue = new SDTUInt(value);
				}
				else if (value is Number)
				{
					sdtValue = new SDTNumber(value);
				}
				else if (value is String)
				{
					sdtValue = new SDTString(value);
				}
				else if (value is Date)
				{
					sdtValue = new SDTDate(value);
				}
				
				if (sdtValue)
				{
					m_sdtValues[property] = sdtValue;
				}
				else
				{
					if (getQualifiedClassName(value) == "Object")
					{
						var sdtObject: SDTObject = new SDTObject(true);
						for (var i: String in value)
						{
							sdtObject[i] = value[i];
						}
						m_otherValues[property] = sdtObject;
					}
					else
					{
						m_otherValues[property] = value;
					}
				}
			}
		}
		
		private function checkDynamic(property: String): Boolean
		{
			if (!m_dynamic)
			{
				throw new ReferenceError("在 " + getQualifiedClassName(this) + " 上找不到属性" + property + "，且没有默认值", 1069);
			}
			return m_dynamic;
		}
		
		flash_proxy override function setProperty(name:*, value:*):void
		{
			var property: String = name;
			if (checkDynamic(property))
			{
				setValue(property, value);
			}
		}
		
		flash_proxy override function getProperty(name:*):*
		{
			var property: String = name;
			if (checkDynamic(property))
			{
				if (m_sdtValues.hasOwnProperty(property))
				{
					return m_sdtValues[property].value;
				}
				else if (m_otherValues.hasOwnProperty(property))
				{
					return m_otherValues[property];
				}
			}
			return undefined;
		}
		
		flash_proxy override function hasProperty(name:*):Boolean
		{
			var property: String = name;
			return m_sdtValues && m_sdtValues.hasOwnProperty(property) || 
				m_otherValues && m_otherValues.hasOwnProperty(property);
		}
		
		flash_proxy override function deleteProperty(name:*):Boolean
		{
			var property: String = name;
			if (m_sdtValues && m_sdtValues.hasOwnProperty(property))
			{
				deleteSdtProperty(property);
				return true;
			}
			else if (m_otherValues && m_otherValues.hasOwnProperty(property))
			{
				deleteOtherProperty(property);
				return true;
			}
			return false;
		}
		
		private function deleteSdtProperty(property: String): void
		{
			SDTBase(m_sdtValues[property]).dispose();
			m_sdtValues[property] = null;
			delete m_sdtValues[property];
		}
		
		private function deleteOtherProperty(property: String): void
		{
			var sdtObject: SDTObject = m_otherValues[property] as SDTObject;
			if (sdtObject)
			{
				sdtObject.dispose();
			}
			
			m_otherValues[property] = null;
			delete m_otherValues[property];
		}
		
		public function dispose(): void
		{
			var properties: Array = [];
			
			// clear all sdt properties
			getProperties(m_sdtValues, properties);
			for each (var property: String in properties)
			{
				deleteSdtProperty(property);
			}
			properties.length = 0;
			
			// clear all other properties
			getProperties(m_otherValues, properties);
			for each (property in properties)
			{
				deleteOtherProperty(property);
			}
			properties.length = 0;
		}
		
		private static function getProperties(object: Object, properties: Array): void
		{
			if (properties)
			{
				for (var property: * in object)
				{
					properties.push(property);
				}
			}
		}
	}
}