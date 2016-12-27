package slicol.starling.ps.cfg
{
	import com.tencent.fge.utils.ClassUtil;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import slicol.starling.ps.core.ColorArgb;
	
	import starling.utils.Color;

	public class PSConfig
	{
		public static const TagType_Texture:String = "TagType_Texture";
		public static const TagType_Split:String = "TagType_Split";
		public static const TagType_Enum:String = "TagType_Enum";
		public static const TagType_Value:String = "TagType_Value";
		public static const TagType_Point:String = "TagType_Point";
		public static const TagType_Color:String = "TagType_Color";
		
		private var m_target:Object = null;
		private var m_xml:XML = new XML;
		
		private var m_mapProperty:Dictionary = new Dictionary;
		private var m_firstValidate:Boolean = true;
	
		private var m_type:String = "";
		
		public function PSConfig(target:Object)
		{
			m_target = target;
			m_type = ClassUtil.getName(target);
		}
		
		public function bindTarget(target:Object):void
		{
			m_target = target;
		}
		
		public function setValue(xml:XML):void
		{
			if(!xml)
			{
				throw Error("PSConfig.setValue, 参数为NULL！");
			}
			m_xml = xml;
			m_xml.@id = String(m_xml.@id);
			m_xml.@type = m_type;
			m_xml.@z = int(Number(m_xml.@z));
		}
		
		public function get id():String
		{
			if(m_xml)
			{
				return String(m_xml.@id);
			}
			return "";
		}
		
		public function get type():String
		{
			if(m_xml)
			{
				return String(m_xml.@type);
			}
			return m_type;
		}
		
		public function get z():int
		{
			if(m_xml)
			{
				return Number(m_xml.@z);
			}
			return 0;
		}
		
		public function getValue():XML
		{
			saveAllProperty();
			return m_xml;
		}
				
		
		public function bindProperty(name:String, tag:String = "", attribute:String = "value"):void
		{
			if(!m_mapProperty.hasOwnProperty(name))
			{
				var data:BindData = new BindData;
				data.name = name;
				data.tag = !tag ? name : tag;
				data.attribute = attribute;
				m_mapProperty[name] = data;
			}
		}
		
		public function checkProperty():void
		{
			if(!m_target)
			{
				throw new Error("还未绑定Target，无法检查属性是否合法！");
			}
			
			for each(var data:BindData in m_mapProperty)
			{
				if(!m_target.hasOwnProperty(data.name))
				{
					throw new Error("绑定了一个不存在的属性:" + data.toString());
				}
			}
		}
		
		public function validate():void
		{
			if(m_target && m_xml)
			{
				for each(var data:BindData in m_mapProperty)
				{
					if(m_target.hasOwnProperty(data.name) && m_xml.hasOwnProperty(data.tag))
					{
						var tag:XML = m_xml[data.tag][0];
						var tagType:String = getTagType(tag);
						
						var strValue:String = "";
						
						if(tagType == TagType_Color)
						{
							if(!m_target[data.name])
							{
								m_target[data.name] = new ColorArgb;
							}
							m_target[data.name]["red"] = Number(tag["@red"]);
							m_target[data.name]["green"] = Number(tag["@green"]);
							m_target[data.name]["blue"] = Number(tag["@blue"]);
							m_target[data.name]["alpha"] = Number(tag["@alpha"]);
						}
						else
						{
							if(m_target[data.name] is int || m_target[data.name] is uint || m_target[data.name] is Number)
							{
								strValue = getAttributeValue(tag, data.attribute);
								
								if(m_firstValidate || m_target[data.name] != Number(strValue))
								{
									m_target[data.name] = Number(strValue);
								}
							}
							else if(m_target[data.name] is String)
							{
								strValue = getAttributeValue(tag, data.attribute);
								if(m_firstValidate || m_target[data.name] != strValue)
								{
									m_target[data.name] = strValue;
								}
							}
							else if(m_target[data.name] is Boolean)
							{
								strValue = getAttributeValue(tag, data.attribute);
								if(m_firstValidate || m_target[data.name] != strValue)
								{
 									m_target[data.name] = strValue == "true" || strValue == "True" || strValue == "TRUE" || Number(strValue);
								}
							}
							else if(tagType == TagType_Enum)
							{
								strValue = getAttributeValue(tag, data.attribute);
								if(m_firstValidate || m_target[data.name] != strValue)
								{
									m_target[data.name] = strValue;
								}
							}
							else
							{
								throw new Error("有未处理的属性：" + data.toString());
							}
						}
					}
					else
					{
						throw new Error("有未处理的属性：" + data.toString());
					}
				}
				
				m_target["z"] = z;
				
				m_firstValidate = false;
			}
			
			function getAttributeValue(tag:XML, attributeName:String):String
			{
				return attributeName ? String(tag["@"+attributeName]) : String(tag);
			}
			
			function defineof(propertyName:String, clazz:Class):Boolean
			{
				var old:* = m_target[propertyName];
				try
				{
					m_target[propertyName] = new clazz;
				}
				catch(e:Error)
				{
					m_target[propertyName] = old;
					return false;
				}
				
				m_target[propertyName] = old;
				return true;
			}
		}
		
		public static function getTagType(tag:XML):String
		{
			if(tag.name() == "texture")
			{
				return TagType_Texture;
			}
			else if(tag.name() == "split")
			{
				return TagType_Split;
			}
			else if(tag.hasOwnProperty("@enum"))
			{
				return TagType_Enum;
			}
			else if(tag.hasOwnProperty("@value"))
			{
				return TagType_Value;
			}
			else if(tag.hasOwnProperty("@x") && tag.hasOwnProperty("@y"))
			{
				return TagType_Point;
			}
			else if(tag.hasOwnProperty("@red") && tag.hasOwnProperty("@green") 
				&& tag.hasOwnProperty("@blue") && tag.hasOwnProperty("@alpha"))
			{
				return TagType_Color;
			}
			
			return null;
		}
		
		private function saveAllProperty():void
		{
			for each(var data:BindData in m_mapProperty)
			{
				saveProperty(data.name);
			}
		}
		
		public function saveProperty(name:String):void
		{
			var data:BindData = m_mapProperty[name];
			if(data && m_target && m_xml)
			{
				if(!m_xml.hasOwnProperty(data.tag))
				{
					m_xml[data.tag] = new XML;
				}
				
				if(m_target[data.name] is ColorArgb)
				{
					m_xml[data.tag]["@red"] = String(m_target[data.name]["red"]);
					m_xml[data.tag]["@green"] = String(m_target[data.name]["green"]);
					m_xml[data.tag]["@blue"] = String(m_target[data.name]["blue"]);
					m_xml[data.tag]["@alpha"] = String(m_target[data.name]["alpha"]);
				}
				else
				{
					if(data.attribute)
					{
						m_xml[data.tag]["@"+data.attribute] = String(m_target[data.name]);
					}
					else
					{
						m_xml[data.tag] = String(m_target[data.name]);
					}
				}
			}
		}
	}
}

class BindData
{
	public var name:String = "";
	public var tag:String = "";
	public var attribute:String = "";
	
	public function toString():String
	{
		return name + "<->" + tag + ".@" + attribute;
	}
}