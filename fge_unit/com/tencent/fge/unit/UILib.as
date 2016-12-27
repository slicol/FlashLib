package com.tencent.fge.unit
{
	import com.tencent.fge.foundation.signals.Signal;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	
	
	public class UILib
	{
		private static var ms_mapUILib:Dictionary = new Dictionary;
		
		public static function getUILib(path:String):UILib
		{
			var lib:UILib = ms_mapUILib[path];

			if(!lib)
			{
				lib = new UILib(path);
				ms_mapUILib[path] = lib;
			}
			
			if(lib.complete)
			{
				lib.onComplete.dispatchAsy();
			}
			
			return lib;
		}
		
		
		
		
		public var onComplete:Signal = new Signal;
		private var m_source:*;
		private var m_complete:Boolean = false;
		
		public function UILib(source:*):void
		{
			if(source is String)
			{
				var ldr:Loader = new Loader;
				ldr.load(new URLRequest(source));
				ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onUIComplete);
			}
			else
			{
				m_source = source;
				onComplete.dispatch();
			}
		}
		
		public function get complete():Boolean
		{
			return m_complete;
		}
		
		private function onUIComplete(e:Event):void
		{
			m_complete = true;
			var ldr:Loader = (e.target as LoaderInfo).loader;
			m_source = ldr.contentLoaderInfo.applicationDomain;
			onComplete.dispatch();
		}
		
		
		public function getDefinition(name:String):Class
		{
			if(m_source is ApplicationDomain)
			{
				return m_source.getDefinition(name) as Class;
			}
			else
			{
				return m_source[name] as Class;
			}
		}
		
		
		public function getInstance(name:String):*
		{
			var cls:Class = getDefinition(name);
			if(cls)
			{
				return new cls;
			}
			return null;
		}
		
		public function getMovieClip(name:String):MovieClip
		{
			return getInstance(name);
		}
		
		public function getBitmap(name:String):Bitmap
		{
			return getInstance(name);
		}
	}
}