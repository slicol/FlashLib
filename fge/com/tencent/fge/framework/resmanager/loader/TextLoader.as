package com.tencent.fge.framework.resmanager.loader
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.resmanager.interfaces.IAtomLoader;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;

	final internal class TextLoader extends URLLoader implements IAtomLoader
	{
		private var m_url:String = "";
		private var m_content:DisplayObject;
		private var m_bytes:ByteArray;
		private var m_size:uint;
		
		public function get url():String{return m_url;}
		public function get bytes():ByteArray{return null;}
		public function get size():uint{return m_size;}
		public function get value():*{return data;}
		public function get usepack():Boolean{return false;}
		public function get applicationDomain():ApplicationDomain
		{
			return ApplicationDomain.currentDomain;
		}
	
		public function TextLoader()
		{
			super();
			super.dataFormat = URLLoaderDataFormat.TEXT;
		}
		
		override public function load(request:URLRequest):void
		{
			m_url = request.url;
			super.load(request);
		}
		
		public function unload():void
		{
			try
			{
				super.close();
			}
			catch(e:Error)
			{
				Log.error("TextLoader.unload", e.errorID, e.toString());
			}
		}
		
		public function cleanMemory():void
		{
			//不需要
		}
		
		public function addAllEventListener(listener:Function):void
		{
			this.addEventListener(Event.COMPLETE, listener);
			this.addEventListener(IOErrorEvent.IO_ERROR, listener);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, listener);
			this.addEventListener(ProgressEvent.PROGRESS, listener);
		}
		
		public function removeAllEventListener(listener:Function):void
		{
			this.removeEventListener(Event.COMPLETE, listener);
			this.removeEventListener(IOErrorEvent.IO_ERROR, listener);
			this.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, listener);	
			this.removeEventListener(ProgressEvent.PROGRESS, listener);
		}
		
	}
}