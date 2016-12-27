package com.tencent.fge.foundation.sdt.Common
{
	public interface SDListenerInterface
	{
		function onWarn(text:String):void;
		function onError(text:String):void;
	}
}