package com.tencent.fge.codec.swf
{
	public class SWFUtil
	{
		public function SWFUtil()
		{
		}
		
		static public function swapCombine2(b0:uint, b1:uint):uint
		{
			return (b1 << 8) | b0;
		}
		
		static public function swapCombine4(b0:uint, b1:uint, b2:uint, b3:uint):uint
		{
			return (b3 << 24) | (b2 << 16) | (b1 << 8) | (b0 << 0);
		}

	}
}