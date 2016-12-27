package com.tencent.fge.utils
{
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientGlowFilter;
	import flash.utils.Dictionary;

	public class FilterUtil
	{
		public function FilterUtil()
		{
		}
		
		public static function getDisableFilter():Array
		{
			return [new ColorMatrixFilter([
				0.34317, 0.57893, 0.0779, 0, 0,
				0.29317, 0.62893, 0.0779, 0, 0,
				0.29317, 0.57893, 0.1279, 0, 0,
				0, 0, 0, 1, 0])];
		}
		
		public static function getHighLightFilter():Array
		{
			return [new ColorMatrixFilter([
				2, 0, 0, 0, -50,
				0, 2, 0, 0, -50,
				0, 0, 2, 0, -50,
				0, 0, 0, 1, 0])];
		}
		
		public static function getBorderFilter(color:uint = 0, size:int = 1):Array
		{
			var ret:Array;
			
			switch(size)
			{
				case 2:
					ret = [new GlowFilter(color,1,2,2,180,2)];
					break;
				case 3:
					ret = [new GlowFilter(color,1,3,3,180,2)];
					break;
				case 1:
				default:
					ret = [new GlowFilter(color,1,2,2,8)];
			}
			
			return ret;
		}
		
		
		public static function getSelectedFilter(color:uint, size:int = 10, strength:Number = 2):Array
		{
			return [new GradientGlowFilter(0,0, [0xffffff, color], [0, 1], [0, 255], size, size, strength, 1, "outer", false)];
		}
		
		
		
		/*
		flash.filters 
		ColorMatrixFilter 
		
		
		matrix	property
		matrix:Array
		Language Version: 	ActionScript 3.0
		Runtime Versions: 	AIR 1.0, Flash Player 9
		An array of 20 items for 4 x 5 color transform. The matrix property cannot be changed by directly modifying its value (for example, myFilter.matrix[2] = 1;). Instead, you must get a reference to the array, make the change to the reference, and reset the value.
		
		The color matrix filter separates each source pixel into its red, green, blue, and alpha components as srcR, srcG, srcB, srcA. To calculate the result of each of the four channels, the value of each pixel in the image is multiplied by the values in the transformation matrix. An offset, between -255 and 255, can optionally be added to each result (the fifth item in each row of the matrix). The filter combines each color component back into a single pixel and writes out the result. In the following formula, a[0] through a[19] correspond to entries 0 through 19 in the 20-item array that is passed to the matrix property:
		
		redResult   = (a[0]  * srcR) + (a[1]  * srcG) + (a[2]  * srcB) + (a[3]  * srcA) + a[4]
		greenResult = (a[5]  * srcR) + (a[6]  * srcG) + (a[7]  * srcB) + (a[8]  * srcA) + a[9]
		blueResult  = (a[10] * srcR) + (a[11] * srcG) + (a[12] * srcB) + (a[13] * srcA) + a[14]
		alphaResult = (a[15] * srcR) + (a[16] * srcG) + (a[17] * srcB) + (a[18] * srcA) + a[19]
		
		public static function getSelectedFilter(color:uint, size:int = 10, strength:Number = 2):Array
			return [new GradientGlowFilter(0,0, [0xffffff, color], [0, 1], [0, 255], size, size, strength, 1, "outer", false)];
		Two optimized modes are available:
		Alpha only. When you pass to the filter a matrix that adjusts only the alpha component, as shown here, the filter optimizes its performance:
		1 0 0 0 0
		0 1 0 0 0
		0 0 1 0 0
		0 0 0 N 0  (where N is between 0.0 and 1.0)
		*/
	}
}