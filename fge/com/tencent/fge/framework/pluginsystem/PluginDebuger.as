package com.tencent.fge.framework.pluginsystem
{
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.utils.Dictionary;

	public class PluginDebuger
	{
		private static var ms_timestats:Dictionary = new Dictionary;
		private static var ms_resstats:Dictionary = new Dictionary;
		
		internal static function timestats_create(plgid:String, time:int):void
		{
			var o:Object = ms_timestats[plgid];
			if(o == null)
			{
				o = new Object;
				o.plgid = plgid;
				ms_timestats[plgid] = o;
			}
			
			o.time_create = time;
		}
		
		internal static function timestats_init(plgid:String, time:int):void
		{
			var o:Object = ms_timestats[plgid];
			if(o == null)
			{
				o = new Object;
				o.plgid = plgid;
				ms_timestats[plgid] = o;
			}
			
			o.time_init = time;
		}
		
		internal static function resstats(plgid:String, resurl:String, size:int):void
		{
			var lst:Array = ms_resstats[plgid];
			if(lst == null)
			{
				lst = new Array;
				ms_resstats[plgid] = lst;
			}
			
			var o:Object = new Object;
			o.url = resurl;
			o.size = size;
			lst.push(o);
		}
		
		
		public static function dump():String
		{
			var lst:Array = new Array;
			var o:Object;
			var i:int;

			for each(o in ms_timestats)
			{
				o.time_all = o.time_create + o.time_init;
				lst.push(o);
			}
			
			lst.sortOn("time_all", Array.NUMERIC);
			
			var strRet:String = "";
			strRet += "##############################\n";
			strRet += "Dump All Plugin Time Used (" + lst.length + ")\n";
			strRet += "##############################\n";
			

			for(i = 0; i < lst.length; ++i)
			{
				o = lst[i];
				
				var tmp:String = "";
				if(i < 10)
				{
					tmp = "0";
				}
				
				strRet += tmp + i + ". " + o.time_all + "\t" + o.time_create + "\t" + o.time_init + "\t" + o.plgid  + "\n";	
			}
			
			strRet += "##############################\n";

			
			
			
			
			Log.debug("PluginDebuger.dump", "\n" + strRet);
			return strRet;
		}
	}
}