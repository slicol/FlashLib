package com.tencent.fge.engine.ui.cursor
{
	import com.tencent.fge.engine.ui.UILayer;
	import com.tencent.fge.engine.ui.UILayerDefine;
	import com.tencent.fge.engine.ui.UISystem;
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	
	public class CursorManager
	{
		private static var ms_instance:CursorManager;
		public static function getInstance():CursorManager
		{
			if(ms_instance == null) ms_instance = new CursorManager;
			return ms_instance;
			
		}
		

		
		//=============================================================================
		private var m_stage:Sprite;
		private var m_layer:UILayer;
		private var m_flag:String = "cursor";
		private var m_cursor:CursorSprite;
		private var m_cursorDefault:CursorSprite;
		private var log:Log = new Log(this);
		private var m_mapCursor:Dictionary = new Dictionary();
		private var m_urlLoader:URLLoader = new URLLoader;
		private var m_cfgPath:String = "";
		//=============================================================================
		
		public static function get width():Number
		{
			if(ms_instance == null || ms_instance.m_cursor == null)
			{
				return 20;
			}
			return ms_instance.m_cursor.width;
		}
		
		public static function get height():Number
		{
			if(ms_instance == null || ms_instance.m_cursor == null)
			{
				return 20;
			}
			return ms_instance.m_cursor.height;
		}
		
		//=============================================================================
		
		public function initialize(cursorConfig:*,
								   cursorFlag:String = "cursor"):void
		{
			m_stage = UISystem.getInstance();
			m_layer = UISystem.getLayer(UILayerDefine.CURSOR, UILayerDefine.CURSOR_Z);
			m_layer.mouseChildren = false;
			m_layer.mouseEnabled = false;
			m_stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseEnter);
			m_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseClick);
			m_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseClick);
			m_stage.addEventListener(MouseEvent.MOUSE_OUT, onMouseLeave);
			m_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			loadConfig(cursorConfig);
			
		}
		
		public function finalize():void
		{
			m_stage.removeEventListener(MouseEvent.MOUSE_OVER, onMouseEnter);
			m_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseClick);
			m_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseClick);
			m_stage.removeEventListener(MouseEvent.MOUSE_OUT, onMouseLeave);
			m_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			m_stage = null;
			m_cursorDefault = null;
			m_cursor = null;
			m_layer = null;
			Mouse.show();
		}
		
		//=============================================================================
		
		private function loadConfig(cfg:*):void
		{
			if(cfg is String)
			{
				m_cfgPath = cfg;
				m_urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
				m_urlLoader.load(new URLRequest(cfg));
				m_urlLoader.addEventListener(Event.COMPLETE, onConfigEvent);
				m_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onConfigEvent);
				m_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onConfigEvent);
			}
			else
			{
				loadXml(cfg);
			}
		}
		
		private function onConfigEvent(e:Event):void
		{
			m_urlLoader.removeEventListener(Event.COMPLETE, onConfigEvent);
			m_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onConfigEvent);
			m_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onConfigEvent);
			
			if(e.type == Event.COMPLETE)
			{
				var xml:XML;
				try
				{
					xml = XML(m_urlLoader.data);
				}
				catch(err:Error)
				{
					log.error("onConfigEvent", err);
					return ;
				}
				
				loadXml(xml);
			}
			else
			{
				log.error("onConfigEvent", e);
			}
		}
		
		private function loadXml(xml:XML):void
		{
			var baseurl:String = xml.@baseurl;
			var xmlCursorList:XMLList = xml.children();
			var xmlCursor:XML;
			
			for(var i:int = 0; i < xmlCursorList.length(); ++i)
			{
				xmlCursor = xmlCursorList[i];
				var data:CursorData = new CursorData;
				data.fromXml(xmlCursor, baseurl);
				var view:CursorSprite = new CursorSprite(data);
				m_mapCursor[data.id] = view;
				
				if(data.id == 0)
				{
					m_cursorDefault = view;
					m_cursorDefault.show();
				}
			}
		}
		
		//=============================================================================

		private function onMouseClick(e:MouseEvent):void
		{
			var pt:Point;

			if(m_cursor != null)
			{
				pt = new Point(e.stageX, e.stageY);
				pt = m_stage.globalToLocal(pt);
				m_cursor.x = pt.x;
				m_cursor.y = pt.y;
				m_cursor.state = e.buttonDown ? CursorState.PRESS : CursorState.NORMAL;
				
			}
			else if(m_cursorDefault != null)
			{
				pt = new Point(e.stageX, e.stageY);
				pt = m_stage.globalToLocal(pt);
				m_cursorDefault.x = pt.x;
				m_cursorDefault.y = pt.y;
				m_cursorDefault.state = e.buttonDown ? CursorState.PRESS : CursorState.NORMAL;
			}
		}
		
		private function onEnterFrame(e:Event):void
		{
			var pt:Point;
			
			if(m_cursor != null)
			{
				pt = new Point(m_stage.mouseX, m_stage.mouseY);
				//pt = m_stage.globalToLocal(pt);
				m_cursor.x = pt.x;
				m_cursor.y = pt.y;
				
				Mouse.hide();
			}
			else if(m_cursorDefault != null)
			{
				pt = new Point(m_stage.mouseX, m_stage.mouseY);
				
				updateCursor(pt, m_cursorDefault);
				
				//pt = m_stage.globalToLocal(pt);
				m_cursorDefault.x = pt.x;
				m_cursorDefault.y = pt.y;
				Mouse.hide();
			}
		}
		
		
		
		//-----------------------------------------------------------------------------
		
		private function onMouseLeave(e:MouseEvent):void
		{
			//log.trace("onMouseLeave", e.target);
			//Mouse.show();
		}
		
		private function onMouseEnter(e:MouseEvent):void
		{
			//log.trace("onMouseEnter", e.target);
			
			var target:Object;
			var flag:*;
			var pt:Point = new Point(e.stageX, e.stageY);
			var arr:Array = m_stage.getObjectsUnderPoint(pt);
			
			Mouse.hide();
			
			if(arr.length == 0)
			{
				updateCursor(pt, m_cursorDefault);
				return;
			}
			
			target = arr[arr.length - 1];
			
			var cursor:CursorSprite;
			
			while(target != m_stage)
			{
				if(target.hasOwnProperty(m_flag))
				{
					flag = target[m_flag];
					if(flag != null)
					{
						cursor = m_mapCursor[flag];
						if(cursor)
						{
							updateCursor(pt, cursor);
							return;
						}
					}
					break;
				}
				else if(target is SimpleButton)
				{
					if(SimpleButton(target).useHandCursor)
					{
						cursor = m_mapCursor[CursorData.HAND];
						if(cursor)
						{
							updateCursor(pt, cursor);
							return;
						}
						break;
					}
				}
				else if(target is TextField)
				{
					if(TextField(target).selectable)
					{
						cursor = m_mapCursor[CursorData.INPUT];
						if(cursor)
						{
							updateCursor(pt, cursor);
							return;
						}
						break;
					}
				}
				else if(target is Sprite)
				{
					if(Sprite(target).buttonMode && Sprite(target).useHandCursor)
					{
						cursor = m_mapCursor[CursorData.HAND];
						if(cursor)
						{
							updateCursor(pt, cursor);
							return;
						}
						break;
					}
				}
				else
				{
					if(target.hasOwnProperty("buttonMode") && target["buttonMode"])
					{
						if(target.hasOwnProperty("useHandCursor") && target["useHandCursor"])
						{
							cursor = m_mapCursor[CursorData.HAND];
							if(cursor)
							{
								updateCursor(pt, cursor);
								return;
							}
							break;
						}
					}
				}
				target = target.parent;
			}
			
			updateCursor(pt, m_cursorDefault);
		}
		
		private function updateCursor(ptStage:Point, cursor:CursorSprite):void
		{
			if(m_cursor != cursor)
			{
				if(m_cursor && m_layer.contains(m_cursor as DisplayObject))
				{
					m_layer.removeChild(m_cursor as DisplayObject);
					m_cursor.hide();
				}
				m_cursor = cursor;
				if(m_cursor)
				{
					m_layer.addChild(m_cursor as DisplayObject);
					var pt:Point = m_stage.globalToLocal(ptStage);
					m_cursor.x = pt.x;
					m_cursor.y = pt.y;
					m_cursor.show();
				}
			}
		}
	}
}