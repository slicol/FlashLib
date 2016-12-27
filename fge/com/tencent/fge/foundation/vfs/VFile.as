package com.tencent.fge.foundation.vfs
{
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class VFile extends EventDispatcher
	{
		public static const STATE_NULL:String = "";
		public static const STATE_COMPLETE:String = "stateComplete";
		public static const STATE_LOADING:String = "stateLoading";
		public static const STATE_ERROR:String = "stateError";
		
		
		private var m_url:String = "";
		private var m_data:ByteArray;
		private var m_state:String = STATE_NULL;
		
		private var m_ldr:URLLoader;
		
		private static var log:Log = new Log(VFile);
		
		public function VFile(url:String):void
		{
			m_url = url;
			m_data = null;
		}
		
		
		public function get url():String{return m_url;}
		public function get data():ByteArray{return m_data;}
		public function get state():String{return m_state;}
		
		//-----------------------------------------------------------------
		
		public function create(bytes:ByteArray = null):void
		{
			if(bytes == null)
			{
				if(m_ldr)
				{
					m_ldr.close();	
					removeLoaderListener(m_ldr, onLoader);
				}
				
				m_ldr = new URLLoader();
				m_ldr.dataFormat = URLLoaderDataFormat.BINARY;
				m_ldr.load(new URLRequest(m_url));
				addLoaderListener(m_ldr, onLoader);
				
				m_state = STATE_LOADING;
			}
			else
			{
				m_data = bytes;
				m_data.position = 0;
				m_state = STATE_COMPLETE;
			}
		}
		
		private function addLoaderListener(target:EventDispatcher, listener:Function):void
		{
			target.addEventListener(Event.COMPLETE, listener);
			target.addEventListener(IOErrorEvent.IO_ERROR, listener);
			target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, listener);
		}
		
		private function removeLoaderListener(target:EventDispatcher, listener:Function):void
		{
			target.addEventListener(Event.COMPLETE, listener);
			target.addEventListener(IOErrorEvent.IO_ERROR, listener);
			target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, listener);
		}
		
		private function onLoader(e:Event):void
		{
			if(e.type == Event.COMPLETE)
			{
				create(m_ldr.data);
				handleComplete();
			}
			else
			{
				handleError(e.type);
			}
		}
		
		internal function handleComplete():void
		{
			var e:Event = new Event(Event.COMPLETE);
			this.dispatchEvent(e);
		}
		
		//-----------------------------------------------------------------
		
		public function release():void
		{
			if(m_data)
			{
				m_data.clear();
				m_data = null;
				m_state = STATE_NULL;
			}
		}
		
		//-----------------------------------------------------------------
		
		private function handleError(info:String):void
		{
			log.error("handleError", info, m_url);
			
		}
		
		//-----------------------------------------------------------------
	}
}

