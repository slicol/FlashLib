package com.tencent.fge.engine.ui.menu
{
	import flash.events.Event;
	
	public class MenuEvent extends Event
	{
		public static const MENU_HIDE:String = "menuHide";
		public static const MENU_CLICK:String = "menuClick";
		
		public var menuTarget:Object = null;
		public var id:String = "";
		public var item:MenuItem;
		public var label:*;
		public var menu:Menu;
		public var userdata:*;

		
		public function MenuEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var evt:MenuEvent = new MenuEvent(this.type, this.bubbles, this.cancelable);

			evt.menuTarget = this.menuTarget;
			evt.id = this.id;
			evt.item = this.item;
			evt.label = this.label;
			evt.menu = this.menu;
			evt.userdata = this.userdata;
			
			return evt;
		}
	}
}