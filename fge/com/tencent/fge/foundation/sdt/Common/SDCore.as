/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   SDCore.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-2-25
#   Comment     :   一个安全数据类型的核心类。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-2 文件创建 
#
*************************************************************************/

package com.tencent.fge.foundation.sdt.Common
{
	import flash.utils.ByteArray;

	public class SDCore
	{
		public function SDCore()
		{
		}
		
		public static function toByteArray(bytes: Object): ByteArray
		{
			if (bytes is Array)
			{
				return arr2bytes(bytes as Array);
			}
			else if (bytes is ByteArray)
			{
				return bytes as ByteArray;
			}
			return null;
		}
		
		public static function toArray(bytes: Object): Array
		{
			if (bytes is Array)
			{
				return bytes as Array;
			}
			else if (bytes is ByteArray)
			{
				return bytes2arr(bytes as ByteArray);
			}
			return null;
		}
		
		public static function freeBytes(bytes: Object): Boolean
		{
			return MemoryPool.freeMemory(bytes);
		}
		
		private static function get crypto(): ICrypto
		{
//			return XXTeaArrayCrypto.singleton;		// encrypt 5	decrypt 10
//			return TeaByteArrayCrypto.singleton;	// encrypt 14	decrypt 63
//			
//			return XorByteArrayCrypto.singleton;	// encrypt 5	decrypt 66
//			return NegByteArrayCrypto.singleton;	// encrypt 5	decrypt 44
			
			return XorArrayCrypto.singleton;		// encrypt 1	decrypt 1
//			return NegArrayCrypto.singleton;		// encrypt 1	decrypt 1
		}
		
		public static function cloneBytes(bytes: Object): Object
		{
			return crypto.cloneBytes(bytes);
		}
		
		public static function randBytes(len: int): Object
		{
			return crypto.randBytes(len);
		}
		
		public static function compareBytes(bytes1: Object, bytes2: Object): Boolean
		{
			return crypto.compareBytes(bytes1, bytes2);
		}
		
        public static function string2bytes(str: String): Object
        {
			return crypto.str2bytes(str);
        }
        
        public static function bytes2string(bytes: Object): String
        {
			return crypto.bytes2str(bytes);
        }
		
		public static function get keylen(): int
		{
			return crypto.keylen;
		}
        
        public static function decrypt(cryptograph: Object, key: Object): Object
        {
//			TimeProfiler.begin(crypto.decrypt);
        	var r: Object = crypto.decrypt(cryptograph, key);
//			TimeProfiler.end(crypto.decrypt);
//			TimeProfiler.output("decrypt", crypto.decrypt);
			return r;
        }  
        
        public static function encrypt(plaintext: Object, key: Object): Object
        {
//			TimeProfiler.begin(crypto.encrypt);
        	var r: Object = crypto.encrypt(plaintext, key);
//			TimeProfiler.end(crypto.encrypt);
//			TimeProfiler.output("encrypt", crypto.encrypt);
			return r;
        }
     
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	            
	}	
}

import apparat.memory.MemoryPool;

import com.tencent.fge.codec.tea.XXTEA;
import com.tencent.fge.framework.resmanager.ResManager;

import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;

class TimeProfiler
{
	private static var ms_mapMax: Dictionary = new Dictionary();
	private static var ms_mapMin: Dictionary = new Dictionary();
	private static var ms_mapTemp: Dictionary = new Dictionary();
	
	public static function begin(key: Object): void
	{
		ms_mapTemp[key] = getTimer();
	}
	
	public static function end(key: Object): void
	{
		var time: int = getTimer() - ms_mapTemp[key];
		ms_mapMax[key] = isNaN(ms_mapMax[key]) ? time : Math.max(time, ms_mapMax[key]);
		ms_mapMin[key] = isNaN(ms_mapMin[key]) ? time : Math.min(time, ms_mapMin[key]);
	}
	
	public static function output(prefix: String, key: Object): void
	{
		trace(prefix, "max:" + ms_mapMax[key], "min:" + ms_mapMin[key]);
	}
}

//-----------------------------------------------------
class MemoryPool
{
	private static var ms_singleton: MemoryPool;
	
	public static function get singleton(): MemoryPool
	{
		if (ms_singleton == null)
		{
			ms_singleton = new MemoryPool();
		}
		return ms_singleton;
	}
	
