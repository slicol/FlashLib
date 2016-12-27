package com.tencent.fge.utils
{
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class ServerTime
	{
		private static const MODE_SERVER:String = "server";
		private static const MODE_CLIENT:String = "client";
		
		public static var ms_mode:String = MODE_SERVER;
		public static var ms_nTimeRunning:Number;
		public static var ms_nTimeServer:Number;
		public static var ms_bSync:Boolean = false;
		
		public function ServerTime()
		{
		}
		
		public static function sync(stdTimeMS:Number, utc:Boolean = true):void
		{
			if (!ms_bSync)
			{
				ms_bSync  = true;
				
				ms_nTimeServer = stdTimeMS;
				ms_nTimeRunning = getTimer();
			}
		}
		
		
		public static function getTime():Number
		{
			if (MODE_CLIENT == ms_mode)
			{
				var date:Date = new Date;
				return date.time;
			}
			else
			{
				return ms_nTimeServer + (getTimer() - ms_nTimeRunning);
			}
		}
		
		
		public static function getDate():Date
		{
			var date:Date = new Date(getTime());
			return date;
		}
		
		
	}
}