package com.tencent.fge.engine.ui.menu
{
	import com.tencent.fge.engine.text.font.FontManager;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;
	

	
	public class MenuItem extends Sprite
	{
		private var m_width:Number = 150;
		private var m_height:Number = 30;
		
		private var m_listBg:Array = new Array(4);
		private var m_iconChild:DisplayObject;

		private var m_id:*;
		private var m_label:*;
		private var m_priority:int = 0;
		private var m_userdata:*;
		private var m_listener:Function;
		
		private var m_listChild:MenuList;
		private var m_rt:MenuRuntime;
		
		private var m_tf:TextField;
		private var m_content:DisplayObject;
		
		private var m_timer:Timer;
		private var m_state:int = MenuItemState.NORMAL;
		
		private var m_enable:Boolean = true;
		
		
		
		public function MenuItem()
		{
			super();
			
		}
		
		private static const ms_borderFilter: Array = [new DropShadowFilter(0, 0, 0, 1, 5, 5, 10)];
		
		public function create(id:*, listener:Function, rt:MenuRuntime):void
		{
			m_rt = rt;
			m_rt.cfg.addEventListener(MenuConfigEvent.MENU_UPDATE_TEX_ITEM_BG_NORMAL, onUpdateTex);
			m_rt.cfg.addEventListener(MenuConfigEvent.MENU_UPDATE_TEX_ITEM_BG_OVER, onUpdateTex);
			m_rt.cfg.addEventListener(MenuConfigEvent.MENU_UPDATE_TEX_ITEM_BG_DOWN, onUpdateTex);
			m_rt.cfg.addEventListener(MenuConfigEvent.MENU_UPDATE_TEX_ITEM_ICON_CHILD, onUpdateTextFormat);
			m_rt.cfg.addEventListener(MenuConfigEvent.MENU_UPDATE_TEXT_FORMAT, onUpdateTex);
			
			m_id = id;
			m_listener = listener;
			
			if(m_listener != null)
			{
				this.addEventListener(MenuEvent.MENU_CLICK, m_listener);
			}
			
			m_tf = new TextField();
			m_tf.height = 20;
			m_tf.width = 100;
			m_tf.mouseEnabled = false;
			m_tf.embedFonts = m_rt.cfg.textEmbedFonts;
			m_tf.filters = ms_borderFilter;
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this.addEventListener(MouseEvent.CLICK, onMouseClick);
			
			m_timer = new Timer(500,1);
			m_timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			updateAllTexWorker();
			updateTextFormat();
		}
		
		public function release():void
		{
			if(m_listChild)
			{
				m_listChild.release();
				m_listChild = null;
			}
			
			m_rt.cfg.removeEventListener(MenuConfigEvent.MENU_UPDATE_TEX_ITEM_BG_NORMAL, onUpdateTex);
			m_rt.cfg.removeEventListener(MenuConfigEvent.MENU_UPDATE_TEX_ITEM_BG_OVER, onUpdateTex);
			m_rt.cfg.removeEventListener(MenuConfigEvent.MENU_UPDATE_TEX_ITEM_BG_DOWN, onUpdateTex);
			m_rt.cfg.removeEventListener(MenuConfigEvent.MENU_UPDATE_TEX_ITEM_ICON_CHILD, onUpdateTextFormat);
			m_rt.cfg.removeEventListener(MenuConfigEvent.MENU_UPDATE_TEXT_FORMAT, onUpdateTex);
			m_rt = null;
			
			m_id = null;
			
			if(m_listener != null)
			{
				this.removeEventListener(MenuEvent.MENU_CLICK, m_listener);
				m_listener = null;
			}
			
			m_tf = null;
			
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			this.removeEventListener(MouseEvent.CLICK, onMouseClick);
			
			m_timer.stop();
			m_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			m_timer = null;
		}
		
		private function onUpdateTextFormat(e:MenuConfigEvent):void
		{
			updateTextFormat();
		}
		
		private function onUpdateTex(e:MenuConfigEvent):void
		{
			var clsTex:Class;
			var bg:DisplayObject;
			
			if(e.type == MenuConfigEvent.MENU_UPDATE_TEX_ITEM_BG_NORMAL)
			{
				updateBgTexture(MenuItemState.NORMAL);
			}
			else if(e.type == MenuConfigEvent.MENU_UPDATE_TEX_ITEM_BG_OVER)
			{
				updateBgTexture(MenuItemState.OVER);
			}
			else if(e.type == MenuConfigEvent.MENU_UPDATE_TEX_ITEM_BG_DOWN)
			{
				updateBgTexture(MenuItemState.DOWN);
			}
			else if(e.type == MenuConfigEvent.MENU_UPDATE_TEX_ITEM_ICON_CHILD)
			{
				updateChildIconTexture();
			}
		}
		
		private function updateAllTexWorker():void
		{
			updateBgTexture(MenuItemState.NORMAL);
			updateBgTexture(MenuItemState.OVER);
			updateBgTexture(MenuItemState.DOWN);
			updateBgTexture(MenuItemState.DISABLE);
			updateChildIconTexture();
			this.state = MenuItemState.NORMAL;
		}
		
		private function updateTextFormat():void
		{
			var state:int = m_enable ? m_state : MenuItemState.DISABLE;
			
			
			var fmt:TextFormat = m_rt.cfg.textFormatArray[state];
			if(fmt != null)
			{
				m_tf.setTextFormat(fmt);
				m_tf.width = m_tf.textWidth + fmt.size;
				m_tf.height = m_tf.textHeight * m_rt.cfg.textHeightCoef;
			}

		}
		
		private function updateBgTexture(state:int):void
		{
			var clsTex:Class;
			var bg:DisplayObject;
			clsTex = m_rt.cfg.texItemBgArray[state];
			if(clsTex != null)
			{
				bg = m_listBg[state];
				
				if(bg != null && this.contains(bg))
				{
					this.removeChild(bg);
				}
				
				bg = new (clsTex);
				this.addChild(bg);
				this.setChildIndex(bg, 0);
				bg.visible = false;
				
				m_listBg[state] = bg;
			}
		}
		
		private function updateChildIconTexture():void
		{
			var clsTex:Class;
			clsTex = m_rt.cfg.texItemIconChild;
			if(clsTex != null)
			{
				if(m_iconChild != null && this.contains(m_iconChild))
				{
					this.removeChild(m_iconChild);
				}
				
				m_iconChild = new (clsTex);
				this.addChild(m_iconChild);
				this.setChildIndex(m_iconChild, 100);
				m_iconChild.visible = false;
			}
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			state = MenuItemState.DOWN;
			m_timer.start();
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			state = MenuItemState.OVER;
			m_timer.start();
		}
		
		private function onMouseOut(e:MouseEvent):void
		{
			state = MenuItemState.NORMAL;
			m_timer.start();
		}
		
		
		private function onMouseClick(e:MouseEvent):void
		{
			if(m_listChild == null)
			{
				var evt:MenuEvent = new MenuEvent(MenuEvent.MENU_CLICK);
				evt.id = m_id;
				evt.label = m_label;
				evt.userdata = m_userdata;
				evt.menu = m_rt.menu;
				evt.menuTarget = m_rt.menuTarget;
				this.dispatchEvent(evt);
				
				m_rt.dispatchEvent(evt.clone());
			}
			else
			{
				this.popup();
			}
			e.stopPropagation();
			
		}
		
		private function onTimer(e:Event):void
		{
			if(m_state == MenuItemState.NORMAL)
			{
				this.hide();
			}
			else if(m_state == MenuItemState.OVER)
			{
				this.popup();
			}
		}
		
		
		override public function get width():Number
		{
			return m_width;
		}
		
		override public function get height():Number
		{
			return m_height;
		}
		
		
		public function get id():*{	return m_id;}
		public function set userdata(value:*):void{	m_userdata = value;}
		public function get userdata():*{return m_userdata;}
		public function set priority(value:int):void{m_priority = value;}
		public function get priority():int{return m_priority;}
		public function set listener(value:Function):void{m_listener = value;}
		public function get state():int{return m_state;}
		public function get enable():Boolean{return m_enable;}
		
		public function set label(value:*):void
		{
			if(m_label != value)
			{
				clearLabel();
				m_label = value;
				updateLabel();
			}
		}
		
		public function set state(value:int):void
		{
			var bg:DisplayObject;
			
			for each (bg in m_listBg)
			{
				if(bg)
				{
					bg.visible = false;
				}
			}
			
			m_state = value;
			
			bg = m_listBg[m_state];
			if(bg)
			{
				bg.visible = true;
			}
			
			updateTextFormat();
		}
		
		public function set enable(value:Boolean):void
		{
			m_enable = value;
			
			if(m_enable)
			{
				this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				this.addEventListener(MouseEvent.CLICK, onMouseClick);
				state = MenuItemState.NORMAL;
			}
			else
			{
				this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
				this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
				this.removeEventListener(MouseEvent.CLICK, onMouseClick);
				state = MenuItemState.DISABLE;
			}
			
			
		}
		
		public function updateWidth(w:Number):void
		{
			m_width = w;
			
			var gapX:Number = m_rt.cfg.itemLeftGap + m_rt.cfg.itemRightGap;
			var tempW:Number = m_width - gapX;
			m_content.width = tempW;

			
			//更新菜单项背景的布局
			this.graphics.clear();
			
			var needDrawBorder:Boolean = true;
			var bg:DisplayObject;
			
			bg = m_listBg[MenuItemState.NORMAL];
			if(bg != null)
			{
				bg.width = this.width;
				bg.height = this.height;
				needDrawBorder = false;
			}
			
			bg = m_listBg[MenuItemState.OVER];
			if(bg != null)
			{
				bg.width = this.width;
				bg.height = this.height;
				needDrawBorder = false;
			}
			
			bg = m_listBg[MenuItemState.DOWN];
			if(bg != null)
			{
				bg.width = this.width;
				bg.height = this.height;
				needDrawBorder = false;
			}
			
			bg = m_listBg[MenuItemState.DISABLE];
			if(bg != null)
			{
				bg.width = this.width;
				bg.height = this.height;
				needDrawBorder = false;
			}
			
			if(needDrawBorder)
			{
				this.graphics.beginFill(0xff0000, 0.5);
				this.graphics.drawRect(0,0,this.width, this.height);
				this.graphics.endFill();
			}
			
			
			//更新子菜单列表的布局
			if(m_listChild != null)
			{
				var needDrawChildIcon:Boolean = true;
				
				if(m_iconChild != null)
				{
					m_iconChild.x = this.width - m_iconChild.width;
					m_iconChild.y = (this.height - m_iconChild.height)/2;
					needDrawChildIcon = false;
				}
				
				if(needDrawChildIcon)
				{
					var rc:Rectangle = new Rectangle;
					rc.width = 10;
					rc.height = 10;
					rc.x = this.width - rc.width;
					rc.y = (this.height - rc.height)/2;
					
					this.graphics.beginFill(0x00ff00, 0.5);
					this.graphics.drawRect(rc.x,rc.y,rc.width, rc.height);
					this.graphics.endFill();
				}
				
				m_listChild.x = this.width;
			}
		}
		
		public function updateLayout():void
		{
			//更新菜单项内容的布局
			var cfg:MenuConfig = m_rt.cfg;
			var gapX:Number = cfg.itemLeftGap + cfg.itemRightGap;
			var gapY:Number = cfg.itemTopGap + cfg.itemBottomGap;
			var tempW:Number;
			var tempH:Number = m_content.height;
			
			tempW = m_content.width;
			if(tempW > cfg.itemMaxWidth - gapX)
			{
				tempW = cfg.itemMaxWidth - gapX;
			}
			if(tempW < cfg.itemMinWidth - gapX)
			{
				tempW = cfg.itemMinWidth - gapX;
				
			}
			
			m_content.x = cfg.itemLeftGap;
			m_content.y = cfg.itemTopGap;
			m_content.width = tempW;

			m_width = tempW + gapX;
			m_height = tempH + gapY;
			
			//更新大小
			updateWidth(m_width);

			//更新子菜单列表的布局
			if(m_listChild != null)
			{
				m_listChild.updateLayout();
			}
		}
		
		private function updateLabel():void
		{
			if(m_label is String)
			{
				m_tf.htmlText = m_label;
				updateTextFormat();
				this.addChild(m_tf);
				m_content = m_tf;
			}
			else if(m_label is DisplayObject)
			{
				this.addChild(m_label);
				m_content = m_label;
			}
			else
			{
				m_tf.htmlText = "[" + m_label.toString() + "]";
				updateTextFormat();
				if(!this.contains(m_tf))
				{
					this.addChild(m_tf);
					m_content = m_tf;
				}
			}
		}
		
		private function clearLabel():void
		{
			if(m_label is String)
			{
				m_tf.text = "";
				this.removeChild(m_tf);
			}
			else if(m_label is DisplayObject)
			{
				this.removeChild(m_label);
			}
			else
			{
				m_tf.text = "";
				if(this.contains(m_tf))
				{
					this.removeChild(m_tf);
				}
			}
			m_label = null;
		}
		
		public function popup():void
		{
			if(m_listChild != null)
			{
				var ptList:Point = new Point(this.width, 0);
				
				ptList = this.localToGlobal(ptList);
				ptList = m_rt.container.globalToLocal(ptList);
				
				
				if(ptList.x + m_listChild.width >= m_rt.containerWidth)
				{
					ptList.x = -m_listChild.width;
				}
				else
				{
					ptList.x = this.width;
				}
				
				if(ptList.y + m_listChild.height >= m_rt.containerHeight)
				{
					ptList.y = -m_listChild.height + this.height;
				}
				else
				{
					ptList.y = 0;
				}

				m_listChild.x = ptList.x;
				m_listChild.y = ptList.y;
				
				m_listChild.popup();
			}
		}
		
		public function hide():void
		{
			if(m_listChild != null)
			{
				m_listChild.hide();
			}
		}
		
		
		public function addMenuItem(fullPath:String, label:*, priority:int, 
									listener:Function):MenuItem
		{
			if(m_listChild == null)
			{
				m_listChild = new MenuList();
				m_listChild.create(m_rt);
				this.addChild(m_listChild);
			}
			
			return m_listChild.addMenuItem(fullPath, label, priority, listener);
		}
		
		public function removeMenuItem(fullPath:String):MenuItem
		{
			if(m_listChild != null)
			{
				return m_listChild.removeMenuItem(fullPath);
			}
			return null;
		}
		
		public function getMenuItem(fullPath:String):MenuItem
		{
			if(m_listChild != null)
			{
				return m_listChild.getMenuItem(fullPath);
			}
			return null;
		}
		
	}
}