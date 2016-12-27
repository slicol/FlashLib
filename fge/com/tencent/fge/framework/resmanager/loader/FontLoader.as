package com.tencent.fge.framework.resmanager.loader
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.resmanager.ResDebuger;
	import com.tencent.fge.framework.resmanager.ResManager;
	import com.tencent.fge.framework.resmanager.interfaces.IAtomLoader;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	final internal class FontLoader extends Loader implements IAtomLoader
	{
		private var m_url:String = "";
		private var m_context:LoaderContext;
		private var m_ldrByte:ByteLoader = new ByteLoader;
		private var m_bytes:ByteArray;
		private var m_size:uint;
		
		public function get url():String{return m_url;}
		public function get bytes():ByteArray{return m_bytes;}
		public function get value():*{return this.content;}
		public function get size():uint{return m_size;}
		public function get usepack():Boolean{return false;}
		public function get applicationDomain():ApplicationDomain
		{
			if(this.loaderInfo != null) 
			{
				return this.loaderInfo.applicationDomain;
			}
			else if(m_context != null)
			{
				return m_context.applicationDomain;
			}
			else
			{
				return null;
			}
		}
		
		
		public function FontLoader()
		{
			super();
		}
		
		
		override public function load(request:URLRequest, context:LoaderContext=null):void
		{	
			Log.trace("FontLoader.load", request.url);
			
			m_url = request.url;
			m_context = context;
			
			if(m_context == null)
			{
				m_context = new LoaderContext(false, new ApplicationDomain);
			}
			
			
			if(ResManager.crossDomain)
			{
				m_ldrByte.addAllEventListener(onByteLoaderEvent);
				m_ldrByte.load(request);
			}
			else
			{
				super.load(request, m_context);
			}	
		}
		
		override public function unload():void
		{
			try
			{
				super.unload();
			}
			catch(e:Error)
			{
				Log.error("FontLoader.unload", e.errorID, e.toString());
			}
			
			m_ldrByte.removeAllEventListener(onByteLoaderEvent);
			if(m_ldrByte.url != null && m_ldrByte.url.length != 0)
			{
				m_ldrByte.unload();
			}
		}

		public function cleanMemory():void
		{
			//不需要
		}
		
		private function onByteLoaderEvent(e:Event):void
		{
			var ldr:ByteLoader = e.target as ByteLoader;
			
			if(e.type == Event.COMPLETE)
			{
				ldr.removeAllEventListener(onByteLoaderEvent);
				m_bytes = ldr.bytes;
				m_size = ldr.size;
				super.loadBytes(m_bytes, m_context);
			}
			else if(e.type == ProgressEvent.PROGRESS)
			{
				this.dispatchEvent(e);
			}
			else
			{
				ldr.removeAllEventListener(onByteLoaderEvent);
				this.dispatchEvent(e);
			}
		}
		
		public function addAllEventListener(listener:Function):void
		{
			this.contentLoaderInfo.addEventListener(Event.COMPLETE, listener);
			this.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, listener);
			this.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, listener);
			
			this.addEventListener(IOErrorEvent.IO_ERROR, listener);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, listener);
			this.addEventListener(ProgressEvent.PROGRESS, listener);
		}
		
		public function removeAllEventListener(listener:Function):void
		{
			this.contentLoaderInfo.removeEventListener(Event.COMPLETE, listener);
			this.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, listener);
			this.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, listener);	
			
			this.removeEventListener(IOErrorEvent.IO_ERROR, listener);
			this.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, listener);
			this.removeEventListener(ProgressEvent.PROGRESS, listener);
		}
		
	}
}