package com.tencent.fge.utils
{
	import com.tencent.fge.utils.AttrData;
	import com.tencent.fge.utils.PathUtil;
	
	public class AttrUtil
	{
		public static function attrXml2Data(cfgAttr:Object, xmlAttr:XMLList):int
		{
			var xmlAttrList:XMLList = xmlAttr.children();
			for(var j:int = 0; j < xmlAttrList.length(); ++j)
			{
				var xmlAttrData:XML = xmlAttrList[j];
				var rd:AttrData = new AttrData;
				rd.id = xmlAttrData.@id;
				rd.value = xmlAttrData.@value;
				rd.type = xmlAttrData.@type;
				
				if(rd.value != null && rd.value.length > 0)
				{
					if(cfgAttr.hasOwnProperty(rd.id) == true)
					{
						cfgAttr[rd.id] = rd.value;
					}
				}
			}
			
			return j;
		}
		
	}
}