	private static var ms_pool: Dictionary = new Dictionary();
	
	public static function getByteArray(len: int = 0): ByteArray
	{
		var bytes: ByteArray = getMemory(ByteArray) as ByteArray;
		bytes.length = len;
		return bytes;
	}
	
	public static function getArray(len: int = 0): Array
	{
		var arr: Array = getMemory(Array) as Array;
		arr.length = len;
		return arr;
	}
	
	public static function getMemory(clazz: Class): Object
	{
		if (clazz)
		{
			var pool: Array = ms_pool[clazz];
			if (pool && pool.length > 0)
			{
				return pool.pop();
			}
			else
			{
				return new clazz();
			}
		}
		return null;
	}
	
	private static function getClass(object: Object): *
	{
		if (object)
		{
			var clazz: * = null;
			try
			{
				var className: String = getQualifiedClassName(object);
				clazz = className ? getDefinitionByName(className) : null;
			}
			catch (e: Error)
			{}
			
			if (clazz)
			{
				return clazz;
			}
			else if (object.hasOwnProperty("constructor"))
			{
				return object.constructor;
			}
		}
		return null;
	}
	
	public static function freeMemory(object: Object): Boolean
	{
		if (object)
		{
			var clazz: Class = getClass(object);
			if (clazz)
			{
				var pool: Array = ms_pool[clazz];
				if (pool)
				{
					if (pool.indexOf(object) < 0)
					{
						pool.push(object);
						return true;
					}
				}
				else
				{
					ms_pool[clazz] = [object];
					return true;
				}
			}
		}
		return false;
	}
}

function arr2bytes(arr: Array): ByteArray
{
	var bytes: ByteArray = MemoryPool.getByteArray();//new ByteArray();
	for each (var str: String in arr)
	{
		var val: int = int(str);
		bytes.writeByte(val);
	}
	bytes.position = 0;
	return bytes;
}

function bytes2arr(bytes: ByteArray): Array
{
	var arr: Array = null;
	if (bytes)
	{
		var pos: int = bytes.position;
		bytes.position = 0;
		arr = MemoryPool.getArray();//[];
		
		for (var i: int = 0, n: int = bytes.bytesAvailable; i < n; i++)
		{
			var val: uint = bytes.readUnsignedByte();
			arr.push(val.toString());
		}
		bytes.position = pos;
	}
	return arr;
}

//-----------------------------------------------------
interface ICrypto
{
	function cloneBytes(bytes: Object): Object;
	function randBytes(len: int): Object;
	function compareBytes(bytes1: Object, bytes2: Object): Boolean;
	function str2bytes(str: String): Object;
	function bytes2str(bytes: Object): String;
	function get keylen(): int;
	function decrypt(cryptograph: Object, key: Object): Object;
	function encrypt(plaintext: Object, key: Object): Object;
}

//.....................................................
class BaseArrayCrypto implements ICrypto
{
	public function cloneBytes(bytes: Object): Object
	{
		var arr: Array = bytes as Array;
		if (arr)
		{
			var arrLen:int = arr.length;
			var buf:Array = MemoryPool.getArray(arrLen);//new Array(arrLen);
			
			var i:int = 0;
			while (i < arrLen)
			{
				buf[i] = arr[i];
				++i;
			}
		}
		return buf;
	}
	
	public function randBytes(len: int): Object
	{
		var bytes: Array = MemoryPool.getArray();//[];
		for (var i: int = 0; i < len; i++)
		{
			bytes[i] = (int)(Math.random() * 255);
		}
		return bytes;
	}
	
	public function compareBytes(bytes1: Object, bytes2: Object): Boolean
	{
		var arr1: Array = bytes1 as Array;
		var arr2: Array = bytes2 as Array;
		if (arr1 && arr2)
		{
			if(arr1.length == arr2.length)
			{
				for(var i:int = 0, n: int = arr1.length; i < n; ++i)
				{
					if(arr1[i] != arr2[i])
					{
						return false;
					}
				}
				return true;
			}
		}
		return false;
	}
	
	public function str2bytes(s: String): Object
	{
		var len:uint = s.length;
		var ret:Array = MemoryPool.getArray(len << 1);//new Array(len << 1);
		var ch:uint = 0;
		var i:uint = 0;
		while (i < len)
		{
			ch = s.charCodeAt(i);
			ret[i << 1] = ch & 255;//0xff 取低位
			ret[(i << 1) + 1] = ch >> 8 & 255; //取高位
			++i;
		}
		return ret;
	}
	
