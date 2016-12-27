package com.tencent.fge.utils
{
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;

	public class BroswerUtil
	{
		public static const WIN_TOP:String = "_top";
		public static const WIN_BLANK:String = "_blank";
		
		private static var ms_airi:AIRInterface = null;
		
		private static var ms_isInAir:Boolean = false;
		
		//如果不用AIR接口的话，就用原生的接口
		public static function useAIRInterface(airi:AIRInterface):void
		{
			ms_airi = airi;
		}
		
		/*
		public static function useAir():void
		{
			ms_isInAir = true;
		}
		*/
		
		public function BroswerUtil()
		{
		}
		
		public static function refresh():void
		{
//			if(ms_airi == null)
//			{
//				navigateToURL(new URLRequest(getHttpUrl()), "_top");
//
//			}
//			else
//			{
//				ms_airi.call("navigateToURL", getHttpUrl(), "_top");
//			}
			
//			ExternalInterface.call("window.open",getHttpUrl(), "_top");
			
			
			if(ms_isInAir)
			{
				ExternalInterface.call("eval","window.location.href='javascript:window.openWindow(\""+getHttpUrl()+"\",\""+"_top"+"\");'");
			}
			else
			{
				navigateToURL(new URLRequest(getHttpUrl()), "_top");
			}
			
		}
		
		
		public static function openIFrameURL(url:String):void
		{
			try
			{
				ExternalInterface.call("swfCall.openIfrUrl", url);
			}
			catch(e:Error)
			{
				navigateToURL(new URLRequest(url));
			}
			
			
		}
		
		public static function openURL(url:String, window:String = null):void
		{
//			if(ms_airi == null)
//			{
//				navigateToURL(new URLRequest(url), window);
//
//			}
//			else
//			{
//				ms_airi.call("navigateToURL", url, window);
//			}
			
//			var isInAir:Boolean = uint(ExternalInterface.call("eval","window.parent.isInAir")) == 1;
			if(ms_isInAir)
			{
				ExternalInterface.call("eval","window.location.href='javascript:window.openWindow(\""+url+"\",\""+window+"\");'");
			}
			else
			{
				navigateToURL(new URLRequest(url), window);
			}
			//
			//
			//ExternalInterface.call("window.open",url, window);
		}
		
		public static function getHttpUrl():String
		{
			var href:String = ExternalInterface.call("eval", "window.location.href");
			return href;
		}
		
		public static function setTitle(content:String):void
		{
			if(ms_airi == null)
			{
				ExternalInterface.call("eval","document.title='" + content + "';");
			}
			else
			{
				ms_airi.call("setTitle", content);
			}
		}
		
		
		public static function getTitle():String
		{
			return ExternalInterface.call("eval","document.title");
		}
		
		
		public static function getUrlArgs():Dictionary
		{
			var url:String = getHttpUrl();
			var i:int = url.indexOf("?");
			var mapArgs:Dictionary;
			
			if(i >= 0)
			{
				url = url.substr(i + 1);
				var lst:Array = url.split("&");
				for(i = 0; i < lst.length; ++i)
				{
					var arg:String = lst[i];
					if(arg.length != 0)
					{
						if(mapArgs == null)
						{
							mapArgs = new Dictionary;
						}
						
						var j:int = arg.indexOf("=");
						if(j < 0)
						{
							mapArgs[arg] = arg;
						}
						else
						{
							var argName:String = arg.substr(0, j);
							var argValue:String = arg.substr(j + 1);
							mapArgs[argName] = argValue;
						}
					}
					
				}
			}
			
			return mapArgs;
		}
	}
}