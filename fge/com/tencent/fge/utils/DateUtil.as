package com.tencent.fge.utils
{
	public class DateUtil
	{
		public static const SP_DATE:Array = [".","."];
		public static const SP_TIME:Array = [":",":"];
		public static const SP_FULL:Array = [".",".","_",":",":"];
		
		public function DateUtil()
		{
		}
		
		
		/**
		 * 格式化日期为字符串，比如：1985-02-28
		 **/
		public static function formatDateToString(date:Date, sp:Array=null):String
		{
			if(sp == null)
			{
				sp = ["-","-"];
			}
			var ret:String = date.fullYear + sp[0] + 
				num2string(date.month + 1) + sp[1] + 
				num2string(date.date); 

			return ret;
		}
		
		/**
		 * 格式化当日时间为字符串，比如：12:12:12
		 **/
		public static function formatTimeToString(date:Date, sp:Array=null, hasSec:Boolean = true):String
		{
			if(sp == null)
			{
				sp = [":",":"];
			}
			
			var ret:String;
			
			if(hasSec)
			{
				ret = num2string(date.hours) + sp[0] + 
					num2string(date.minutes) + sp[1] + 
					num2string(date.seconds);
			}
			else
			{
				ret = num2string(date.hours) + sp[0] + 
					num2string(date.minutes);
			}
			
			return ret;
		}
		
		
		/**
		 * 格式化整个时间为字符串，比如：1985-02-28 12:12:12
		 **/
		public static function formatToString(date:Date, sp:Array = null):String
		{
			if(sp == null)
			{
				sp = ["-","-"," ",":",":"];
			}
			
			var ret:String = date.fullYear + sp[0] + 
				num2string(date.month + 1) + sp[1] + 
				num2string(date.date) + sp[2] + 
				num2string(date.hours) + sp[3] + 
				num2string(date.minutes) + sp[4] + 
				num2string(date.seconds);
			
			return ret;
		}
		
		
		/**
		 * 将秒转换为日期时长 比如：2天23小时15分钟45秒 对于“天”是向上取整
		 **/
		public static function formatSecondToStringEx(second:int):String
		{
			second = second < 0 ? 0 : second;
			
			var ret:String = "";
			
			if(second > 86400) // 大于24小时
			{
				ret = Math.ceil(second / 86400) + "天";
			}
			else if(second > 3600) // 大于60分钟
			{
				ret = Math.round(second / 3600) + "小时";
			}
			else if(second > 60) // 大于60秒
			{
				ret = Math.round(second / 60) + "分钟";
			}
			else
			{
				ret = second + "秒";
			}
			
			return ret;
		}
		
		
		/**
		 * 将秒转换为日期时长 比如：2天23小时15分钟45秒 对于“天”是向下取整
		 **/
		public static function formatSecondToString(second:int):String
		{
			second = second < 0 ? 0 : second;
			
			var ret:String = "";
			
			if(second > 86400) // 大于24小时
			{
				ret = Math.round(second / 86400) + "天";
			}
			else if(second > 3600) // 大于60分钟
			{
				ret = Math.round(second / 3600) + "小时";
			}
			else if(second > 60) // 大于60秒
			{
				ret = Math.round(second / 60) + "分钟";
			}
			else
			{
				ret = second + "秒";
			}
			
			return ret;
		}
		
		public static function num2string(num:int):String
		{
			return num < 10 ? "0" + num.toString() : num.toString();
		}
	}
}