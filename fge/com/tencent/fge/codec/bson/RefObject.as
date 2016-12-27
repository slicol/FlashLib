package com.tencent.fge.codec.bson
{
	public final class RefObject extends Object
	{
		public var value:Object;
		
		public function RefObject(o:Object = null)
		{
			super();
			value = o;
		}
		
	}
}
