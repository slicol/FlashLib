/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   LogConfig.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2009-1
#   Comment     :   日志系统配置管理，管理外部配置文件。其主要功能是通过一个配置文件
 * 					开控制日志的开关，控制粒度精确到类。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-1 文件创建 
 * 					
#
*************************************************************************/

package com.tencent.fge.foundation.log.client
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class LogConfig extends EventDispatcher
	{
		public static const EVENT_LOAD_COMPLETE:String = "EventLoadComplete";
		public static const EVENT_LOAD_ERROR:String = "EventLoadError";
		
		//配置加载相关
		private var urlLoader:URLLoader;
		private var urlConfig:String = "Debug.xml";
		private var cfgList:Dictionary;
		
		private var allError:Boolean = true;
		private var allTrace:Boolean = false;
		private var allDebug:Boolean = true;
		private var allThrow:Boolean = true;
		private var allWarn:Boolean = true;
		private var outTarget:int = 0;
		

		public function LogConfig()
		{
			urlLoader = new URLLoader;
		}
		
		public function load(url:String = null):Boolean
		{	
			if(url == null || url.length == 0)
			{
				url = this.urlConfig;
			}

			urlLoader.load(new URLRequest(url));
			urlLoader.addEventListener(Event.COMPLETE,onConfigLoaded);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			return true;
		}
		

		
		private function unload():void
		{
			urlLoader.removeEventListener(Event.COMPLETE,onConfigLoaded);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,onError);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
		}
		
		public function loadContent(content:String):Boolean
		{
			var tmpXML:XML;
		
			try
			{
				tmpXML = new XML(content);
			}
			catch(e:Error)
			{
				return false;
			}
			
			
			var xmlList:XMLList = tmpXML.children();
			var len:int = xmlList.length();
			
			this.cfgList = new Dictionary;
			this.allError = tmpXML.@error != "false";
			this.allTrace = tmpXML.@trace == "true";
			this.allDebug = tmpXML.@debug != "false";
			this.allThrow = tmpXML.@exthrow == "true";
			this.allWarn = tmpXML.@warn != "false";
			this.outTarget = tmpXML.@target;
			
			for(var i:int = 0; i < len; ++i)
			{
				var name:String = xmlList[i].@name;
				var error:Boolean = xmlList[i].@error != "false";
				var trace:Boolean = xmlList[i].@trace == "true";
				var debug:Boolean = xmlList[i].@debug != "false";
				var warn:Boolean = xmlList[i].@warn != "false";
				var exthrow:Boolean = xmlList[i].@exthrow == "true";
				
				var o:Object = new Object;
				o.name = name;
				o.error = error;
				o.trace = trace;
				o.debug = debug;
				o.exthrow = exthrow;
				o.warn = warn;
				
				this.cfgList[o.name] = o;
			}
			
			return true;
		}
		
		
		private function onConfigLoaded(e:Event):void
		{
			var ret:Boolean = loadContent(e.currentTarget.data);
			unload();
			
			if(ret)
			{
				this.dispatchEvent(new Event(EVENT_LOAD_COMPLETE));
			}
			else
			{
				this.dispatchEvent(new Event(EVENT_LOAD_ERROR));
			}
		}
		
		private function onError(e:Event):void
		{
			unload();
			this.dispatchEvent(new Event(EVENT_LOAD_ERROR));
		}

		public function logError(clsName:String=null):Boolean
		{
			if(clsName==null || this.cfgList == null)
			{
				return this.allError;
			}
			else
			{
				var o:Object = this.cfgList[clsName];
				if(o==null)
				{
					o = this.cfgList["Default"];
				}
				if(o==null)
				{
					return this.allError;
				}
				else
				{
					return o.error;
				}
			}
		}
		
		
		public function logWarn(clsName:String=null):Boolean
		{
			if(clsName==null || this.cfgList == null)
			{
				return this.allWarn;
			}
			else
			{
				var o:Object = this.cfgList[clsName];
				if(o==null)
				{
					o = this.cfgList["Default"];
				}
				if(o==null)
				{
					return this.allWarn;
				}
				else
				{
					return o.warn;
				}
			}
		}
		
		
		public function logTrace(clsName:String=null):Boolean
		{
			if(clsName==null || this.cfgList == null)
			{
				return this.allTrace;
			}
			else
			{
				var o:Object = this.cfgList[clsName];
				if(o==null)
				{
					o = this.cfgList["Default"];
				}
				if(o==null)
				{
					return this.allTrace;
				}
				else
				{
					return o.trace;
				}
			}
		}
		
		public function logDebug(clsName:String=null):Boolean
		{
			if(clsName==null || this.cfgList == null)
			{
				return this.allDebug;
			}
			else
			{
				var o:Object = this.cfgList[clsName];
				if(o==null)
				{
					o = this.cfgList["Default"];
				}
				if(o==null)
				{
					return this.allDebug;
				}
				else
				{
					return o.debug;
				}
			}
		}
		
		public function logThrow(clsName:String=null):Boolean
		{
			if(clsName==null || this.cfgList == null)
			{
				return this.allThrow;
			}
			else
			{
				var o:Object = this.cfgList[clsName];
				if(o==null)
				{
					o = this.cfgList["Default"];
				}
				if(o==null)
				{
					return this.allThrow;
				}
				else
				{
					return o.exthrow;
				}
			}
		}
		
		public function logOutTarget():int
		{
			return this.outTarget;
		}
		
		protected var version:String = "1.0.0";
		protected var author:String = "slicoltang,slicol@qq.com";
		protected var copyright:String = "腾讯计算机系统有限公司";	     		
	}
}