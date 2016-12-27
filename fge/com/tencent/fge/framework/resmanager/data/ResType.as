package com.tencent.fge.framework.resmanager.data
{
	public class ResType
	{
		public static const NULL:String = "";
		public static const BYTE:String = "byte"
		public static const TEXT:String = "text";
		public static const FLASH:String = "flash";
		public static const IMAGE:String = "image";
		public static const SOUND:String = "sound";
		public static const FONT:String = "font";
		public static const PLUGIN:String = "plugin";
		public static const PACK:String = "pack";
		
		
		public static function getTypeFromPath(path:String):String
		{
			var i:int = path.indexOf("?");
			if(i > 0)
			{
				path = path.substr(0,i);
			}
			
			i = path.lastIndexOf(".");
			var ext:String = "";
			if(i > 0 && (i + 1) < path.length) 
			{
				if( path.substr(i - 1) != "\\" ||
					path.substr(i - 1) != "/")
				{
					ext = path.substr(i + 1);
					ext = ext.toLowerCase();					
				}
			}
			switch(ext)
			{
				case "swf":
					return ResType.FLASH;
					break;
				case "png":
				case "jpg":
				case "jpeg":
					return ResType.IMAGE;
					break;
				case "xml":
				case "txt":
				case "ini":
					return ResType.TEXT;
					break;
				case "mp3":
					return ResType.SOUND;
					break;
				case "font":
					return ResType.FONT;
					break;
				case "plg":
					return ResType.PLUGIN;
					break;
				case "pack":
					return ResType.PACK;
					break;
				default:
					return ResType.BYTE;
			}
		}

	}
}