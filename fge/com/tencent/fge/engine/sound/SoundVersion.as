package com.tencent.fge.engine.sound
{
	import com.tencent.fge.framework.resmanager.ResManager;
	import com.tencent.fge.framework.vermanager.VersionData;
	import com.tencent.fge.framework.vermanager.VersionManager;

	public class SoundVersion
	{
		
		
		public static function initialize():void
		{
			
		}
		
		public static function getRealUrl(url:String):String
		{
			if(ResManager.useVerManager == ResManager.VM_MANAGED)
			{
				var vd:VersionData = VersionManager.getVersionDataEx(url);
				if(!vd)
				{
					return url;
				}
				else
				{
					return vd.realurl;
				}
			}
			else 
			{
				return url;
			}
			
		}
	}
}