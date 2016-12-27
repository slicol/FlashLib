package com.tencent.fge.engine.ui.cursor
{
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	public class CursorSprite extends Sprite
	{
		public static const LOAD_INIT:int = 0;
		public static const LOAD_ING:int = 1;
		public static const LOAD_COMPLETE:int = 2;

		
		private var m_data:CursorData;
		private var m_loadState:int = LOAD_INIT;
		
		private var m_byteLdrNormal:URLLoader;
		private var m_byteLdrPress:URLLoader;
		
		private var m_ldrNormal:Loader = new Loader;
		private var m_ldrPress:Loader = new Loader;
		
		private var m_isNormalComplete:Boolean = false;
		private var m_isPressComplete:Boolean = false;
		
		private var m_state:int = -1;
		
		public function CursorSprite(data:CursorData)
		{
			super();
			m_data = data;
			
			this.addChild(m_ldrNormal);
			m_ldrNormal.visible = false;
			m_ldrNormal.mouseEnabled = false;
			m_ldrNormal.mouseChildren = false;
			
			this.addChild(m_ldrPress);
			m_ldrPress.visible = false;
			m_ldrPress.mouseEnabled = false;
			m_ldrPress.mouseChildren = false;
			
			this.mouseEnabled = false;
			this.mouseChildren = false;
		}
		
		public function set state(value:int):void
		{
			if(m_state == value)
			{
				return;
			}
			
			m_state = value;
			
			if(value == CursorState.NORMAL)
			{
				m_ldrNormal.visible = true;
				m_ldrPress.visible = false;
				if(m_isNormalComplete)
				{
					Mouse.hide();
				}
				else
				{
					Mouse.show();
				}
			}
			else if(value == CursorState.PRESS)
			{
				m_ldrNormal.visible = false;
				m_ldrPress.visible = true;
				if(m_isPressComplete)
				{
					Mouse.hide();
				}
				else
				{
					Mouse.show();
				}
			}
		}
		
		
		public function show():void
		{
			this.visible = true;
			if(m_loadState == LOAD_INIT)
			{
				var ldr:URLLoader;
				
				ldr = new URLLoader;
				ldr.dataFormat = URLLoaderDataFormat.BINARY;
				ldr.load(new URLRequest(m_data.normal));
				ldr.addEventListener(Event.COMPLETE, onBytesLoadEvent);
				ldr.addEventListener(IOErrorEvent.IO_ERROR, onBytesLoadEvent);
				ldr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onBytesLoadEvent);
				m_byteLdrNormal = ldr;
				
				ldr = new URLLoader;
				ldr.dataFormat = URLLoaderDataFormat.BINARY;
				ldr.load(new URLRequest(m_data.press));
				ldr.addEventListener(Event.COMPLETE, onBytesLoadEvent);
				ldr.addEventListener(IOErrorEvent.IO_ERROR, onBytesLoadEvent);
				ldr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onBytesLoadEvent);
				m_byteLdrPress = ldr;
				
				m_loadState = LOAD_ING;
				Mouse.show();
			}
			else if(m_loadState == LOAD_COMPLETE)
			{
				Mouse.hide();
			}
		}
		
		public function hide():void
		{
			this.visible = false;
		}
		
		private function onBytesLoadEvent(e:Event):void
		{
			var ldr:URLLoader = e.target as URLLoader;
			ldr.removeEventListener(Event.COMPLETE, onBytesLoadEvent);
			ldr.removeEventListener(IOErrorEvent.IO_ERROR, onBytesLoadEvent);
			ldr.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onBytesLoadEvent);
			
			if(e.type == Event.COMPLETE)
			{
				if(ldr == m_byteLdrNormal)
				{
					m_ldrNormal.loadBytes(ldr.data, new LoaderContext(false, new ApplicationDomain()));
					this.addChild(m_ldrNormal);
					m_ldrNormal.visible = false;
					m_isNormalComplete = true;
				}
				else
				{
					m_ldrPress.loadBytes(ldr.data, new LoaderContext(false, new ApplicationDomain()));
					this.addChild(m_ldrPress);
					m_ldrPress.visible = false;
					m_isPressComplete = true;
				}
				
				if(m_isNormalComplete && m_isPressComplete)
				{
					m_loadState = LOAD_COMPLETE;
					if(this.visible)
					{
						Mouse.hide();
						state = CursorState.NORMAL;
					}
				}
			}
		}
	}
}