	public function bytes2str(bytes: Object): String
	{
		var ret: String = null;
		var arr: Array = bytes as Array;
		if (arr)
		{
			var nArrLen:uint = arr.length;
			if (nArrLen & 1 != 0)
			{
				//如果是奇数，则错误！
				return null;
			}
			
			var nStrLen:uint = nArrLen >> 1;
			var ch:String = "";
			var i:uint = 0;
			ret = "";
			while (i < nStrLen)
			{
				ch = String.fromCharCode(arr[(i << 1) + 1] << 8 ^ arr[i << 1]);
				ret = ret + ch;
				++i;
			}
		}
		return ret;
	}
	
	public function decrypt(cryptograph: Object, key: Object): Object
	{
		var originBytes: Array = cryptograph as Array;
		var keyBytes: Array = key as Array;
		if (originBytes && (this.keylen > 0 && keyBytes || this.keylen == 0))
		{
			var bytes: Array = doDecrypt(originBytes, keyBytes);
			return bytes;
		}
		return null;
	}  
	
	public function encrypt(plaintext: Object, key: Object): Object
	{
		var originBytes: Array = plaintext as Array;
		var keyBytes: Array = key as Array;
		if (originBytes && keyBytes)
		{
			var bytes: Array = doEncrypt(originBytes, keyBytes);
			return bytes;
		}
		return null;
	}
	
	public function get keylen(): int
	{
		return 0;
	}
	
	protected function doDecrypt(originBytes: Array, keyBytes: Array): Array
	{
		return null;
	}
	
	protected function doEncrypt(originBytes: Array, keyBytes: Array): Array
	{
		return null;
	}
}

//.....................................................
class BaseByteArrayCrypto implements ICrypto
{
	public function cloneBytes(bytes: Object): Object
	{
		var buf: ByteArray = null;
		var arr: ByteArray = bytes as ByteArray;
		if (arr)
		{
			buf = MemoryPool.getByteArray();//new ByteArray();
			buf.writeBytes(arr, 0, arr.length);
			buf.position = 0;
		}
		return buf;
	}
	
	public function randBytes(len: int): Object
	{
		var bytes: ByteArray = MemoryPool.getByteArray();//new ByteArray();
		for (var i: int = 0; i < len; i++)
		{
			bytes.writeByte(Math.random() * 255);
		}
		bytes.position = 0;
		return bytes;
	}
	
	public function compareBytes(bytes1: Object, bytes2: Object): Boolean
	{
		var b1: ByteArray = bytes1 as ByteArray;
		var b2: ByteArray = bytes2 as ByteArray;
		if (b1 && b2)
		{
			if(b1.length == b2.length)
			{
				var pos1: int = b1.position;
				var pos2: int = b2.position;
				b1.position = 0;
				b2.position = 0;
				for (var i:int = 0, n: int = b1.length; i < n; ++i)
				{
					if (b1.readByte() != b2.readByte())
					{
						b1.position = pos1;
						b2.position = pos2;
						return false;
					}
				}
				b1.position = pos1;
				b2.position = pos2;
				return true;
			}
		}
		return false;
	}
	
	public function str2bytes(s: String): Object
	{
		var ret:ByteArray = null;
		if (s)
		{
			var len:uint = s.length;
			var ch:uint = 0;
			var i:uint = 0;
			
			ret = MemoryPool.getByteArray();//new ByteArray();
			ret.length = len << 1;
			while (i < len)
			{
				ch = s.charCodeAt(i);
				ret.writeByte(ch & 255);//0xff 取低位
				ret.writeByte(ch >> 8 & 255); //取高位
				++i;
			}
			ret.position = 0;
		}
		return ret;
	}
	
	public function bytes2str(bytes: Object): String
	{
		var ret:String;
		var arr: ByteArray = bytes as ByteArray;
		if (arr)
		{
			var nArrLen:uint = arr.length;
			if (nArrLen & 1 != 0)
			{
				//如果是奇数，则错误！
				return null;
			}
			
			var nStrLen:uint = nArrLen >> 1;
			var ch:String = "";
			var i:uint = 0;
			ret = "";
			
			var pos: int = arr.position;
			arr.position = 0;
			while (i < nStrLen)
			{
				var low: uint = arr.readUnsignedByte();
				var high: uint = arr.readUnsignedByte();
				ch = String.fromCharCode(high << 8 ^ low);
				ret = ret + ch;
				++i;
			}
			arr.position = pos;
		}
		return ret;
	}
	
