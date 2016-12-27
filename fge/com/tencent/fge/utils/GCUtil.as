package com.tencent.fge.utils
{
	import flash.net.LocalConnection;
	import flash.system.System;

	public class GCUtil
	{
		
		public static function gc(imminence:Number=0.75):void
		{
			/*
			if(FlashVerUtil.flashVer >= 11.0)
			{
				System.pauseForGCIfCollectionImminent(imminence);
			}
			else
			*/
			{
				
				try
				{
					new LocalConnection().connect("MoonSpirit");
					new LocalConnection().connect("MoonSpirit");
				}
				catch (e:Error) 
				{
					
				}
				
			}
			
		}
	}
}