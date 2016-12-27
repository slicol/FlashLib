package com.tencent.fge.framework.resmanager
{
	import com.tencent.fge.events.LoadEvent;
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.resmanager.data.ResState;
	import com.tencent.fge.framework.resmanager.data.ResType;
	import com.tencent.fge.framework.resmanager.events.ResEvent;
	import com.tencent.fge.framework.resmanager.events.ResGroupEvent;
	import com.tencent.fge.framework.resmanager.loader.ResLoader;
	import com.tencent.fge.utils.StringUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.sampler.getSize;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	[Event(name = "loadSuccess", type="com.tencent.fge.framework.resmanager.events.ResEvent")]
	[Event(name = "loadFailed", type="com.tencent.fge.framework.resmanager.events.ResEvent")]
	[Event(name = "unload", type="com.tencent.fge.framework.resmanager.events.ResEvent")]
	
	public class ResHelper extends EventDispatcher
	{
		private var m_path:String = "";
		private var m_file:ResFile;
		private var m_ldr:ResLoader;
		private var m_type:String = "";
		private var m_state:String = ResState.NULL;
		private var m_timAsy:Timer;
		private var m_ref:int = 0;

		public function ResHelper(path:String, type:String)
		{
			super();
			m_path = path;
			m_type = type;
			m_ldr = new ResLoader(type);
			m_file = new ResFile();
			m_file.path = path;
			m_file.type = type;
		}		
		
		public function get file():ResFile{return m_file;}
		public function get path():String{return m_path;}
		public function isNull():Boolean{return m_ref == 0;}
		
		internal function addRef():void
		{
			++m_ref;
		}
		
		//加载资源
		internal function loadRes(ver:String, domain:ApplicationDomain = null):void
		{
			//在这里进行加载分流：一部分从Cache里加载，一部分从Server加载。
			//Cache又分IECache和FlashCache;
			//现在这里统一从Server加载
			
			++m_ref;
			Log.trace("ResHelper.loadRes", "m_ref " + this.m_ref + " path " + path);	
			switch(m_state)
			{
			case ResState.LOAD_FAILED:
				//这里只是一个保险措施
				m_ldr.unload();
				//继续向下执行
			case ResState.NULL:
				m_ldr.addAllEventListener(onLoaderEvent);
				m_ldr.load(m_path, ver, domain);
				m_state = ResState.LOADING;
				break;
			case ResState.LOADING:
				break;
			case ResState.LOAD_SUCCESS:
				if(m_timAsy == null)
				{
					m_timAsy = new Timer(100,1);
					m_timAsy.addEventListener(TimerEvent.TIMER, onAsyTimer);
				}
				if(!m_timAsy.running)
				{	
					m_timAsy.start();
				}
				break;
			default:break;
			}
		}
		
		internal function unloadRes(force:Boolean = false):void
		{
			
			if(force)
			{
				m_ref = 0;
			}
			else
			{
				--m_ref;
			}
			
			if(m_ref <= 0)
			{
				m_ref = 0;
				
				m_ldr.unload();
				cleanupContent();
			}
			Log.trace("ResHelper.unloadRes", "m_ref " + this.m_ref + " path " + path);	
		}
		
		
		private function cleanupContent():void
		{
			Log.trace("ResHelper.cleanupContent", "instance " + this.path);	
			if(m_file == null) 
			{
				return;
			}

			var c:* = m_file.content;
			m_file.content = null;
			if(c is Bitmap)
			{
				Bitmap(c).bitmapData.dispose();
				Bitmap(c).bitmapData = null;
			}
			else if(c is BitmapData)
			{
				BitmapData(c).dispose();
			}			
			else if(c is MovieClip)
			{
				MovieClip(c).stop();
			}
			else if(c != null)
			{
				try
				{
					if(c.hasOwnProperty("cleanup"))
					{
						c.cleanup();
					}
				}
				catch(e:Error)
				{
					Log.error("ResHelper.cleanupContent", "catch error : instance " + this.path);	
				}
			}

			
			if(m_file.bytes != null)
			{
				m_file.bytes.clear();
			}
			m_file.bytes = null;
			
			m_file.domain = null;
		}
		
		
		private function onAsyTimer(e:Event):void
		{
			var evt:ResEvent;
			
			Log.trace("ResHelper.onAsyTimer", "path " + this.path);	
			if(m_state == ResState.LOAD_SUCCESS)
			{
				evt = new ResEvent(ResEvent.LOAD_SUCCESS);
				evt.path = m_path;
				this.dispatchEvent(evt);
			}
			else if(m_state == ResState.LOAD_FAILED)
			{
				evt = new ResEvent(ResEvent.LOAD_FAILED);
				evt.path = m_path;
				this.dispatchEvent(evt);
			}
		}
		
		private function onLoaderEvent(e:Event):void
		{			
				
			var evt:ResEvent;
			if(e.type == Event.COMPLETE)
			{
				m_ldr.removeAllEventListener(onLoaderEvent);
				
				m_file.path = m_path;
				m_file.type = m_ldr.type;
				m_file.ver = m_ldr.ver;
				m_file.content = m_ldr.value;
				m_file.bytes = m_ldr.bytes;
				m_file.size = m_ldr.size;
				m_file.memory = getSize(m_file.content);
				
				m_file.domain = m_ldr.applicationDomain;
				
				Log.trace("ResHelper.onLoaderEvent", e.type, m_path, m_file.size, m_file.memory);	
				
				m_state = ResState.LOAD_SUCCESS;
				evt = new ResEvent(ResEvent.LOAD_SUCCESS);
			}
			else if(e.type == ProgressEvent.PROGRESS)
			{
				evt = new ResEvent(ResEvent.LOAD_PROGRESS);
				evt.bytesLoaded = ProgressEvent(e).bytesLoaded;
				evt.bytesTotal = ProgressEvent(e).bytesTotal;
			}
			else
			{
				Log.error("ResHelper.onLoaderEvent", e.type, m_path);	
				m_ldr.removeAllEventListener(onLoaderEvent);
				
				m_state = ResState.LOAD_FAILED;
				evt = new ResEvent(ResEvent.LOAD_FAILED);
			}

			
			
			evt.path = m_path;
			this.dispatchEvent(evt);
		}

		public function addAllEventListener(listener:Function):void
		{
			this.addEventListener(ResEvent.LOAD_SUCCESS, listener);
			this.addEventListener(ResEvent.LOAD_FAILED, listener);
			this.addEventListener(ResEvent.LOAD_PROGRESS, listener);
		}
		
		public function removeAllEventListener(listener:Function):void
		{
			this.removeEventListener(ResEvent.LOAD_SUCCESS, listener);
			this.removeEventListener(ResEvent.LOAD_FAILED, listener);
			this.removeEventListener(ResEvent.LOAD_PROGRESS, listener);
		}
		
		
		public function toDumpString():String
		{
			
			
			var tmpState:String;
			
			switch(m_state)
			{
				case ResState.NULL:			tmpState = "null   ";break;
				case ResState.LOADING:		tmpState = "loading";break;
				case ResState.LOAD_SUCCESS:	tmpState = "success";break;
				case ResState.LOAD_FAILED:	tmpState = "failed ";break;
				default:break;
			}
			

			
			var tmpType:String;
			tmpType = StringUtil.expendString(m_file.type, 10);
			
			
			
			var strRet:String = tmpType + 
				"\t| " + m_file.ver + 
				"\t| " + m_file.size.toPrecision(8) + 
				"\t| " + m_file.memory.toPrecision(8) + 
				"\t| " + tmpState +
				"\t| " + m_file.path;
			
			
			return strRet;
		}
		
		
		public function toDumpContent():*
		{
			return m_file.content;
		}
			
			
	}
}

