package com.tencent.fge.engine.ui.menu
{
	import flash.events.Event;
	
	public class MenuConfigEvent extends Event
	{
		public static const MENU_UPDATE_TEX_LIST_BG:String = "menuUpdateTexListBg";
		public static const MENU_UPDATE_TEX_ITEM_BG_NORMAL:String = "menuUpdateTexItemBgNormal";
		public static const MENU_UPDATE_TEX_ITEM_BG_OVER:String = "menuUpdateTexItemBgOver";
		public static const MENU_UPDATE_TEX_ITEM_BG_DOWN:String = "menuUpdateTexItemBgDown";
		public static const MENU_UPDATE_TEX_ITEM_ICON_CHILD:String = "menuUpdateTexItemIconChild";
		public static const MENU_UPDATE_TEXT_FORMAT:String = "menuUpdateTextFormat";
		
		public function MenuConfigEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}