	public function decrypt(cryptograph: Object, key: Object): Object
	{
		var originBytes: ByteArray = cryptograph as ByteArray;
		var keyBytes: ByteArray = key as ByteArray;
		if (originBytes && (this.keylen > 0 && keyBytes || this.keylen == 0))
		{
			var bytes: ByteArray = doDecrypt(originBytes, keyBytes);
			return bytes;
		}
		return null;
	}  
	
	public function encrypt(plaintext: Object, key: Object): Object
	{
		var originBytes: ByteArray = plaintext as ByteArray;
		var keyBytes: ByteArray = key as ByteArray;
		if (originBytes && keyBytes)
		{
			var bytes: ByteArray = doEncrypt(originBytes, keyBytes);
			return bytes;
		}
		return null;
	}
	
	public function get keylen(): int
	{
		return 0;
	}
	
	protected function doDecrypt(originBytes: ByteArray, keyBytes: ByteArray): ByteArray
	{
		return null;
	}
	
	protected function doEncrypt(originBytes: ByteArray, keyBytes: ByteArray): ByteArray
	{
		return null;
	}
}

//-----------------------------------------------------
class XXTeaArrayCrypto extends BaseArrayCrypto implements ICrypto
{
	private static var ms_singleton: ICrypto;
	
	public static function get singleton(): ICrypto
	{
		if (ms_singleton == null)
		{
			ms_singleton = new XXTeaArrayCrypto();
		}
		return ms_singleton;
	}
	
	public override function get keylen(): int
	{
		return 23;
	}
	
	protected override function doDecrypt(originBytes:Array, keyBytes:Array):Array
	{
		return XXTEA.decrypt_CharArray(originBytes, keyBytes);
	}  
	
	protected override function doEncrypt(originBytes:Array, keyBytes:Array):Array
	{
		return XXTEA.encrypt_CharArray(originBytes, keyBytes);
	}
}

//.....................................................
class TeaByteArrayCrypto extends BaseByteArrayCrypto implements ICrypto
{
	private static var ms_singleton: ICrypto;
	
	public static function get singleton(): ICrypto
	{
		if (ms_singleton == null)
		{
			ms_singleton = new TeaByteArrayCrypto();
		}
		return ms_singleton;
	}
	
	private static const FUNC_TEALEN:String = "1";
	private static const FUNC_TEAENC:String = "2";
	private static const FUNC_TEADEC:String = "3";
	
	protected override function doDecrypt(cryptograph:ByteArray, key:ByteArray):ByteArray
	{
		return ResManager.libx ? ResManager.libx[FUNC_TEADEC](cryptograph, key) : null;
	}
	
	protected override function doEncrypt(plaintext:ByteArray, key:ByteArray):ByteArray
	{
		return ResManager.libx ? ResManager.libx[FUNC_TEAENC](plaintext, key) : null;
	}
	
	public override function get keylen(): int
	{
		return 16;
	}
}

//.....................................................
class XorByteArrayCrypto extends BaseByteArrayCrypto implements ICrypto
{
	private static var ms_singleton: ICrypto;
	
	public static function get singleton(): ICrypto
	{
		if (ms_singleton == null)
		{
			ms_singleton = new XorByteArrayCrypto();
		}
		return ms_singleton;
	}
	
	protected override function doDecrypt(originBytes:ByteArray, keyBytes:ByteArray):ByteArray
	{
		return crypt(originBytes, keyBytes);
	}
	
	protected override function doEncrypt(originBytes:ByteArray, keyBytes:ByteArray):ByteArray
	{
		return crypt(originBytes, keyBytes);
	}
	
	public override function get keylen(): int
	{
		return 3;
	}
	
