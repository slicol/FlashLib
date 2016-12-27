package com.tencent.fge.framework.mutexmanager.enum
{
	public class MutexResult
	{
		public static const SUCCESS:String = "SUCCESS";
		
		//	note: all failed enumeration must contain "FAILED" sub string
		public static const FAILED:String = "FAILED";		
		public static const FAILED_EXCLUSIVE:String = "FAILED_EXCLUSIVE";
		public static const FAILED_ORDER_ERROR:String = "FAILED_ORDER_ERROR";
		
		public static function isSuccess(result:String):Boolean
		{
			var index:int = result.search(FAILED);
			if(index == -1)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}
}