package com.tencent.fge.utils
{
	import com.tencent.fge.utils.CharSet;
	
	import flash.utils.ByteArray;

	public class StringUtil
	{
		private static var ms_sSpace:String = "                  ";
		
		public function StringUtil()
		{
		}
		
	    static public function replace(str:String, oldSubStr:String, newSubStr:String):String 
	    {
	        return str.split(oldSubStr).join(newSubStr);
	    }
	
	    static public function trim(str:String, char:String = " "):String 
	    {
	    	if(isWhitespace(char))
	    	{
	    		return trimFast(str);
	    	}
	        else
	        {
	        	return trimBack(trimFront(str, char), char);
	        }
	    }
	
	    static public function trimFront(str:String, char:String):String 
	    {
	        char = stringToCharacter(char);
	        if (str.charAt(0) == char) 
	        {
	            str = trimFront(str.substring(1), char);
	        }
	        return str;
	    }
	
	    static public function trimBack(str:String, char:String):String 
	    {
	        char = stringToCharacter(char);
	        if (str.charAt(str.length - 1) == char) 
	        {
	            str = trimBack(str.substring(0, str.length - 1), char);
	        }
	        return str;
	    }
	
	    static public function stringToCharacter(str:String):String 
	    {
	        if (str.length == 1) 
	        {
	            return str;
	        }
	        return str.slice(0, 1);
	    }
	    
	    	
	    private static function trimFast(str:String):String
	    {
	        if (str == null) return '';
	        
	        var startIndex:int = 0;
	        while (isWhitespace(str.charAt(startIndex)))
	            ++startIndex;
	
	        var endIndex:int = str.length - 1;
	        while (isWhitespace(str.charAt(endIndex)))
	            --endIndex;
	
	        if (endIndex >= startIndex)
	            return str.slice(startIndex, endIndex + 1);
	        else
	            return "";
	    }
    
	    public static function trimArrayElements(value:String, delimiter:String):String
	    {
	        if (value != "" && value != null)
	        {
	            var items:Array = value.split(delimiter);
	            
	            var len:int = items.length;
	            for (var i:int = 0; i < len; i++)
	            {
	                items[i] = StringUtil.trim(items[i]);
	            }
	            
	            if (len > 0)
	            {
	                value = items.join(delimiter);
	            }
	        }
	        
	        return value;
	    }


	    public static function isWhitespace(character:String):Boolean
	    {
	        switch (character)
	        {
	            case " ":
	            case "\t":
	            case "\r":
	            case "\n":
	            case "\f":
	                return true;
	
	            default:
	                return false;
	        }
	    }

	    public static function substitute(str:String, ... rest):String
	    {
	        if (str == null) return '';
	        
	        // Replace all of the parameters in the msg string.
	        var len:uint = rest.length;
	        var args:Array;
	        if (len == 1 && rest[0] is Array)
	        {
	            args = rest[0] as Array;
	            len = args.length;
	        }
	        else
	        {
	            args = rest;
	        }
	        
	        for (var i:int = 0; i < len; i++)
	        {
	            str = str.replace(new RegExp("\\{"+i+"\\}", "g"), args[i]);
	        }
	
	        return str;
	    }
	    
	    
	    public static function printf(fmt:String, ... arg):String
	    {
	    	var argCnt:int = arg.length;
	    	var ret:String = "";
			var j:int = 0;
	    	var j1:int = 0;
	    	var j2:int = 0;
	    			    	
	    	for(var i:int = 0; i < argCnt; ++i)
	    	{
	    		j1 = j;
	    		while(j < fmt.length - 1)
	    		{
	    			if(fmt.charAt(j) == "%")
	    			{
	    				var tmp:String = fmt.charAt(j + 1);
	    				if(tmp != "%")
	    				{
		    				if(tmp == "s")
		    				{
		    					j2 = j;
		    					ret = ret + fmt.substring(j1,j2) + (arg[i]).toString();
		    					j += 2;
		    					break;
		    				}
		    				else if(tmp == "d")
		    				{
		    					j2 = j;
		    					ret = ret + fmt.substring(j1,j2) + (arg[i]).toString();
		    					j += 2;
		    					break;
		    				}
		    				else if(tmp == "u")
		    				{
		    					j2 = j;
		    					ret = ret + fmt.substring(j1,j2) + (arg[i]).toString();
		    					j += 2;
		    					break;
		    				}
		    				else
		    				{
		    					++j;
		    				}
	    				}
	    			}
	    			++j;
	    		}
	    	}
	    	return ret;
	    }
		
		
		//=========================================================================
		
		public static function getStringBytes(s:String, sizeOfBytes:int, chatSet:String):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			var returnBytes:ByteArray = new ByteArray();
			
			if(0 < sizeOfBytes)
			{
				bytes.writeMultiByte(s ,chatSet);
				
				while(bytes.length < sizeOfBytes - 1)
				{
					bytes.writeByte(0);
				}
				
				bytes.position = 0;
				bytes.readBytes(returnBytes ,0 ,sizeOfBytes -1);
				
				returnBytes.position = returnBytes.length;
				returnBytes.writeByte(0);
				returnBytes.position = 0;
			}
			
			
			return returnBytes;
		}
		
		
		//=========================================================================
		
		private static var s_bytesTestString:ByteArray = new ByteArray;
		public static function getStringBytesLength(str:String, charSet:String):uint
		{
			s_bytesTestString.clear();
			s_bytesTestString.writeMultiByte(str, charSet);
			s_bytesTestString.position = 0;
			return s_bytesTestString.length;
		}
		
		/**
		 *根据指定的byteLength设置字符串内容，字符串长度小于byteLength不修改
		 * 长于byteLength时减3byte长度补"..."
		 * @param maxBytesLength
		 * @param text
		 * @return 
		 * 
		 */		
		public static function getTextByByteLength(maxByteLength:int ,text:String):String
		{
			var btyesLength:int;
			var returnString:String;	
			
			returnString = text;
			maxByteLength -= maxByteLength % 2;
			btyesLength = StringUtil.getStringBytesLength(text, CharSet.GB2312);
			if(btyesLength > maxByteLength)
			{
				returnString = StringUtil.getTextByCharLength(returnString ,(maxByteLength - 3) - (maxByteLength - 3)%2);
				returnString = returnString + "...";
			}
			
			return returnString;			
		}
		
		/**
		 * 截取指定长度的文本内容,一个中文算2长度
		 * @param txt 需要截取的文本
		 * @param length 需要截取的长度
		 * @return 截取后的内容
		 */    
		public static function getTextByCharLength(txt:String, length:int ,chatSet:String = "gb2312"):String
		{
			if(length<1)return "";
			var byte:ByteArray = new ByteArray();
			byte.writeMultiByte(txt, chatSet);
			byte.position = 0;
			return byte.readMultiByte(Math.min(length,byte.bytesAvailable), chatSet);
		}
		
		
		/**
		 * 截取指定长度的文本内容,一个中文算2长度，会自动去掉最后的半个中文字符
		 * @param txt 需要截取的文本
		 * @param length 需要截取的长度
		 * @return 截取后的内容
		 */    
		public static function getTextByCharLengthEx(txt:String, length:int ,chatSet:String = "gb2312"):String
		{
			if(length<1)return "";
			var byte:ByteArray = new ByteArray();
			byte.writeMultiByte(txt, chatSet);
			byte.position = 0;
			
			var len:int = Math.min(length,byte.bytesAvailable);
			byte.position = len - 1;
			var j:int = 0; 
			
			for(var i:int = len - 1; i >= 0; --i)
			{
				byte.position = i;
				var char:uint = byte.readUnsignedByte();
				if((char & 0x80) == 0)
				{
					break;
				}
			}
			
			if((i + 1 - len) % 2 != 0)
			{
				len--;
			}
			
			
			
			byte.position = 0;
			return byte.readMultiByte(len, chatSet);
		}
		
		
		
		public static const RANGE_NUMBERS:uint = 0x00000001;	//	0 ~ 9
		public static const RANGE_LOWER_LETTER:uint = 0x00000002;	//	a ~ z
		public static const RANGE_UPPER_LETTER:uint = 0x00000004;	//	A ~ Z
		public static const RANGE_LETTERS:uint = RANGE_LOWER_LETTER | RANGE_UPPER_LETTER;
		
		private static const CHAR_CODE_0:Number = "0".charCodeAt();
		private static const CHAR_CODE_9:Number = "9".charCodeAt();
		private static const CHAR_CODE_LOWER_A:Number = "a".charCodeAt();
		private static const CHAR_CODE_LOWER_Z:Number = "z".charCodeAt();
		private static const CHAR_CODE_UPPER_A:Number = "A".charCodeAt();
		private static const CHAR_CODE_UPPER_Z:Number = "Z".charCodeAt();
		public static function isStringInRange(str:String, range:uint):Boolean
		{
			var result:Boolean;
			
			
			var i:int;
			var oneCharCode:Number;
			for(i = 0; i < str.length; ++i)
			{
				oneCharCode = str.charCodeAt(i);
				
				result = false;
				if(true == Boolean(range & RANGE_NUMBERS))
				{
					if(oneCharCode >= CHAR_CODE_0 && oneCharCode <= CHAR_CODE_9)
					{
						result = true;
					}
				}
				
				if(result == false && true == Boolean(range & RANGE_LOWER_LETTER))
				{
					if(oneCharCode >= CHAR_CODE_LOWER_A && oneCharCode <= CHAR_CODE_LOWER_Z)
					{
						result = true;
					}
				}
				
				if(result == false && true == Boolean(range & RANGE_UPPER_LETTER))
				{
					if(oneCharCode >= CHAR_CODE_UPPER_A && oneCharCode <= CHAR_CODE_UPPER_Z)
					{
						result = true;
					}
				}
				
				if(result == false)
				{
					//	one letter is NOT in the desired range
					return false;
				}
			}
			
			
			//	all letters are in the desired range
			return true;
		}
		
		
		
		public static function expendString(src:String, len:int):String
		{
			if(null == src)
			{
				src = "";
			}
			
			var tmp:int = len - src.length;
			var ret:String = src;
			if(tmp > 0)
			{
				while(tmp > ms_sSpace.length)
				{
					ms_sSpace += ms_sSpace;
				}
				
				ret += ms_sSpace.substr(0, tmp);
				
			}
			return ret;
		}
	}
}