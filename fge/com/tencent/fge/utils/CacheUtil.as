package com.tencent.fge.utils
{
	import com.tencent.fge.framework.cachemanager.CacheManager;
	import com.tencent.fge.framework.cachemanager.data.CacheData;
	import com.tencent.fge.framework.cachemanager.interfaces.ICache;

	public class CacheUtil
	{
		public function CacheUtil()
		{
		}
		
		public static function hasFlagToday(cacheName:String, flagName:String):Boolean
		{
			var value:String = "";

			var cache:ICache = CacheManager.getCache("DailyFlag_" + cacheName);
			if(cache)
			{
				var cd:CacheData = cache.read(flagName);
				if(cd)
				{
					value = cd.data;
				}
			}				
		
			var date:String = DateUtil.formatDateToString(new Date, [".","."]);
			return value >= date;
		}
		
		public static function setFlagToday(cacheName:String, flagName:String):void
		{
			var value:String = DateUtil.formatDateToString(new Date, [".","."]);
			var cache:ICache = CacheManager.getCache("DailyFlag_" + cacheName);
			if(cache)
			{
				cache.write(flagName,0, value);
			}
		}		
	}
}