package com.tencent.fge.framework.resmanager.loader
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.resmanager.interfaces.IAtomLoader;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;


	final internal class SoundLoader extends Sound implements IAtomLoader
	{
		private var m_url:String = "";
		private var m_context:SoundLoaderContext;
		private var m_bytes:ByteArray;
		private var m_size:uint;

		public function get bytes():ByteArray{return m_bytes;}
		public function get value():*{return this;}
		public function get size():uint{return m_size;}
		public function get usepack():Boolean{return false;}

		public function get applicationDomain():ApplicationDomain
		{
			return ApplicationDomain.currentDomain;
		}

		
		public function SoundLoader()
		{
			super();
		}
		
		override public function load(stream:URLRequest, context:SoundLoaderContext=null):void
		{
			if(stream == null) return;
			
			m_url = stream.url;
			m_context = context;
			
			super.load(stream, m_context);		
		}
		
		public function unload():void
		{
			try
			{
				super.close();
			}
			catch(e:Error)
			{
				Log.error("SoundLoader.unload", e.errorID, e.toString());
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