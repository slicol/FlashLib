package com.tencent.fge.framework.resmanager
{
	import com.tencent.fge.framework.resmanager.data.ResData;
	import com.tencent.fge.utils.PathUtil;
	
	import flash.utils.ByteArray;
	
	public class ResUtil
	{
		public static function resXml2Data(cfgRes:Object, xmlRes:XMLList, dir:String):int
		{
			if(!cfgRes.hasOwnProperty("list"))
			{
				throw Error("ResUtil.resXml2Data() 函数参数格式错误！cfgRes缺少list属性！");
			}
			
			var xmlResList:XMLList = xmlRes.children();
			for(var j:int = 0; j < xmlResList.length(); ++j)
			{
				var xmlResData:XML = xmlResList[j];
				var rd:ResData = new ResData;
				rd.id = xmlResData.@id;
				rd.path = xmlResData.@path;
				rd.type = xmlResData.@type;
				rd.ver = xmlResData.@ver;
				
				if(rd.path != null && rd.path.length > 0)
				{
					rd.path = PathUtil.makePath(dir, rd.path, true);
					cfgRes.list[rd.id] = rd;
					if(cfgRes.hasOwnProperty(rd.id) == true)
					{
						cfgRes[rd.id] = rd.path;
					}
				}
			}
			
			return j;
		}
		

	}
}