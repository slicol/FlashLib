package com.tencent.fge.foundation.network
{
	import flash.utils.ByteArray;
	
	internal final class ProtocolPackage
	{
		public var head:IProtocolHead;
		public var data:ByteArray;
		
		
		public function toString():String
		{
			return "ProtocolPackage(" + 
					"id:"+head.pid.toString()+"(0x"+head.pid.toString(16)+"), " + 
					"index:" + head.index.toString() + ", " +
					"dataSize:" + data.length + ")";
		}
	}
}