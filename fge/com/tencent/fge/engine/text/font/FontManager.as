package com.tencent.fge.engine.text.font
{
	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	public class FontManager
	{
		private static var ms_mapFontName:Dictionary = new Dictionary;
		
		public function FontManager()
		{
		}
		
		public static function hasFont(fontName:String, enumerateDeviceFonts:Boolean=false):Boolean
		{
			var i:int = 0;
			var lst:Array = Font.enumerateFonts(enumerateDeviceFonts);
			for(i = 0; i < lst.length; ++i)
			{
				if(lst[i].fontName == fontName)
				{
					break;
				}
			}
			
			return i < lst.length;
		}
		
		public static function setFont(tf:TextField, fontName:String):void
		{
			var myName:String = ms_mapFontName[fontName];
			var embedFonts:Boolean = true;
			
			if(myName == null)
			{
				if(hasFont(fontName))
				{
					myName = fontName;
					ms_mapFontName[fontName] = myName;
				}
				else
				{
					myName = "宋体";
					embedFonts = false;
				}
			}
			
			tf.embedFonts = embedFonts;
			
			var fmt:TextFormat = tf.defaultTextFormat;
			fmt.font = myName;
			
			tf.defaultTextFormat = fmt;
			
		}
		
	}
}