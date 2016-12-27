package slicol.common
{
	
	
	import flash.utils.getTimer;
	
	
	public class FRateLimiter
	{
		static public function limitFrame(maxFPS:uint):void
		{
			var fTime:uint = 1000 / maxFPS;
			
			while(Math.abs(newT - oldT) < fTime)
			{
				newT = getTimer();
			}
			oldT = getTimer();
			
		}
		
		private static var oldT:uint = getTimer();
		private static var newT:uint = oldT;
	}

}