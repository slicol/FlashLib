package com.tencent.fge.engine.math
{
	public class Random
	{
		public function Random()
		{
		}
		
		static public function indexOfProbabilitySeries(series:Array, sumOfSeries:Number = 0.0):int 
		{
			if(series != null && series.length > 0)
			{
				if(sumOfSeries <= 0)
				{
					for(var i:int = 0; i < series.length; ++i)
					{
						sumOfSeries += series[i];
					}
				}
				
				var seed:Number = Math.random()*sumOfSeries;
				for(var j:int = 0; j < series.length; ++j)
				{
					sumOfSeries -= series[j];
					if(seed >= sumOfSeries)
					{
						return j;
					}
				}
			}
			return -1;
		}
	}
}