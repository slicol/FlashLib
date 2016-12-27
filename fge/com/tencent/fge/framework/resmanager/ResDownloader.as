package com.tencent.fge.framework.resmanager
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class ResDownloader extends EventDispatcher
	{
		public function ResDownloader(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}