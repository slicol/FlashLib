package com.tencent.fge.utils
{
	public class VectorUtil
	{
		public function VectorUtil()
		{
		}
		
		public static function toArray(vector:*):Array
		{
			if(vector == null)
			{
				return null;
			}
			
			var ret:Array = new Array;
			
			for(var i:int = 0; i < vector.length; ++i)
			{
				ret.push(vector[i]);
			}
			
			return ret;
		}
			
		
		public static function toString(vector:*):String
		{
			var ret:String;
			if(null == vector)
			{
				return ret;
			}
			else
			{
				ret = "";
				
				var tmp:*;
				var i:int = 0;
				if(vector.length > 0)
				{
					tmp =  vector[0];
					ret = tmp.toString();
				}
				
				for(i = 1; i < vector.length; ++i)
				{
					tmp = vector[i];
					ret += "," + tmp.toString();
				}
				return "[" + ret + "]";
			}
		}
		
		public static function sortAscending(x:*, y:*):Number
		{
			if(x < y)
			{
				return -1;
			}
			else if(x > y)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}
		
		public static function sortDescending(x:*, y:*):Number
		{
			if(x < y)
			{
				return 1;
			}
			else if(x > y)
			{
				return -1;
			}
			else
			{
				return 0;
			}
		}
	}
}