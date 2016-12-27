package com.tencent.fge.utils
{
	public class XmlUtil
	{
		public function XmlUtil()
		{
			throw new Error("XmlUtil只能静态使用！");
		}
		
		public static function xml2String(s:String):String
		{
			return s.replace("<", "＜")
				.replace(">", "＞");
		}
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	  		
	}
}

/*		
实体  Description  
&lt;  < (小于)  
&gt;  > (大于)  
&amp;  &（和）  
&quot;  "（双引号）  
&apos;  '（撇号，单引号） 
*/