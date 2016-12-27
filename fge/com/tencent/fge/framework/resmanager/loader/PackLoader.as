package com.tencent.fge.framework.resmanager.loader
{
	import apparat.memory.Memory;
	
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.resmanager.ResDebuger;
	import com.tencent.fge.framework.resmanager.ResManager;
	import com.tencent.fge.framework.resmanager.ResUtil;
	import com.tencent.fge.framework.resmanager.data.ResType;
	import com.tencent.fge.framework.resmanager.interfaces.IAtomLoader;
	import com.tencent.fge.utils.FlashVerUtil;
	
	import flash.display.Loader;
	import flash.errors.MemoryError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	final internal class PackLoader extends Loader implements IAtomLoader
	{
		private var m_url:String = "";
		private var m_context:LoaderContext;
		private var m_ldrByte:ByteLoader = new ByteLoader;
		private var m_bytes:ByteArray;
		private var m_size:uint;
		private var m_md5:String = "";
		private var m_needmd5:Boolean = true;
		
		public function get url():String{return m_url;}
		public function get bytes():ByteArray{return m_bytes;}
		public function get value():*{return this.content;}
		public function get size():uint{return m_size;}
		public function get usepack():Boolean{return m_ldrByte.usepack;}
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
		
		
		public function PackLoader(md5:String)
		{
			super();
			m_md5 = md5;
		}
		
		
		override public function load(request:URLRequest, context:LoaderContext=null):void
		{	
			m_url = request.url;
			Log.trace("PackLoader.load", m_url);
			
			m_context = context;
			m_needmd5 = m_context != null && ResManager.useVerManager == 1;
			
			//关闭MD5校验
			m_needmd5 = false;
			
			if(m_context == null)
			{
				m_context = new LoaderContext(false, new ApplicationDomain());
			}
			
			m_ldrByte.addAllEventListener(onByteLoaderEvent);
			m_ldrByte.load(request);
		}
		
		override public function unload():void
		{
			try
			{
				//super.unloadAndStop();
				super.unload();
			}
			catch(e:Error)
			{
				Log.error("PackLoader.unload", e.errorID, e.toString());
			}
			
			m_ldrByte.removeAllEventListener(onByteLoaderEvent);
			if(m_ldrByte.url != null && m_ldrByte.url.length != 0)
			{
				m_ldrByte.unload();
			}
		}
		
		public function cleanMemory():void
		{
			if(this.contentLoaderInfo)
			{
				if(FlashVerUtil.flashVer >= 11.4)
				{
					return;
				}
				
				var bytes:ByteArray = this.contentLoaderInfo.bytes;
				
				if(bytes)
				{
					bytes.position = 0;
					
					var preMemory: ByteArray = ApplicationDomain.currentDomain.domainMemory;
					Memory.select(bytes);
					for(var i:int = 0, n: int = 40; i < n; ++i)
					{
						Memory.writeByte(0, i);
					}
					Memory.select(preMemory);
				}
				
			}
		}
		
		private function onByteLoaderEvent(e:Event):void
		{
			var ldr:ByteLoader = e.target as ByteLoader;
			if(e.type == Event.COMPLETE)
			{
				ldr.removeAllEventListener(onByteLoaderEvent);
				m_bytes = ldr.bytes;
				m_size = ldr.size;
				
				switch(ldr.type)
				{
					case ResType.FLASH:
						{
							if(m_needmd5)
							{
								if(m_md5 != "" && ldr.md5 == m_md5)
								{
									super.loadBytes(m_bytes, m_context);
									ldr.cleanMemory();
								}
								else
								{
									ldr.cleanMemory();
									
									var evt:SecurityErrorEvent = 
										new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR);
									this.dispatchEvent(evt);
								}
							}
							else
							{
								super.loadBytes(m_bytes, m_context);
								ldr.cleanMemory();
							}

						}
						break;
					case ResType.FONT:
					case ResType.IMAGE:
						super.loadBytes(m_bytes, new LoaderContext(false, new ApplicationDomain()));
						break;
					default:
						break;
				}
			}
			else if(e.type == ProgressEvent.PROGRESS)
			{
				this.dispatchEvent(e);
			}
			else
			{
				Log.error("PackLoader.onByteLoaderEvent", m_url);
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