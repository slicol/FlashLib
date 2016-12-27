package com.tencent.fge.engine.ui
{
	import com.tencent.fge.utils.ClassUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextSnapshot;

	public class UISprite extends Sprite
	{
		public static var DEBUG:Boolean = false;
		
		public var zTopmost:int = 0;
		public var zActivate:int = 0;
		public var zIndex:int = 0;
		private var m_z:int = 0;
		
		//public var z:int = 0;
		
		private var m_container:Sprite;
		
		override public function get z():Number{return m_z;}
			
		public function UISprite(name:String = null, z:int = 0, topmost:Boolean = false)
		{
			super();
			
			if(name != null && name != "")
			{
				super.name = name;
			}
			else
			{
				super.name = ClassUtil.getName(this);
			}
			this.m_z = z;
			this.zTopmost = topmost ? 2:0;
					
			
			if(DEBUG) this.showDebugInfo(true);
		}
		
		public function init():void
		{
			m_container = new Sprite;
		}
		
		protected function setEnableActivate2Top(value:Boolean):void
		{
			if(value)
			{
				this.addEventListener(MouseEvent.MOUSE_DOWN, onActivateEvent);
			}
			else
			{
				this.removeEventListener(MouseEvent.MOUSE_DOWN, onActivateEvent);
			}
		}
		
		private function onActivateEvent(e:MouseEvent):void
		{
			if(e.type == MouseEvent.MOUSE_DOWN)
			{
				if(this.parent)
				{
					this.parent.addChild(this);
				}
			}
		}

		
		protected function drawBorder(w:int, h:int):void
		{
			this.graphics.clear();
			this.graphics.lineStyle(2, 0xff0000,0.8);
			this.graphics.beginFill(0xffffff,0);
			this.graphics.drawRect(0,0,w,h);
			this.graphics.endFill();
		}
		
		protected function clearBorder():void
		{
			this.graphics.clear();
		}
		
		 
		public function addContent(content:DisplayObject):DisplayObject
		{
			return m_container.addChild(content);
		}
		
		 
		public function addContentAt(content:DisplayObject, index:int):DisplayObject
		{
			return m_container.addChildAt(content, index);
		}
		 
		 
		public function hasContent(content:DisplayObject):Boolean
		{
			return m_container.contains(content);
		}
		
		 
		public function removeContent(content:DisplayObject):DisplayObject
		{
			return m_container.removeChild(content);
		}
		
		 
		public function removeContentAt(index:int):DisplayObject
		{
			return m_container.removeChildAt(index);
		}
		
		 
		
		public function show():void
		{
			visible = true;
			super.addChild(m_container);
		}
		public function hide():void
		{
			visible = false;
			if(m_container.parent == this)
			{
				super.removeChild(m_container);
			}
		}
		
		private var m_dbgInfo:UISpriteDebugInfo;
		protected function showDebugInfo(bShow:Boolean):void
		{
			if(m_dbgInfo == null)
			{
				m_dbgInfo = new UISpriteDebugInfo();
				this.addChild(m_dbgInfo);
			}
			if(bShow)
			{
				m_dbgInfo.visible = true;
				m_dbgInfo.drawText(name);
				m_dbgInfo.drawBorder(width,height);
			}
			else
			{
				m_dbgInfo.visible = false;
			}
		}
		
		public function finalize():void
		{
			
		}
	}
}
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.text.TextFormat;
	

class UISpriteDebugInfo extends Sprite
{
	private var m_txt:TextField;
	
	public function drawText(s:String):void
	{
		createTextField();
		m_txt.text = s;
	}
	
	public function drawBorder(w:int, h:int):void
	{
		this.graphics.clear();
		this.graphics.lineStyle(2, 0xff0000,0.8);
		this.graphics.beginFill(0xffffff,0);
		this.graphics.drawRect(0,0,w,h);
		this.graphics.endFill();
	}
	
	private function createTextField():void
	{
		if(m_txt == null) 
		{
			m_txt = new TextField();
			m_txt.text = "DebugInfo";
			m_txt.x = 0;
			m_txt.y = 0;
			m_txt.width = 60;
			m_txt.height = 20;
			m_txt.selectable = false;
			m_txt.autoSize = TextFieldAutoSize.LEFT;
			m_txt.textColor = 0xff0000;
			this.addChild(m_txt);
			
			var fmt:TextFormat = new TextFormat;
			fmt.bold = true;
			fmt.size = 12;
			
			fmt.align = TextFormatAlign.CENTER;
			m_txt.setTextFormat(fmt);				
		}
	}
	
}