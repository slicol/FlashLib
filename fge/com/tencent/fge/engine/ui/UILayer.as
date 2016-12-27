package com.tencent.fge.engine.ui
{
	import com.tencent.fge.utils.KeyArray;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	public class UILayer extends Sprite
	{
		private var m_lstUI:Array = new Array;
		private var m_z:int = 0;
		private var m_numChildren:int;
		//public var z:int;
		
		public function UILayer(name:String, z:int)
		{
			super();
			m_z = z;
			super.name = name;
		}
		
		override public function get z():Number{return m_z;}
		

		public function addUI(ui:UISprite):void
		{
			if(ui == null)
			{
				return;
			}
			
			var i:int = m_lstUI.indexOf(ui);
			if(i >= 0)
			{
				m_lstUI.splice(i,1);
			}
			
			m_lstUI.push(ui);
			this.addChild(ui);
//			this.addUIEventListener(ui);
			updateLayout();
		}
		
		public function removeUI(ui:UISprite):UISprite
		{
			if(ui == null)
			{
				return ui;
			}
			
			var i:int = m_lstUI.indexOf(ui);
			if(i >= 0)
			{
				m_lstUI.splice(i,1);
			}
			
			if(this.contains(ui))
			{
				this.removeChild(ui);
			}
			
//			this.removeUIEventListener(ui);
			
			return ui;
		}
		
		public function getUI(name:String):Array
		{
			var ui:UISprite;
			var lst:Array = new Array;
			for(var i:int = 0; i < m_lstUI.length; ++i)
			{
				ui = m_lstUI[i];
				if(ui.name == name)
				{
					lst.push(ui);
				}
			}
			
			return lst;
		}		
		
		
		private function updateLayout():void
		{
			var i:int;
			var ui:UISprite;
			
			for(i = 0; i < m_lstUI.length; ++i)
			{
				ui = m_lstUI[i];
				ui.zIndex = i;
			}
			
			m_lstUI.sortOn(["zTopmost", "zActivate", "z", "zIndex"], 
				[Array.NUMERIC, Array.NUMERIC, Array.NUMERIC, Array.NUMERIC]); 

			for(i = m_lstUI.length - 1; i >= 0; --i)
		    {
		    	ui = m_lstUI[i];
		    	this.setChildIndex(ui, i); 
		    }
		}
		
		
//		private function addUIEventListener(ui:DisplayObject):void
//		{
//			ui.addEventListener(Event.ACTIVATE, onUIEvent);
//			ui.addEventListener(Event.DEACTIVATE, onUIEvent);
//		}
//		
//		private function removeUIEventListener(ui:DisplayObject):void
//		{
//			ui.removeEventListener(Event.ACTIVATE, onUIEvent);
//			ui.removeEventListener(Event.DEACTIVATE, onUIEvent);
//		}
//		
//		private function onUIEvent(e:Event):void
//		{
//			switch(e.type)
//			{
//			case Event.ACTIVATE:
//				this.updateLayout();
//				break;
//			default:break;
//			}
//		}
		
	}
}
