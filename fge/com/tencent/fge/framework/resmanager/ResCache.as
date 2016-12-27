package com.tencent.fge.framework.resmanager
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	public class ResCache
	{
		public static const CLOSE:int = 0;
		public static const READ_ONLY:int = 1;
		public static const READ_WRITE:int = 2;
		
		private static var ms_state:int = 0;
		private static var ms_so:SharedObject;
		private static var ms_sodata:Object;
		private static var ms_version:Object;
		private static var ms_name:String = "";
		private static var ms_readable:Boolean = false;
		private static var ms_writeable:Boolean = false;
		
		private static var ms_timAsy:Timer = new Timer(100, 1);
		private static var ms_lstAsy:Vector.<AsyHelper>

		public function ResCache()
		{
		}
		
		public static function get state():int{return ms_state;}
		public static function get readable():Boolean{return ms_readable;}
		public static function get writeable():Boolean{return ms_writeable;}
		

		public static function open(name:String, state:int = 1):void
		{
			if(state > 2 && state < 1)
			{
				state = 1;
			}
			
			ms_readable = true;
			ms_writeable = state == 2;
			
			ms_state = state;
			ms_name = name;
			
			ms_so = SharedObject.getLocal(ms_name);
			ms_sodata = ms_so.data;
			ms_version = ms_sodata["version"];
			
			if(ms_version == null)
			{
				ms_version = new Object;
				ms_sodata["version"] = ms_version;
			}
			
			ms_timAsy.addEventListener(TimerEvent.TIMER, onTimer);
			ms_lstAsy = new Vector.<AsyHelper>;
		}
		
		public static function close():void
		{
			ms_state = CLOSE;
			ms_version = null;
			ms_sodata = null;
			ms_so = null;
			ms_readable = false;
			ms_writeable = false;
			
			ms_timAsy.removeEventListener(TimerEvent.TIMER, onTimer);
			
			handlerAsy();
		}
		
		public static function flush(name:String):void
		{
			var so:SharedObject = SharedObject.getLocal(name);
			so.flush();
		}
		
		
		public static function clear():void
		{
			if(ms_version && ms_sodata)
			{
				for(var url:String in ms_version)
				{
					var realUrl:String = ms_version[url];
					ms_sodata[realUrl] = null;
				}
			}
		}
		
		public static function dump():String
		{
			var str:String = "";
			str += "\n===============Begin==============";
			str += "\n name: " + ms_name ;
			str += "\nstate: " + ms_state;
			str += "\n----------------------------------";
			if(ms_version && ms_sodata)
			{
				for(var url:String in ms_version)
				{
					var realUrl:String = ms_version[url];
					var data:ByteArray = ms_sodata[realUrl];
					
					if(data)
					{
						str += "\n[" + data.length + "] " + url +" , "+realUrl;
					}
					else
					{
						str += "\n[不存在!] " +  url +" , "+realUrl;
					}
				}
			}
			str += "\n================End===============\n";
			return str;
		}
		
		public static function getVersionList():Object
		{
			return ms_version;
		}
		
		public static function readAsy(realUrl:String, listener:Function):Boolean
		{
			var data:ByteArray = read(realUrl);
			if(data != null)
			{
				var hlp:AsyHelper = new AsyHelper;
				hlp.realUrl = realUrl;
				hlp.data = data;
				hlp.listener = listener;
				
				ms_lstAsy.push(hlp);
				ms_timAsy.start();
				
				return true;
			}
			return false;
		}
		
		private static function onTimer(e:Event):void
		{
			handlerAsy();
		}
		
		private static function handlerAsy():void
		{
			for(var i:int = 0; i < ms_lstAsy.length; ++i)
			{
				var hlp:AsyHelper = ms_lstAsy[i];
				hlp.listener(hlp.data);
				hlp.data = null;
				hlp.listener = null;
			}
			
			ms_lstAsy = new Vector.<AsyHelper>;
		}
		
		public static function read(realUrl:String):ByteArray
		{
			if(ms_sodata)
			{
				var data:ByteArray = ms_sodata[realUrl];
				return data;
			}
			return null;
		}
		
		public static function write(url:String, realUrl:String, data:ByteArray):void
		{
			if(ms_state == READ_WRITE && realUrl != null && realUrl != "")
			{
				var oldRealUrl:String = ms_version[url];
				if(oldRealUrl != realUrl)
				{
					ms_version[url] = realUrl;
					ms_sodata[oldRealUrl] = null;
					ms_sodata[realUrl] = data;
				}
			}
			
		}
		
		
	}
}
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

class AsyHelper extends EventDispatcher
{
	public var realUrl:String = "";
	public var data:ByteArray = null;
	public var listener:Function = null;
}