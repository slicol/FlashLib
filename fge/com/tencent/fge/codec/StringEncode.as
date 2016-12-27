package com.tencent.fge.codec
{
	import flash.utils.ByteArray;
	public class StringEncode
	{
		public function StringEncode():void
		{
			
		}
  
		public static function urlencodeGB2312(str:String):String
		{
			var result:String ="";
			var byte:ByteArray =new ByteArray();
			 
			byte.writeMultiByte(str,"gb2312");
			 
			for(var i:int;i<byte.length;i++)
			{
				result += escape(String.fromCharCode(byte[i]));
			}
			return result;
		}

		public static function urlencodeBIG5(str:String):String
		{
			var result:String ="";
			var byte:ByteArray =new ByteArray();
			byte.writeMultiByte(str,"big5");
			for(var i:int;i<byte.length;i++)
			{
				result += escape(String.fromCharCode(byte[i]));
			}
			return result;
		}

		public static function urlencodeGBK(str:String):String
		{
			var result:String ="";
			var byte:ByteArray =new ByteArray();
			byte.writeMultiByte(str,"gbk");
			byte.position =0;
			return byte.readMultiByte(byte.length, "gbk");
			//return byte.toString();
			
			for(var i:int;i<byte.length;i++)
			{
		 		result += escape(String.fromCharCode(byte[i]));
	   		}
   			return result;
  		}
 	}
}

