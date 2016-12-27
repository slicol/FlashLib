package com.tencent.fge.engine.ui.menu
{
	import flash.events.EventDispatcher;
	import flash.text.TextFormat;

	public class MenuConfig extends EventDispatcher
	{
		public var texListBg:Class;
		public var texItemBgArray:Array = new Array(4);
		public var texItemIconChild:Class;

		public var listGap:Number = 2;
		public var listLeftGap:Number = 5;
		public var listRightGap:Number = 5;
		public var listBottomGap:Number = 10;
		public var listTopGap:Number = 10;
		
		public var itemLeftGap:Number = 15;
		public var itemRightGap:Number = 0;
		public var itemBottomGap:Number = 5;
		public var itemTopGap:Number = 5;
		
		public var itemMinWidth:Number = 50;
		public var itemMaxWidth:Number = 200;
		
		public var textEmbedFonts:Boolean = false;
		public var textFormatArray:Array = new Array(4);
		public var textHeightCoef:Number = 1.2;

		public var containerWidth:Number;
		public var containerHeight:Number;
		
		
		public function setTextFormat(fmtNormal:TextFormat, fmtOver:TextFormat, 
									  fmtDown:TextFormat, fmtDisable:TextFormat):void
		{
			if(fmtNormal == null)
			{
				fmtNormal = new TextFormat;
			}
			
			textFormatArray[0] = fmtNormal;
			textFormatArray[1] = fmtOver;
			textFormatArray[2] = fmtDown;
			textFormatArray[3] = fmtDisable;
			
			var evt:MenuConfigEvent;
			evt = new MenuConfigEvent(MenuConfigEvent.MENU_UPDATE_TEXT_FORMAT);
			this.dispatchEvent(evt);
		}
		
		public function setTexture(bgList:Class,
								   bgItemNormal:Class, bgItemOver:Class, 
								   bgItemDown:Class, bgItemDisable:Class,
								   childMenuIcon:Class):void
		{
			texListBg = bgList;
			texItemBgArray[0] = bgItemNormal;
			texItemBgArray[1] = bgItemOver;
			texItemBgArray[2] = bgItemDown;
			texItemBgArray[3] = bgItemDisable;
			
			texItemIconChild = childMenuIcon;

			
			var evt:MenuConfigEvent;
			
			evt = new MenuConfigEvent(MenuConfigEvent.MENU_UPDATE_TEX_LIST_BG);
			this.dispatchEvent(evt);
			
			evt = new MenuConfigEvent(MenuConfigEvent.MENU_UPDATE_TEX_ITEM_BG_NORMAL);
			this.dispatchEvent(evt);
			
			evt = new MenuConfigEvent(MenuConfigEvent.MENU_UPDATE_TEX_ITEM_BG_OVER);
			this.dispatchEvent(evt);
			
			evt = new MenuConfigEvent(MenuConfigEvent.MENU_UPDATE_TEX_ITEM_ICON_CHILD);
			this.dispatchEvent(evt);
		}
	}
}