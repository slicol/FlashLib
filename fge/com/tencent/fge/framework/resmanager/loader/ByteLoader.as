package com.tencent.fge.framework.resmanager.loader
{
	import by.blooddy.crypto.MD5;
	
	import com.tencent.fge.codec.swf.SWFFile;
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.resmanager.ResCache;
	import com.tencent.fge.framework.resmanager.ResManager;
	import com.tencent.fge.framework.resmanager.ResUtil;
	import com.tencent.fge.framework.resmanager.data.ResType;
	import com.tencent.fge.framework.resmanager.interfaces.IAtomLoader;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;

	final internal class ByteLoader extends URLLoader implements IAtomLoader
	{
		private var m_url:String = "";
		private var m_usepack:Boolean = false;
		private var m_type:String = "";
		private var m_bytes:ByteArray = null;
		
		public function get url():String{return m_url;}
		public function get size():uint{return bytesTotal;}
		public function get value():*{return bytes;}
		public function get type():String{return m_type;}
		public function get usepack():Boolean{return m_usepack;}

		
		public function get bytes():ByteArray
		{
			m_bytes = data;
			
			if(m_usepack)
			{
				m_usepack = false;
				var func:Function = ResManager.libx["0"];
				if(func != null)
				{
					var o:Object = func(data);
					if(o)
					{
						m_type = ResType.getTypeFromPath("x." + o["extension"]);
						m_bytes = o["bytes"];
						m_usepack = true;
					}
					
				}
			}
			
			return m_bytes;
		}
		
		
		public function get applicationDomain():ApplicationDomain
		{
			return ApplicationDomain.currentDomain;
		}		
		
		public function ByteLoader()
		{
			super();
			super.dataFormat = URLLoaderDataFormat.BINARY;
		}
		
		override public function load(request:URLRequest):void
		{
			m_url = request.url;
			m_type = ResType.getTypeFromPath(m_url);
			m_usepack = (m_type == ResType.PACK);
			
			if(ResCache.readable)
			{
				if(ResCache.readAsy(m_url, onResCacheAsyCallBack))
				{
					return;
				}
			}
			
			if(ResCache.writeable)
			{
				this.addEventListener(Event.COMPLETE, onResCompleteForCache);
			}
			
			super.load(request);
		}
		
		private function onResCacheAsyCallBack(data:ByteArray):void
		{
			this.data = data;
			var evt:Event = new Event(Event.COMPLETE);
			this.dispatchEvent(evt);
		}
		
		private function onResCompleteForCache(e:Event):void
		{
			this.removeEventListener(Event.COMPLETE, onResCompleteForCache);
			ResCache.write(m_url, m_url, data);
		}
		
		public function unload():void
		{
			try
			{
				super.close();
			}
			catch(e:Error)
			{
				Log.warn("ByteLoader.unload", e.errorID, e.toString());
			}
		}
		
		public function cleanMemory():void
		{
			if(m_bytes)
			{
				m_bytes.position = 0;
				for(var i:int = 0, n: int = 40; i < n; ++i)
				{
					m_bytes.writeByte(0);
				}
				m_bytes.clear();
			}
		}
		

		public function get md5():String	
		{
			if(m_bytes)
			{
				if(m_url.indexOf("plugin_") >= 0)
				{
					m_bytes.position = 0;
					var rawBytes: ByteArray = SWFFile.uncompress(m_bytes);
					if (rawBytes.length > 1000)
					{
						var mainBytes:ByteArray = new ByteArray;
						rawBytes.position = 1000;
						rawBytes.readBytes(mainBytes);
						mainBytes.position = 0;
						return MD5.hashBytes(mainBytes);
					}
					rawBytes.position = 0;
					return MD5.hashBytes(rawBytes);
				}
				m_bytes.position = 0;
				return MD5.hashBytes(m_bytes);
			}
			return "";
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