/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   XXTEA.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-2-25
#   Comment     :   一个XXTEA算法的实现类。
 * 					实现基于字符数组的XXTEA。
 * 					后续将实现基于字节流的XXTEA。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-2 文件创建 
#
*************************************************************************/

package com.tencent.fge.codec.tea
{
	import com.tencent.fge.utils.StringUtil;
	
	import flash.net.URLLoader;

	public class XXTEA
	{
		public function XXTEA()
		{
		}
		
		
		private static function splitString2Array(s:String):Array
		{
			var len:uint;
			var ret:Array;
			var ch:uint;
			var i:uint;
			len = s.length;
			ret = new Array(len << 1);
			ch = 0;
			i = 0;
			while (i < len)
			{
				ch = s.charCodeAt(i);
				ret[i << 1] = ch & 255;//0xff 取低位
				ret[(i << 1) + 1] = ch >> 8 & 255; //取高位
				++i;
			}
			return ret;
		}
		
		private static function mergeArray2String(arr:Array):String
		{
			var ret:String;
			var nArrLen:uint;
			var nStrLen:uint;
			var ch:String;
			var i:uint;
			ret = "";
			nArrLen = arr.length;
			if (nArrLen & 1 != 0)
			{
				//如果是奇数，则错误！
				return null;
			}
			nStrLen = nArrLen >> 1;
			ch = "";
			i = 0;
			while (i < nStrLen)
			{
				ch = String.fromCharCode(arr[(i << 1) + 1] << 8 ^ arr[i << 1]);
				ret = ret + ch;
				++i;
			}
			return ret;
		}
		
		public static function encrypt_String(str:String, key:String):String
		{
			var aStr:Array = splitString2Array(str);
			var aKey:Array = splitString2Array(key);
			
			var aRet:Array = encrypt_CharArray(aStr, aKey);
			var ret:String = mergeArray2String(aRet);
			
			return ret;
		}
		
		public static function decrypt_String(str:String, key:String):String
		{
			var aStr:Array = splitString2Array(str);
			var aKey:Array = splitString2Array(key);
			
			var aRet:Array = decrypt_CharArray(aStr, aKey);
			var ret:String = mergeArray2String(aRet);
			
			return ret;
		}
		
		
		public static function encrypt_CharArray(str:Array, key:Array):Array
		{ 
		    if (str == null || str.length == 0) 
		    { 
		        return null; 
		    }
		    
		    
		    var v:Array = new Array(str.length); 
		    var i:int = 0; 
		    for(i = 0; i < str.length; ++i)
		    {
		    	v[i] = str[i];
		    }
		    v[v.length] = str.length;
		    
		    
		    var k:Array = new Array(key.length); 
		    for(i = 0; i < key.length; ++i)
		    {
		    	k[i] = key[i];
		    }		    
		    
		    
		    if (k.length < 4) 
		    { 
		        k.length = 4; 
		    } 
		    var n:int = v.length - 1; 
		  
		    var z:int = v[n], y:int = v[0], delta:int = 0x9E3779B9; 
		    var mx:int, e:int, p:int, q:int = Math.floor(6 + 52 / (n + 1)), sum:int = 0; 
		    
		    while (0 < q--) 
		    { 
		        sum = sum + delta & 0xffffffff; 
		        e = sum >>> 2 & 3; 
		        for (p = 0; p < n; p++) 
		        { 
		            y = v[p + 1]; 
		            mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z); 
		            z = v[p] = v[p] + mx & 0xffffffff; 
		        } 
		        y = v[0]; 
		        mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z); 
		        z = v[n] = v[n] + mx & 0xffffffff; 
		    } 
		    
		    
		    //在这里进行分割
		    var datLen:int = v.length;
		    var ret:Array = new Array(datLen * 4);
		    var datVal:uint = 0;
		    i = 0;
		    while(i < datLen)
		    {
		    	datVal = v[i];
		    	ret[i * 4] = (datVal >> 24) & 0x000000ff;
		    	ret[i * 4 + 1] = (datVal >> 16) & 0x000000ff;
		    	ret[i * 4 + 2] = (datVal >> 8) & 0x000000ff;
		    	ret[i * 4 + 3] = datVal & 0x000000ff;
		    	++i;
		    }
		  
		    return ret; 
		} 
		  
		public static function decrypt_CharArray(str:Array, key:Array):Array
		{ 
		    if (str == null || str.length == 0 || str.length % 4 != 0) 
		    { 
		        return null; 
		    }
		    
		    
		    //合并数据
		    var datLen:int = str.length / 4;
		    var v:Array = new Array(datLen);
		    var datVal:uint = 0; 
		    var i:int = 0; 
		    for(i = 0; i < datLen; ++i)
		    {
		    	v[i] = (str[i * 4] << 24) 
			    	| (str[i * 4 + 1] << 16) 
			    	| (str[i * 4 + 2] << 8) 
			    	| (str[i * 4 + 3]);
		    }
		    
		    
		    var k:Array = new Array(key.length); 
		    for(i = 0; i < key.length; ++i)
		    {
		    	k[i] = key[i];
		    }
		    
		    if (k.length < 4) 
		    { 
		        k.length = 4; 
		    } 
		    var n:int = v.length - 1; 
		  
		    var z:int = v[n - 1], y:int = v[0], delta:int = 0x9E3779B9; 
		    var mx:int, e:int, p:int, q:int = Math.floor(6 + 52 / (n + 1)), sum:int = q * delta & 0xffffffff; 
		    while (sum != 0) 
		    { 
		        e = sum >>> 2 & 3; 
		        for (p = n; p > 0; p--) 
		        { 
		            z = v[p - 1]; 
		            mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z); 
		            y = v[p] = v[p] - mx & 0xffffffff; 
		        } 
		        z = v[n]; 
		        mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z); 
		        y = v[0] = v[0] - mx & 0xffffffff; 
		        sum = sum - delta & 0xffffffff; 
		    } 
		    return v.slice(0, v.length - 1); 
		}
		
		protected var version:String = "1.0.0";
		protected var author:String = "slicoltang,slicol@qq.com";
		protected var copyright:String = "腾讯计算机系统有限公司";			
	}
}