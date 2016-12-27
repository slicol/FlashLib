package com.tencent.fge.utils
{
	import flash.geom.Point;

	public class MathUtil
	{
		public static function restrict(min:Number, max:Number, value:Number):Number
		{
			return Math.max(min, Math.min(max, value));
		}
		
		public static function randomRange(min:Number, max:Number):Number
		{
			if(0 > min)
			{
				min = 0;
			}
			
			if(1 < max)
			{
				max = 1;
			}
			
			do
			{
				var randNum:Number = Math.random();
				
				if(min <= randNum && max > randNum)
				{
					return randNum;
				}
				
			}while(true);
			
			return Math.random();
		}
		
		public static function pointToString(point:Point):String
		{
			if(null == point)
			{
				return "null";
			}
			else
			{
				return "(" + point.x + ", " + point.y + ")";
			}
		}
	}
}