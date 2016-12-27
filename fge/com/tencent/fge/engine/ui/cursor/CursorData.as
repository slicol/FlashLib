package com.tencent.fge.engine.ui.cursor
{
	public class CursorData
	{
		public static const NORMAL:int = 0;
		public static const HAND:int = 10001;
		public static const INPUT:int = 10002;
		
		public var id:int;
		public var normal:String = "";
		public var press:String = "";
		
		public function fromXml(xml:XML, baseurl:String = ""):void
		{
			id = Number(xml.@id);
			normal = baseurl + xml.@normal;
			press = baseurl + xml.@press;
		}
	}
}

/*
<?xml version="1.0" encoding="utf-8"?>
<config>
	<cursor id="1" normal=""  press="">默认</cursor>
</config>
*/