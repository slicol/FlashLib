package com.tencent.fge.utils
{
	import flash.utils.ByteArray;

	public class ProtoBuffUtil
	{
		public static function readString(bytes:ByteArray, charSet:String = "gb2312"):String
		{
			if(!bytes){return null;}
			
			return bytes.readMultiByte(bytes.length, charSet);
		}
	}
}