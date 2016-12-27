package com.tencent.fge.framework.resmanager
{
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	
	public class ResFile
	{
		public var path:String = "";
		public var type:String = "";
		public var ver:String = "0";
		public var content:*;
		public var bytes:ByteArray;
		public var size:int;
		public var memory:int;
		public var domain:ApplicationDomain;
	}
}