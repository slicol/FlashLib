package com.tencent.fge.engine.bpe
{
	
	internal final class BpeInterval 
	{
		
		internal var min:Number;
		internal var max:Number;
		
		public function BpeInterval(min:Number, max:Number) 
		{
			this.min = min;
			this.max = max;
		}
		
		internal function toString():String 
		{
			return (min + " : " + max);
		}
	}
}