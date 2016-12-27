package com.tencent.fge.debug
{
	public class Assert
	{
		public function Assert()
		{
		}
		
		static public function expr(value:Boolean, ... arg):void
		{
			if(!value)
			{
				throw("断言错误："+ arg);
			}
		}
	}
}