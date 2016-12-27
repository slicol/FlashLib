/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   Base64.as
#   Version     :   2.0.0
#   Author      :   slicoltang
#   Date        :   2010-2-25
#   Comment     :   一个Base64类。
 * 					实现了基于字节的Base64编解码
 * 					实现了基于字符的Base64编解码
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-2 文件创建 
#
*************************************************************************/

package com.tencent.fge.codec
{
	import flash.utils.ByteArray;
	
	public class Base64
	{
		private static const BASE64_CHARS:String = 
			"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="; 
			   
		public static const version:String = "2.0.0";    
 		
		public function Base64()
		{
			throw new Error("Base64 class is static container only");    
		}

        public static function encode(data:String):String 
        {    
            var bytes:ByteArray = new ByteArray();    
            bytes.writeUTFBytes(data);    
            return encodeByteArray(bytes);    
        }
                    
        public static function encodeByteArray(data:ByteArray):String 
        {    
            var output:String = "";    
            var dataBuffer:Array;    
            var outputBuffer:Array = new Array(4);    
                
            data.position = 0;    
                
            while (data.bytesAvailable > 0) 
            {        
                dataBuffer = new Array();    
                for (var i:uint = 0; i < 3 && data.bytesAvailable > 0; i++)
                {    
                    dataBuffer[i] = data.readUnsignedByte();    
                }    
   
                outputBuffer[0] = (dataBuffer[0] & 0xfc) >> 2;    
                outputBuffer[1] = ((dataBuffer[0] & 0x03) << 4) | ((dataBuffer[1]) >> 4);    
                outputBuffer[2] = ((dataBuffer[1] & 0x0f) << 2) | ((dataBuffer[2]) >> 6);    
                outputBuffer[3] = dataBuffer[2] & 0x3f;    
                    
                for (var j:uint = dataBuffer.length; j < 3; j++) 
                {    
                    outputBuffer[j + 1] = 64; //"="   
                }    
                    
                for (var k:uint = 0; k < outputBuffer.length; k++) {    
                    output += BASE64_CHARS.charAt(outputBuffer[k]);    
                }    
            }    
                 
            return output;    
        }    
            
        public static function decode(data:String):String 
        {    
            var bytes:ByteArray = decodeToByteArray(data);    
            return bytes.readUTFBytes(bytes.length);    
        }    
            
        public static function decodeToByteArray(data:String):ByteArray 
        {    
            var output:ByteArray = new ByteArray();      
            var dataBuffer:Array = new Array(4);    
            var outputBuffer:Array = new Array(3);    
   
            for (var i:uint = 0; i < data.length; i += 4) 
            {    
                for (var j:uint = 0; j < 4 && i + j < data.length; j++) 
                {    
                    dataBuffer[j] = BASE64_CHARS.indexOf(data.charAt(i + j));    
                }    
                      
                outputBuffer[0] = (dataBuffer[0] << 2) + ((dataBuffer[1] & 0x30) >> 4);    
                outputBuffer[1] = ((dataBuffer[1] & 0x0f) << 4) + ((dataBuffer[2] & 0x3c) >> 2);            
                outputBuffer[2] = ((dataBuffer[2] & 0x03) << 6) + dataBuffer[3];    
                     
                for (var k:uint = 0; k < outputBuffer.length; k++)
                {    
                    if (dataBuffer[k+1] == 64) break;    
                    output.writeByte(outputBuffer[k]);    
                }    
            }    
                
            output.position = 0;    
            return output;    
        }
        

        
        
        
		public static function encode_CharArray(data:Array):String
		{
			var ret:String;
			
			//以下使数据的长度为3的倍数
			var datLenMod:uint = data.length % 3;
			if (datLenMod == 0)
			{
			    ret = "t";
			}
			else if (datLenMod == 1)
			{
			    ret = "s";
			    data.push(0);
			    data.push(0);
			}
			else
			{
			    ret = "f";
			    data.push(0);
			}
			
			//这时datLen应该为整数
			var datLen:uint = data.length / 3;
			
			var ch0:String = "";
			var ch1:String = "";
			var ch2:String = "";
			var ch3:String = "";
			
			var code0:uint = 0;
			var code1:uint = 0;
			var code2:uint = 0;
			
			var i:uint = 0;
			while (i < datLen)
			{
			    code0 = data[i * 3];
			    code1 = data[i * 3 + 1];
			    code2 = data[i * 3 + 2];
			    ch0 = BASE64_CHARS.charAt(code0 >> 2);
			    ch1 = BASE64_CHARS.charAt((code0 & 0x03) << 4 ^ code1 >> 4);
			    ch2 = BASE64_CHARS.charAt((code1 & 0x0f) << 2 ^ code2 >> 6);
			    ch3 = BASE64_CHARS.charAt(code2 & 0x3f);
			    ret = ret + ch0 + ch1 + ch2 + ch3;
			    ++i;
			}
			return ret;
		}
		

		public static function decode_CharArray(s:String) : Array
		{
			var datLen:int;
			var datMod:String;
			var data:String;
			var ret:Array;
			var buf:Array;

			datLen = s.length / 4 * 3;
			buf = new Array(datLen);
			datMod = s.charAt(0);
			data = s.slice(1);

			if (datMod == "t")
			{
			    ret = new Array(datLen);
			}
			else if (datMod == "s")
			{
			    ret = new Array(datLen - 2);
			}
			else if (datMod == "f")
			{
			    ret = new Array(datLen - 1);
			}
			else
			{
			    return null;
			}
			
			datLen = datLen / 3;
			
			var ch0:uint = 0;
			var ch1:uint = 0;
			var ch2:uint = 0;
			var ch3:uint = 0;
			
			var i:uint = 0;
			while (i < datLen)
			{
			    ch0 = BASE64_CHARS.indexOf(data.charAt(4 * i));
			    ch1 = BASE64_CHARS.indexOf(data.charAt(4 * i + 1));
			    ch2 = BASE64_CHARS.indexOf(data.charAt(4 * i + 2));
			    ch3 = BASE64_CHARS.indexOf(data.charAt(4 * i + 3));
			    
			    buf[3 * i] = ch0 << 2 ^ ch1 >> 4;
			    buf[3 * i + 1] = (ch1 & 0x0f) << 4 ^ ch2 >> 2;
			    buf[3 * i + 2] = (ch2 & 0x03) << 6 ^ ch3;
			    ++i;
			}
			
			
			var retLen:uint = ret.length;
			var j:uint = 0;
			while (j < retLen)
			{
			    ret[j] = buf[j];
			    ++j;
			}
			return ret;
		}
		
		
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	   	    
	}
}   
