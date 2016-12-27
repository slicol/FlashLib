package com.tencent.fge.engine.bpe
{
	
	internal final class BpeMathUtil 
	{
		internal static var ONE_EIGHTY_OVER_PI:Number = 180 / Math.PI;
		internal static var PI_OVER_ONE_EIGHTY:Number = Math.PI / 180;

		internal static function clamp(n:Number, min:Number, max:Number):Number 
		{
			if (n < min) return min;
			if (n > max) return max;
			return n;
		}
		
		internal static function sign(val:Number):int 
		{
			if (val < 0) return -1
			return 1;
		}
	}
}