	private static function crypt(originBytes: ByteArray, keyBytes: ByteArray): ByteArray
	{
		var bytes: ByteArray = null;
		if (originBytes && keyBytes)
		{
			var pos1: int = originBytes.position;
			var pos2: int = keyBytes.position;
			
			originBytes.position = 0;
			keyBytes.position = 0;
			bytes = MemoryPool.getByteArray();//new ByteArray();
			for (var i: int = 0, n: int = originBytes.length; i < n; i++)
			{
				if (keyBytes.bytesAvailable == 0)
				{
					keyBytes.position = 0;
				}
				
				var byte: uint = originBytes.readUnsignedByte();
				var mask: uint = keyBytes.readUnsignedByte();
				byte ^= mask;
				bytes.writeByte(byte);
			}
			
			bytes.position = 0;
			originBytes.position = pos1;
			keyBytes.position = pos2;
		}
		return bytes;
	}
}

//.....................................................
class NegByteArrayCrypto extends BaseByteArrayCrypto implements ICrypto
{
	private static var ms_singleton: ICrypto;
	
	public static function get singleton(): ICrypto
	{
		if (ms_singleton == null)
		{
			ms_singleton = new NegByteArrayCrypto();
		}
		return ms_singleton;
	}
	
	protected override function doDecrypt(originBytes:ByteArray, keyBytes:ByteArray):ByteArray
	{
		return crypt(originBytes, keyBytes);
	}
	
	protected override function doEncrypt(originBytes: ByteArray, keyBytes: ByteArray): ByteArray
	{
		return crypt(originBytes, keyBytes);
	}
	
	public override function get keylen(): int
	{
		return 0;
	}
	
	private static function crypt(originBytes: ByteArray, keyBytes: ByteArray): ByteArray
	{
		var bytes: ByteArray = null;
		if (originBytes)
		{
			bytes = MemoryPool.getByteArray();//new ByteArray();
			
			var pos: int = originBytes.position;
			for (var i: int = 0, n: int = originBytes.length; i < n; i++)
			{
				var byte: uint = originBytes.readUnsignedByte();
				byte = ~byte & 0xff;
				bytes.writeByte(byte);
			}
			originBytes.position = pos;
			bytes.position = 0;
		}
		return bytes;
	}
}

//.....................................................
class XorArrayCrypto extends BaseArrayCrypto implements ICrypto
{
	private static var ms_singleton: ICrypto;
	
	public static function get singleton(): ICrypto
	{
		if (ms_singleton == null)
		{
			ms_singleton = new XorArrayCrypto();
		}
		return ms_singleton;
	}
	
	protected override function doDecrypt(originBytes:Array, keyBytes:Array):Array
	{
		return crypt(originBytes, keyBytes);
	}
	
	protected override function doEncrypt(originBytes:Array, keyBytes:Array):Array
	{
		return crypt(originBytes, keyBytes);
	}
	
	public override function get keylen(): int
	{
		return 3;
	}
	
	private static function crypt(originBytes: Array, keyBytes: Array): Array
	{
		var bytes: Array = null;
		if (originBytes && keyBytes)
		{
			bytes = MemoryPool.getArray();//[];
			for (var i: int = 0, n: int = originBytes.length, m: int = keyBytes.length; i < n; i++)
			{
				var byte: uint = originBytes[i];
				var mask: uint = keyBytes[i % m];
				byte ^= mask;
				bytes.push(byte);
			}
		}
		return bytes;
	}
}

//.....................................................
class NegArrayCrypto extends BaseArrayCrypto implements ICrypto
{
	private static var ms_singleton: ICrypto;
	
	public static function get singleton(): ICrypto
	{
		if (ms_singleton == null)
		{
			ms_singleton = new NegArrayCrypto();
		}
		return ms_singleton;
	}
	
	protected override function doDecrypt(originBytes:Array, keyBytes:Array):Array
	{
		return crypt(originBytes, keyBytes);
	}
	
	protected override function doEncrypt(originBytes:Array, keyBytes:Array):Array
	{
		return crypt(originBytes, keyBytes);
	}
	
	public override function get keylen(): int
	{
		return 0;
	}
	
	private static function crypt(originBytes: Array, keyBytes: Array): Array
	{
		var bytes: Array = null;
		if (originBytes)
		{
			bytes = MemoryPool.getArray();//[];
			for (var i: int = 0, n: int = originBytes.length; i < n; i++)
			{
				var byte: uint = originBytes[i];
				byte = ~byte & 0xff;
				bytes.push(byte);
			}
		}
		return bytes;
	}
}