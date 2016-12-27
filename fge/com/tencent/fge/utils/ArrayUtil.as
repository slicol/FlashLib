package com.tencent.fge.utils
{
	public class ArrayUtil
	{
		public static function vector2array(source:*):Array
		{
			var arr:Array = new Array;
			if(source != null)
			{
				for(var i:int = 0; i < source.length; ++i)
				{
					arr.push(source[i]);
				}
				return arr;
			}
			else
			{
				return null;
			}
		}
		
		
		public static function array2vector(source:Array, target:*):void
		{
			if(source != null && target != null)
			{
				for(var i:int = 0; i < source.length; ++i)
				{
					target.push(source[i]);
				}
			}
		}
	}
}