package com.tencent.fge.utils
{
	import flash.system.Capabilities;

	public class FlashVerUtil
	{
		private static var ms_flashVer:Number = 0;
		
		public function FlashVerUtil()
		{
		}
		
		public static function get flashVer():Number
		{
			if(ms_flashVer == 0)
			{
				var ma:int;
				var mi:int;
				
				var arrVer:Array = Capabilities.version.split(" ");
				if(arrVer.length > 1)
				{
					arrVer = arrVer[1].split(",");
					if(arrVer.length > 1)
					{
						ma = Number(arrVer[0]);
						mi = Number(arrVer[1]);
						ms_flashVer = ma + 0.1 * mi;
					}
				}				
			}
			
			return ms_flashVer;

		}
		
		
	}
}