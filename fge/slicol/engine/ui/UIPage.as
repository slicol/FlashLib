package slicol.engine.ui
{
	import flash.display.Sprite;
	
	public class UIPage extends UISprite
	{
		private static var ms_lstInstance:Vector.<UIPage> = new Vector.<UIPage>;
		
		public static function find(id:String):UIPage
		{
			for each(var instance:UISprite in ms_lstInstance)
			{
				if(instance.id == id)
				{
					return instance as UIPage;
				}
			}
			return null;
		}
		
		private static function add(instance:UISprite):void
		{
			ms_lstInstance.push(instance);
		}
		
		private static function remove(instance:UISprite):void
		{
			var i:int = ms_lstInstance.indexOf(instance);
			if(i >= 0)
			{
				ms_lstInstance.splice(i,1);
			}
		}
		
		
		//---------------------------------------------------------------
		
		
		public function UIPage()
		{
			super();
		}
		
		
		
		//---------------------------------------------------------------
		//DynamicUI
		//---------------------------------------------------------------
		private var m_lstDynamicUI:Vector.<UISprite> = new Vector.<UISprite>;
		private var m_dynamicUILayer:UISprite;
		
		public function addDynamicUI(ui:UISprite):void
		{
			if(!m_dynamicUILayer)
			{
				m_dynamicUILayer = new UISprite;
				this.addChild(m_dynamicUILayer);
			}
			
			if(m_lstDynamicUI.indexOf(ui) < 0)
			{
				m_lstDynamicUI.push(ui);
				m_dynamicUILayer.addChild(ui);
				
				UISprite.updateHierarchy(m_lstDynamicUI);
			}
		}
		
		public function removeDynamicUI(ui:UISprite):void
		{
			var i:int = m_lstDynamicUI.indexOf(ui);
			
			if(i >= 0)
			{
				m_lstDynamicUI.splice(i,1);
				m_dynamicUILayer.removeChild(ui);
			}
		}
		
		//---------------------------------------------------------------
		
		public function enter():void
		{
			UISystem.me.enterPage(id);
		}
		
		public function leave():void
		{
			UISystem.me.leavePage(id);
		}
		
		override public function show():void
		{
			this.visible = true;
		}
		
		override public function hide():void
		{
			this.visible = false;
			removeAllDynamicUI();
		}
		

		
		private function removeAllDynamicUI():void
		{
			var list:Vector.<UISprite> = m_lstDynamicUI.concat();
			
			for each(var ui:UISprite in list)
			{
				m_dynamicUILayer.removeChild(ui);
				ui.hide();
			}
		}
	}
}