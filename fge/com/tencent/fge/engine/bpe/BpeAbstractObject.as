package com.tencent.fge.engine.bpe 
{
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;

	public class BpeAbstractObject extends EventDispatcher
	{
		private var m_alwaysRepaint:Boolean;
		private var m_sprite:Sprite;
		private var m_visible:Boolean;
		
		//用于调试
		internal var lineThickness:Number;
		internal var lineColor:uint;
		internal var lineAlpha:Number;
		internal var fillColor:uint; 
		internal var fillAlpha:Number;
		
		
		//用于引用显示对象，这是视图与逻辑之间的关联点
		internal var collisionObject:DisplayObject;
		internal var userData:*;//用于引用一些附加数据
		

		
		public function BpeAbstractObject() 
		{
			m_alwaysRepaint = false;
			m_visible = true;
		}
		
		//被添加到Engine时调用
		internal function initialize():void {}
		
		//被Engine调用		
		public function paint():void {}	
		
		//被移除Engine时调用
		internal function cleanup():void 
		{
			sprite.graphics.clear();
			//displayObject = null;
			collisionObject = null;
			userData = null;
		}
		
	
		//----------------------------------------------------------------
		//用于调试
		public function setStyle(
			lineThickness:Number=0, lineColor:uint=0x000000, lineAlpha:Number=1,
			fillColor:uint=0xffffff, fillAlpha:Number=0.5):void 
		{
			
			setLine(lineThickness, lineColor, lineAlpha);		
			setFill(fillColor, fillAlpha);		
		}		
		
		
		public function setLine(thickness:Number=0, color:uint=0x000000, alpha:Number=1):void 
		{
			lineThickness = thickness;
			lineColor = color;
			lineAlpha = alpha;
		}
		
		public function setFill(color:uint=0xffffff, alpha:Number=0.5):void 
		{
			fillColor = color;
			fillAlpha = alpha;
		}
		
		//----------------------------------------------------------------
		
		public function get sprite():Sprite 
		{
			if (m_sprite != null) return m_sprite;
			m_sprite = new Sprite();
			m_sprite.cacheAsBitmap = true;
			return m_sprite;
		}
		
		/*
		public function getCurrentDisplayObject():DisplayObject
		{
			return this.displayObject;
		}
		*/
		
		
		//作用于Fixed的物体。如果是Fixed，则用于决定它是否被次都重绘
		public final function get alwaysRepaint():Boolean 
		{
			return m_alwaysRepaint;
		}
		
		public final function set alwaysRepaint(b:Boolean):void 
		{
			m_alwaysRepaint = b;
		}	
		
		public function get visible():Boolean 
		{
			return m_visible;
		}
				
		public function set visible(v:Boolean):void 
		{
			m_visible = v;
			sprite.visible = v;
		}		
	}
}
