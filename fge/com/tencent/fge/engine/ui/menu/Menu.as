package com.tencent.fge.engine.ui.menu
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;

	public class Menu extends Sprite
	{
		private var m_rt:MenuRuntime;
		private var m_hasPopup:Boolean = false;
		private var m_listRoot:MenuList;

		private var m_stage_for_hide:EventDispatcher;
		
		public function Menu()
		{
			super();
		}
		
		override public function get name():String
		{
			return m_rt.name;
		}
		
		public function create(stage:DisplayObjectContainer,
							   container:DisplayObjectContainer, 
							   name:String, cfg:MenuConfig = null):void
		{
			m_rt = new MenuRuntime;
			m_rt.container = container;
			m_rt.name = name;
			m_rt.menu = this;
			m_rt.stage = stage;
			

			if(cfg == null)
			{
				cfg = new MenuConfig;
				cfg.containerWidth = container.width;
				cfg.containerHeight = container.height;
			}

			m_rt.cfg = cfg;
			m_rt.containerWidth = cfg.containerWidth;
			m_rt.containerHeight = cfg.containerHeight;
			
			m_listRoot = new MenuList();
			this.addChild(m_listRoot);
			m_listRoot.create(m_rt);
			
			m_listRoot.addEventListener(MenuEvent.MENU_HIDE, onMenuListHide);
			
			m_listRoot.updateLayout();
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		public function release():void
		{
			m_rt.container = null;
			m_rt.name = "";
			m_rt.menu = null;
			m_rt.menuTarget = null;
			m_rt.cfg = null;
			m_rt = null;
			
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			m_listRoot.release();
			m_listRoot.removeEventListener(MenuEvent.MENU_HIDE, onMenuListHide);
			m_listRoot = null;
		}

		public function setTextFormat(fmtNormal:TextFormat, fmtOver:TextFormat, 
									  fmtDown:TextFormat, fmtDisable:TextFormat):void
		{
			m_rt.cfg.setTextFormat(fmtNormal, fmtOver, fmtDown, fmtDisable);
			m_listRoot.updateLayout();
		}
		
		public function setTexture(bgList:Class,
								   bgItemNormal:Class, bgItemOver:Class, 
								   bgItemDown:Class, bgItemDisable:Class,
								   childMenuIcon:Class):void
		{
			m_rt.cfg.setTexture(bgList, bgItemNormal, bgItemOver, 
				bgItemDown, bgItemDisable, childMenuIcon);
			m_listRoot.updateLayout();
		}
		
		public function setContainerSize(w:Number, h:Number):void
		{
			m_rt.containerWidth = w > 0? w:m_rt.containerWidth;
			m_rt.containerHeight = h > 0? h:m_rt.containerHeight;
				
			var cfg:MenuConfig = m_rt.cfg;
			if(cfg)
			{
				cfg.containerWidth = m_rt.containerWidth;
				cfg.containerHeight = m_rt.containerHeight;
			}
		}
		
		
		public function addMenuItem(fullPath:String, label:*, priority:int, listener:Function):MenuItem
		{
			var item:MenuItem = m_listRoot.addMenuItem(fullPath, label, priority, listener);
			m_listRoot.updateLayout();
			return item;
		}
		
		public function removeMenuItem(fullPath:String):MenuItem
		{
			var item:MenuItem = m_listRoot.removeMenuItem(fullPath);
			m_listRoot.updateLayout();
			return item;
		}
		
		public function getMenuItem(fullPath:String):MenuItem
		{
			var item:MenuItem = m_listRoot.getMenuItem(fullPath);
			return item;
		}
		
		public function setMenuItemState(fullPath:String, state:int):void
		{
			var item:MenuItem = m_listRoot.getMenuItem(fullPath);
			if(item)
			{
				item.state = state;
			}
		}
		
		public function setMenuItemEnable(fullPath:String, value:Boolean):void
		{
			var item:MenuItem = m_listRoot.getMenuItem(fullPath);
			if(item)
			{
				item.enable = value;
			}
		}
		
		public function popup(stageX:Number,stageY:Number, target:Object = null, listener:Function = null):void
		{
			var pt:Point = new Point(stageX,stageY);
			var ptList:Point = new Point(0, 0);
			
			
			//计算坐标
			var container:DisplayObjectContainer = m_rt.container;
			
			if(container)
			{
				if( !container.contains(this))
				{
					container.addChild(this);
				}
				
				pt = container.globalToLocal(pt);
				
				this.x = pt.x;
				this.y = pt.y;
				
				ptList = this.localToGlobal(ptList);
				ptList = container.globalToLocal(ptList);
			}
			
			m_hasPopup = true;
			m_rt.menuTarget = target;
			
			
			
			//调整坐标
			if(ptList.x + m_listRoot.width >= m_rt.containerWidth)
			{
				ptList.x = -m_listRoot.width;
			}
			else
			{
				ptList.x = 0;
			}
			
			if(ptList.y + m_listRoot.height >= m_rt.containerHeight)
			{
				ptList.y = -m_listRoot.height + 0;
			}
			else
			{
				ptList.y = 0;
			}
			
			m_listRoot.x = ptList.x;
			m_listRoot.y = ptList.y;
			
			//弹出菜单
			m_listRoot.popup();
			
			if(listener != null)
			{
				m_rt.addEventListener(MenuEvent.MENU_CLICK, listener);
			}
			
			m_rt.addEventListener(MenuEvent.MENU_CLICK, onMenuClick);
			m_rt.listener = listener;
			
			
			//监听隐藏菜单的事件
			m_stage_for_hide = m_rt.stage.stage;
			if(m_stage_for_hide == null) 
			{
				m_stage_for_hide = m_rt.stage;
			}
			
			if(m_stage_for_hide != null)
			{
				m_stage_for_hide.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			}
		}
		
		private function onStageMouseDown(e:Event):void
		{
			hide();
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
		}
		
		public function get hasPopup():Boolean
		{
			return m_hasPopup;
		}
		
	
		
		public function hide():void
		{
			if(m_stage_for_hide != null)
			{
				m_stage_for_hide.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
				m_stage_for_hide = null;
			}
			
			m_hasPopup = false;
			m_rt.menuTarget = null;
			m_listRoot.hide();
			if(m_rt.listener != null)
			{
				m_rt.removeEventListener(MenuEvent.MENU_CLICK, onMenuClick);
				m_rt.removeEventListener(MenuEvent.MENU_CLICK, m_rt.listener);
				m_rt.listener = null;
			}
		}
		
		private function onMenuListHide(e:Event):void
		{
			if(m_rt.container && (m_rt.container.contains(this)))
			{
				m_rt.container.removeChild(this);
			}
		}
		
		private function onMenuClick(e:MenuEvent):void
		{
			this.dispatchEvent(e);
		}
		
	}
}