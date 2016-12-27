package com.tencent.fge.engine.ui.menu
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	public class MenuList extends Sprite
	{
		private static const TWEEN_SHOW:Number = 0.1;
		private static const TWEEN_HIDE:Number = -0.2;
		
		private var m_width:Number;
		private var m_height:Number;
		
		private var m_bg:DisplayObject;
		
		private var m_rt:MenuRuntime;
		private var m_lstItem:Array = new Array;
		private var m_mapItem:Dictionary = new Dictionary(true);
		
		private var m_timHide:Timer;
		private var m_timShow:Timer;
		
		

		public function MenuList()
		{
			super();
		}
		
		public function create(rt:MenuRuntime):void
		{
			m_rt = rt;
			m_rt.cfg.addEventListener(MenuConfigEvent.MENU_UPDATE_TEX_LIST_BG, onUpdateTex);

			
			m_lstItem = new Array;
			
			m_timShow = new Timer(20);
			m_timShow.addEventListener(TimerEvent.TIMER, onShowTimer);
			
			m_timHide = new Timer(20);
			m_timHide.addEventListener(TimerEvent.TIMER, onHideTimer);
			
			this.visible = false;
			
			updateTexWorker();
		}
		
		public function release():void
		{
			m_rt.cfg.removeEventListener(MenuConfigEvent.MENU_UPDATE_TEX_LIST_BG, onUpdateTex);
			m_rt = null;
			
			var lst:Array = m_lstItem.concat();
			
			for(var i:int = 0; i < lst.length; ++i)
			{
				var item:MenuItem = lst[i];
				if(item)
				{
					this.removeMenuItemWorker(item.id);
				}
			}
			
			lst = null;
			m_lstItem = null;
			
			m_timShow.stop();
			m_timShow.removeEventListener(TimerEvent.TIMER, onShowTimer);
			m_timShow = null;
			
			m_timHide.stop();
			m_timHide.removeEventListener(TimerEvent.TIMER, onHideTimer);
			m_timHide = null;
		}
		

		
		private function onShowTimer(e:Event):void
		{
			this.alpha += TWEEN_SHOW;
			if(this.alpha >= 1)
			{
				m_timShow.stop();
			}
		}
		
		private function onHideTimer(e:Event):void
		{
			this.alpha += TWEEN_HIDE;
			if(this.alpha <= 0)
			{
				m_timHide.stop();
				this.visible = false;
			}
			
			var evt:MenuEvent = new MenuEvent(MenuEvent.MENU_HIDE);
			this.dispatchEvent(evt);
		}
		
		override public function get width():Number
		{
			return m_width;
		}
		
		override public function get height():Number
		{
			return m_height;
		}
		
		private function onUpdateTex(e:Event):void
		{
			updateTexWorker();
		}
		
		private function updateTexWorker():void
		{
			if(m_rt.cfg.texListBg)
			{
				if(m_bg != null && this.contains(m_bg))
				{
					this.removeChild(m_bg);
				}
				
				m_bg = new (m_rt.cfg.texListBg);
				this.addChild(m_bg);
				this.setChildIndex(m_bg, 0);
			}
		}
		
		public function updateLayout():void
		{
			var cfg:MenuConfig = m_rt.cfg;
			var tempH:Number = cfg.listTopGap;
			var itemW:Number = 0;
			var item:MenuItem;
			var i:int;
			//更新每一个菜单项的布局
			for(i = 0; i < m_lstItem.length; ++i)
			{
				item = m_lstItem[i];
				item.updateLayout();
				item.x = cfg.listLeftGap;
				item.y = tempH;
				tempH = tempH + item.height + cfg.listGap;
				if(itemW < item.width)
				{
					itemW = item.width;
				}
			}
			
			m_height = tempH + cfg.listBottomGap - cfg.listGap;
			m_width = itemW + cfg.listLeftGap + cfg.listRightGap;
			
			
			//重设每一个菜单项的尺寸
			for(i = 0; i < m_lstItem.length; ++i)
			{
				item = m_lstItem[i];
				item.updateWidth(itemW);
			}
			

			//更新列表背景的布局
			this.graphics.clear();
			if(m_bg == null)
			{
				this.graphics.beginFill(0xff0000, 0.5);
				this.graphics.drawRect(0,0,this.width, this.height);
				this.graphics.endFill();
			}
			else
			{
				m_bg.width = this.width;
				m_bg.height = this.height;
			}
		}
		
		public function popup():void
		{
			if(this.visible == false)
			{
				this.visible = true;
				this.alpha = 0;
				m_timShow.start();
			}
			else if(this.alpha < 1)
			{
				m_timShow.start();
			}
			m_timHide.stop();
		}
		
		public function hide():void
		{
			m_timHide.start();
		}
		
		public function addMenuItem(fullPath:String, label:*, priority:int, 
									listener:Function):MenuItem
		{
			var nextPath:String = "";
			var currPath:String = "";
			
			var i:int = fullPath.indexOf(",", 0);
			if(i < 0)
			{
				currPath = fullPath;
			}
			else
			{
				currPath = fullPath.substr(0, i);
				nextPath = fullPath.substr(i + 1);
			}
			
			var item:MenuItem;
			if(nextPath == "")
			{
				item = addMenuItemWorker(currPath, label, priority, listener);
			}
			else
			{
				item = addNullMenuItemWorker(currPath, currPath);
				item.addMenuItem(nextPath, label, priority, listener);
			}
			
			return item;
		}
		
		public function removeMenuItem(fullPath:String):MenuItem
		{
			var nextPath:String = "";
			var currPath:String = "";
			
			var i:int = fullPath.indexOf(",", 0);
			if(i < 0)
			{
				currPath = fullPath;
			}
			else
			{
				currPath = fullPath.substr(0, i);
				nextPath = fullPath.substr(i + 1);
			}
			
			var item:MenuItem;
			if(nextPath == "")
			{
				item = removeMenuItemWorker(currPath);
			}
			else
			{
				item = getMenuItemWorker(currPath);
				item.removeMenuItem(nextPath);
			}

			return item;
		}
		
		private function addMenuItemWorker(id:*, label:*, priority:int = 0, listener:Function = null):MenuItem
		{
			var item:MenuItem = m_mapItem[id];
			if(item == null)
			{
				item = new MenuItem();
				item.create(id, listener, m_rt);
				this.addChild(item);
				m_mapItem[id] = item;
				m_lstItem.push(item);
			}
			
			item.priority = priority;
			item.listener = listener;
			item.label = label;
			m_lstItem.sortOn("priority");
			
			return item;
		}
		
		
		private function removeMenuItemWorker(id:String):MenuItem
		{
			var item:MenuItem = m_mapItem[id];
			if(item != null)
			{
				item.release();
				this.removeChild(item);
				m_mapItem[id] = null;
				delete m_mapItem[id];
				var i:int = m_lstItem.indexOf(item);
				m_lstItem.splice(i,1);
			}
			return item;
		}
		
		private function addNullMenuItemWorker(id:*, label:*):MenuItem
		{
			var item:MenuItem = m_mapItem[id];
			if(item == null)
			{
				item = new MenuItem();
				item.create(id, null, m_rt);
				this.addChild(item);
				m_mapItem[id] = item;
				m_lstItem.push(item);
				m_lstItem.sortOn("priority");
			}
			item.label = label;
			return item;
		}
		

		
		public function getMenuItem(fullPath:String):MenuItem
		{
			var nextPath:String = "";
			var currPath:String = "";
			
			var i:int = fullPath.indexOf(",", 0);
			if(i < 0)
			{
				currPath = fullPath;
			}
			else
			{
				currPath = fullPath.substr(0, i);
				nextPath = fullPath.substr(i + 1);
			}
			
			var item:MenuItem;
			if(nextPath == "")
			{
				item = getMenuItemWorker(currPath);
			}
			else
			{
				item = getMenuItemWorker(currPath);
				if(item != null)
				{
					item = item.getMenuItem(nextPath);
				}
			}
			
			return item;
		}
		
		
		private function getMenuItemWorker(id:*):MenuItem
		{
			var item:MenuItem = m_mapItem[id];
			return item;
		}
		
	}
}