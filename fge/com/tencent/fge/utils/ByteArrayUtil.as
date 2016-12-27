package com.tencent.fge.utils
{
	import flash.utils.ByteArray;
	
	public class ByteArrayUtil
	{
		public function ByteArrayUtil()
		{
		}
		
		public static function toString(bytes:ByteArray):String
		{
			var s:String = " ";
			var pos:uint = bytes.position;
			while(bytes.bytesAvailable > 0)
			{
				var byte:uint = bytes.readUnsignedByte();
				if(byte < 16) s += "0";
				s += byte.toString(16);
				s += " ";
			}
			bytes.position =  pos;
			return "["+s+"]";
		}

		/*---------------------------------------------------------
		*	Func:	writeString
		*	Desc:	Writes a string to the byte stream according to a specific character set.
		*			The length of the string in bytes is written first, as a 16-bit integer,
		*			followed by the bytes representing the characters of the string.
		*	Param:	
		*	Return:	
		*	Remark:	
		*--------------------------------------------------------*/
		public static function writeString(bytes:ByteArray, str:String, charSet:String):void
		{
			var bytesLength:uint = StringUtil.getStringBytesLength(str, charSet);
			bytes.writeShort(bytesLength);
			bytes.writeMultiByte(str, charSet);
		}
		
		/*---------------------------------------------------------
		*	Func:	readString
		*	Desc:	Reads a string from the byte stream according to a specific character set.
		*			The string is assumed to be prefixed with an short indicating the length in bytes.
		*	Param:	
		*	Return:	
		*	Remark:	
		*--------------------------------------------------------*/
		public static function readString(bytes:ByteArray, charSet:String):String
		{
			var bytesLength:int = bytes.readShort();
			return bytes.readMultiByte(bytesLength, charSet);
		}
	}
}