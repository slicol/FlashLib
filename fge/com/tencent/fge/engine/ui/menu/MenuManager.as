package com.tencent.fge.engine.ui.menu
{
	import com.tencent.fge.engine.ui.UILayer;
	import com.tencent.fge.engine.ui.UILayerDefine;
	import com.tencent.fge.engine.ui.UISystem;
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	public class MenuManager
	{
		private static var ms_instance:MenuManager;
		public static function getInstance():MenuManager
		{
			if(ms_instance == null) ms_instance = new MenuManager;
			return ms_instance;
			
		}
		
		//=============================================================================
		
		private var m_stage:Sprite;
		private var m_layer:UILayer;
		private var log:Log = new Log(this);
		private var m_defaultMenuCfg:MenuConfig;
		private var m_mapMenu:Dictionary = new Dictionary;

		public function MenuManager()
		{
		}
		
		public static function initialize(defaultMenuConfig:MenuConfig = null):void
		{
			MenuManager.getInstance().initialize(defaultMenuConfig);
		}
		
		public function initialize(defaultMenuConfig:MenuConfig = null):void
		{
			m_defaultMenuCfg = defaultMenuConfig;
			
			m_stage = UISystem.getInstance();
			m_layer = UISystem.getLayer(UILayerDefine.MENU, UILayerDefine.MENU_Z);
		}
		
		public static function finalize():void
		{
			MenuManager.getInstance().finalize();
		}
		public function finalize():void
		{
			m_stage = null;
			m_layer = null;
			m_defaultMenuCfg = null;
		}


		public static function createMenu(name:String, cfg:MenuConfig = null):Menu
		{
			return MenuManager.getInstance().createMenu(name, cfg);
		}
		
		public function createMenu(name:String, cfg:MenuConfig = null):Menu
		{
			var m:Menu = m_mapMenu[name];
			if(m == null)
			{
				m = new Menu();
				m.create(m_stage, m_layer, name, cfg == null ? m_defaultMenuCfg : cfg);
				m.setContainerSize(UISystem.width, UISystem.height);
				m_mapMenu[name] = m;
			}
			return m;
		}
		
		
		public static function releaseMenu(name:String):void
		{
			MenuManager.getInstance().releaseMenu(name);
		}
		
		public function releaseMenu(name:String):void
		{
			var m:Menu = m_mapMenu[name];
			if(m != null)
			{
				m.release();
				m_mapMenu[name] = null;
				delete m_mapMenu[name];
			}
		}
		
		
		
		public static function addMenu(menu:Menu):Boolean
		{
			return MenuManager.getInstance().addMenu(menu);
		}
		
		public function addMenu(menu:Menu):Boolean
		{
			var m:Menu = m_mapMenu[menu.name];
			if(m == null )
			{
				m_mapMenu[menu.name] = menu;
				return true;
			}
			return false;
		}
		
		public static function removeMenu(menu:Menu):void
		{
			MenuManager.getInstance().removeMenu(menu);
		}
		public function removeMenu(menu:Menu):void
		{
			var m:Menu = m_mapMenu[menu.name];
			if(m != null )
			{
				m_mapMenu[menu.name] = null;
				delete m_mapMenu[menu.name];
			}
		}
		
		private function addMenuWorker(menu:Menu):Boolean
		{
			m_mapMenu[menu.name] = menu;
			return true;
		}
		
		public static function getMenu(name:String):Menu
		{
			return MenuManager.getInstance().getMenu(name);
		}
		public function getMenu(name:String):Menu
		{
			return m_mapMenu[name];
		}
		
	}
}