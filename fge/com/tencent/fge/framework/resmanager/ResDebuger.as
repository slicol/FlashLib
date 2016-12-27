package com.tencent.fge.framework.resmanager
{
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;

	public class ResDebuger
	{		
		private var m_name:String;
		private var m_domain:ApplicationDomain;
		
		public function ResDebuger(name:String, domain:ApplicationDomain)
		{
			m_name = name;
			m_domain = domain;
		}
		
		public static function dump(lstManager:Dictionary):String
		{
			var lst:Array = new Array;
			var mgr:ResManager;
			var i:int;
			
			for each(mgr in lstManager)
			{
				lst.push(mgr);
			}
			
			
			var strRet:String = "";
			
			strRet += "##############################\n";
			strRet += "Dump All ResManager (" + lst.length + ")\n";
			strRet += "##############################\n";

			for(i = 0; i < lst.length; ++i)
			{
				mgr = lst[i];
				strRet += i + ". " + mgr.name + "[" + mgr.domain + "]\n";	
			}
			
			strRet += "##############################\n";
			
			var strTmp:String = strRet;
			
			for(i = 0; i < lst.length; ++i)
			{
				mgr = lst[i];
				strRet += mgr.dump() + "\n";
			}
			
			strRet += "##############################\n";
			
			Log.debug("ResDebuger.dump", "\n" + strTmp);
			return strRet;
		}
		
		
		public function dump(mapResGroup:Dictionary, mapResHelper:Dictionary):String
		{
			var lst:Array = new Array;
			var i:int;

			var strRet:String = "";
			
			strRet += "==============================\n";
			strRet += "Dump: " + m_name + "[" + m_domain + "]\n";
			strRet += "==============================\n";
			

			var grp:ResGroup;
			for each(grp in mapResGroup)
			{
				lst.push(grp);
			}
			
			strRet += "------------------------------\n";
			strRet += "ResGroup (" + lst.length + ")\n";
			strRet += "------------------------------\n";
			
			for(i = 0; i < lst.length; ++i)
			{
				grp = lst[i];
				strRet += i + ". " + grp.name + "\n";
			}
			
			
			
			
			
			lst = new Array;
			var hlp:ResHelper;
			for each(hlp in mapResHelper)
			{
				lst.push(hlp);
			}
			
			strRet += "------------------------------\n";
			strRet += "ResFile (" + lst.length + ")\n";
			strRet += "------------------------------\n";
			
			for(i = 0; i < lst.length; ++i)
			{
				hlp = lst[i];
				strRet += i + ". " + hlp.toDumpString() + "\n";
			}
			
			Log.debug("ResDebuger.dump", "\n" + strRet);
			return strRet;
		}
		
		
		
		
		

	}
}