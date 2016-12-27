package com.tencent.fge.foundation.network.demo
{
	import com.tencent.fge.foundation.network.IProtocolHead;
	
	import flash.utils.ByteArray;

	public class PTL_Head implements IProtocolHead
	{
		public function PTL_Head()
		{
		}

		public function get pid():uint
		{
			return 0;
		}
		
		public function get headsize():uint
		{
			return 0;
		}
		
		public function get datasize():uint
		{
			return 0;
		}
		
		public function get length():uint
		{
			return 0;
		}
		
		public function get checksum():uint
		{
			return 0;
		}
		
		public function get index():uint
		{
			return 0;
		}
		
		public function readBytes(bytes:ByteArray, index:uint, pid:uint, pdata:ByteArray):uint
		{
			return 0;
		}
		
		public function writeBytes(bytes:ByteArray):uint
		{
			return 0;
		}
		
		public function copy(bytes:ByteArray):IProtocolHead
		{
			return null;
		}
		
		public function encrypt(bytes:ByteArray, dec:int, pid:uint):ByteArray
		{
			return bytes;
		}
		
		public function decrypt(bytes:ByteArray, dec:int, pid:uint):ByteArray
		{
			return bytes;
		}
		
	}
}