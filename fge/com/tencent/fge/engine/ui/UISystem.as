package com.tencent.fge.engine.ui
{
	import com.tencent.fge.engine.ui.keyboard.VirtualKeyboard;
	import com.tencent.fge.utils.KeyArray;
	import com.tencent.protobuf.stringToByteArray;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;

	public final class UISystem extends Sprite
	{
		private static var ms_width:Number = 1024;
		private static var ms_height:Number = 768;
		
		private static var ms_instance:UISystem;
		private static var ms_LayoutNumberChilds:Dictionary=new Dictionary();;
		
		private var m_lstLayer:KeyArray = new KeyArray;
		

		public static function getInstance():UISystem
		{
			if(ms_instance == null) ms_instance = new UISystem;
			return ms_instance;
		}
		
		public static function get width():Number{return ms_width;}
		public static function get height():Number{return ms_height;}
		public static function set debug(value:Boolean):void{UISprite.DEBUG = value;}
		
		public static function initialize():Boolean
		{
			return getInstance().initialize();
		}
		
		public static function finalize():void
		{
			getInstance().finalize();
		}
		
		public static function dump(layerName:String):String
		{
			var layer:UILayer = UISystem.getInstance().m_lstLayer.getElement(layerName);
			if(layer != null)
			{
				return UIDebugger.dumpDown(layer);
			}
			else
			{
				return UIDebugger.dumpDown(UISystem.getInstance().stage);
			}
		}
		
		public static function resize(w:int, h:int):void
		{
			ms_width = w;
			ms_height = h;
		}
		
		public static function getLayer(name:String, z:uint = 0):UILayer
		{
			return getInstance().getLayer(name, z);
		}
		
		public static function createLayer(name:String, z:int = 0):UILayer
		{
			return getInstance().createLayer(name, z);
		}
		
		public static function releaseLayer(name:String):void
		{
			return getInstance().releaseLayer(name);
		}
		
		public static function getUI(name:String):Array
		{
			return getInstance().getUI(name);
		}
		
		public static function addUI(layer:String, ui:UISprite):void
		{
			if(ms_LayoutNumberChilds[layer]==null)
			{
				ms_LayoutNumberChilds[layer]=0;
			}
			else
			{
				ms_LayoutNumberChilds[layer]++;
			}
			getInstance().getLayer(layer).addUI(ui);
		}
		
		public static function getLayoutChildNumbers(layer:String):int{
			return ms_LayoutNumberChilds[layer];
		}
		
		public static function removeUI(layer:String, ui:UISprite):UISprite
		{
			return getInstance().getLayer(layer).removeUI(ui);
		}
		
		
		
		private function initialize():Boolean
		{
			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			return true;
		}
		
		private function finalize():void
		{
			VirtualKeyboard.finalize();
		}
		
		private function onAddToStage(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			VirtualKeyboard.initialize(this.stage);
		}
		
		public function getLayer(name:String, z:uint = 0):UILayer
		{
			var layer:UILayer = m_lstLayer.getElement(name);
			if(layer == null)
			{
				layer = createLayer(name, z);
			}
			return layer;
		}
		
		public function createLayer(name:String, z:int = 0):UILayer
		{
			var layer:UILayer = new UILayer(name, z);
			m_lstLayer.push(name, layer);
			this.addChild(layer);
			updateLayout();
			return layer;
		}
		
		public function releaseLayer(name:String):void
		{
			var layer:UILayer = m_lstLayer.getElement(name);
			if(layer != null)
			{
				m_lstLayer.remove(name);
				if(true == this.contains(layer))
				{
					this.removeChild(layer);
				}
			}
			updateLayout();
		}
		
		public function getUI(name:String):Array
		{
			var lst:Array = new Array;
			for(var i:int = 0; i < m_lstLayer.length; ++i)
			{
				var layer:UILayer = m_lstLayer.getElement(i);
				var uilst:Array = layer.getUI(name);
				lst = lst.concat(uilst);
			}
			return lst;
		}

		private function updateLayout():void
		{
			//更新层叠关系
			m_lstLayer.sortOn("z");
			for(var i:int = m_lstLayer.length - 1; i >= 0; --i)
		    {
		    	var layer:UILayer = m_lstLayer.getElement(i);
		    	this.setChildIndex(layer, i); 
		    }
		}

	}
}