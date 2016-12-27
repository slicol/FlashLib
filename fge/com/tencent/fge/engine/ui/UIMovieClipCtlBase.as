package com.tencent.fge.engine.ui
{
	import com.tencent.fge.utils.SWFUtil;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	
	public class UIMovieClipCtlBase extends MovieClip
	{		
		protected var m_parent:DisplayObjectContainer;
		protected var m_dispIndex:int;
		protected var m_ui:MovieClip;
		protected var m_lstBindProperty:Vector.<BindedProperty>;
		private var m_constraints:*;
		
		public function UIMovieClipCtlBase(ui:MovieClip = null)
		{
			super();
			m_ui = ui;
			m_parent = m_ui.parent;
		}
		
		
		public function bindExternalUIMovieClip(ui:MovieClip):void
		{
			
		}
		
		
		public function dispose():void
		{
			m_parent = null;
			m_ui = null;
			m_lstBindProperty = null;
			m_dispIndex = 0;
			m_constraints = null;
		}
		
		public function set constraints(value:*):void{m_constraints = value;}
		public function get constraints():*{return m_constraints;}
		
		public function appendParent(target:DisplayObject, newParent:Sprite):Sprite
		{
			target = checkUIMovieClipCtl(target);
			newParent = checkUIMovieClipCtl(newParent);

			
			if(target && newParent)
			{
				var oldParent:DisplayObjectContainer = target.parent;
				oldParent.addChildAt(newParent, oldParent.getChildIndex(target));
				newParent.addChild(target);
				return newParent;
			}
			
			return null;
		}
		
		
		public function set renderable(value:Boolean):void
		{
			if(value)
			{
				if(!m_ui.parent)
				{
					if(m_parent)
					{
						if(m_dispIndex > m_parent.numChildren)
						{
							m_dispIndex = m_parent.numChildren;
						}
						if(m_dispIndex < 0)
						{
							m_dispIndex = 0;
						}
						
						m_parent.addChildAt(m_ui, m_dispIndex);
					}
				}
			}
			else
			{
				if(m_ui.parent)
				{
					m_parent = m_ui.parent;
					m_dispIndex = m_parent.getChildIndex(m_ui);
					m_parent.removeChild(m_ui);
				}
			}
		}
		
		
		protected function replaceDisplayObject(src:*, dst:DisplayObject, bSynSize:Boolean = false):void
		{
			if(src is String)
			{
				src = m_ui[src];
			}
			
			src = checkUIMovieClipCtl(src);
			dst = checkUIMovieClipCtl(dst);
	
			
			if(src is DisplayObject && dst is DisplayObject)
			{
				var idx:int;
				var parent:DisplayObjectContainer;
				
				parent = src.parent;
				
				if(parent)
				{
					idx = parent.getChildIndex(src);
					dst.x = src.x;
					dst.y = src.y;
					if(src.width != 0 && src.height != 0)
					{
						if(bSynSize)
						{
							dst.width = src.width;
							dst.height = src.height;
						}
					}
					parent.removeChild(src);
					parent.addChildAt(dst, idx);
				}
			}
		}
		
		public function get ui():MovieClip{return m_ui;}
		
		
		public function bindProperty(mine:String, data:Object, property:String):void
		{
			if(m_lstBindProperty == null)
			{
				m_lstBindProperty = new Vector.<BindedProperty>;
			}
			
			var p:BindedProperty;
			
			for(var i:int = 0; i < m_lstBindProperty.length; ++i)
			{
				p = m_lstBindProperty[i];
				
				if(p.mine == mine)
				{
					break;
				}
			}
			
			if(i < m_lstBindProperty.length)
			{
				p.data = data;
				p.property = property;
			}
			else
			{
				p = new BindedProperty;
				p.mine = mine;
				p.data = data;
				p.property = property;
				m_lstBindProperty.push(p);
			}
		}
		
		public function unbindAllProperty():void
		{
			if(m_lstBindProperty)
			{
				m_lstBindProperty.length = 0;
			}
		}
		
		
		protected function updateAllProperty():void
		{
			if(!m_lstBindProperty)
			{
				return;
			}
			
			var p:BindedProperty;
			

			for(var i:int = 0; i < m_lstBindProperty.length; ++i)
			{
				p = m_lstBindProperty[i];
				this[p.mine] = p.data[p.property];
			}			
			
		}
		
		protected function updateProperty(mineProperty:String = ""):void
		{
			if(!m_lstBindProperty)
			{
				return;
			}
				
			
			var p:BindedProperty;
			
			if(mineProperty == "" || mineProperty == null)
			{
				updateAllProperty();
			}
			else
			{
				for(var i:int = 0; i < m_lstBindProperty.length; ++i)
				{
					p = m_lstBindProperty[i];
					
					if(p.mine == mineProperty)
					{
						this[p.mine] = p.data[p.property];
						break;
					}
				}
			}
		}
		
		
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			child = checkUIMovieClipCtl(child);
			return ui.addChildAt(child, index);			
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			child = checkUIMovieClipCtl(child);
			
			if(child)
			{
				return ui.addChild(child);
			}
		
			
			return null;
		}
		
		override public function getChildIndex(child:DisplayObject):int
		{
			child = checkUIMovieClipCtl(child);
			
			if(child)
			{
				return ui.getChildIndex(child);
			}
			
			
			return -1;
		}
		
		override public function contains(child:DisplayObject):Boolean
		{
			child = checkUIMovieClipCtl(child);
			
			if(child)
			{
				return ui.contains(child);
			}
			
			return false;
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			child = checkUIMovieClipCtl(child);

			if(child && ui.contains(child))
			{
				return ui.removeChild(child);
			}
			return null;
		}
		
		
		public function removeAllChildren():void
		{
			try
			{
				ui.removeChildren(0, int.MAX_VALUE);
				return;
			}
			catch(e:Error)
			{
				
			}
			
			try
			{
				SWFUtil.clearChildren(ui);
			}
			catch(e:Error)
			{
				
			}
		}
		
		public static function removeAllChildren(ui:MovieClip):void
		{
			try
			{
				ui.removeChildren(0, int.MAX_VALUE);
				return;
			}
			catch(e:Error)
			{
				
			}
			
			try
			{
				SWFUtil.clearChildren(ui);
			}
			catch(e:Error)
			{
				
			}
		}
		

		
		protected function checkUIMovieClipCtl(disp:*):*
		{
			if(disp is UIMovieClipCtlBase)
			{
				return UIMovieClipCtlBase(disp).ui;
			}
			return disp;
		}
		
		public function active():void
		{
			//用来启用一个UI
		}
		
		public function deactive():void
		{
			//用来让一个UI不使用
		}

		
		
		
		override public function get numChildren():int{return ui.numChildren;}
		
		override public function set x(value:Number):void{m_ui.x = value;}
		override public function set y(value:Number):void{m_ui.y = value;}
		override public function get x():Number{return m_ui.x;}
		override public function get y():Number{return m_ui.y;}
		
		override public function get scaleX():Number{return m_ui.scaleX;}
		override public function set scaleX(value:Number):void{	m_ui.scaleX = value;}
		override public function get scaleY():Number{return m_ui.scaleY;}
		override public function set scaleY(value:Number):void{	m_ui.scaleY = value;}
		
		override public function set width(value:Number):void{m_ui.width = value;}
		override public function set height(value:Number):void{m_ui.height = value;}
		override public function get width():Number{return m_ui.width;}
		override public function get height():Number{return m_ui.height;}
		
		override public function set visible(value:Boolean):void{m_ui.visible = value;}		
		override public function get visible():Boolean{return m_ui.visible;}	
		
		override public function set alpha(value:Number):void{m_ui.alpha = value;}		
		override public function get alpha():Number{return m_ui.alpha;}	
		
		override public function get enabled():Boolean{return m_ui.enabled;}
		override public function set enabled(value:Boolean):void{m_ui.enabled = value;}
		
		override public function get mouseEnabled():Boolean{return m_ui.mouseEnabled;}
		override public function set mouseEnabled(enabled:Boolean):void{m_ui.mouseEnabled = enabled;}
		
		override public function get mouseChildren():Boolean{return m_ui.mouseChildren;}
		override public function set mouseChildren(enabled:Boolean):void{m_ui.mouseChildren = enabled;}
		
		override public function get stage():Stage{return m_ui.stage;}
		override public function get parent():DisplayObjectContainer{return m_ui.parent;}
		
		override public function play():void{m_ui.play();}
		override public function stop():void{m_ui.stop();}
		
		override public function gotoAndPlay(frame:Object, scene:String=null):void
		{
			try
			{
				m_ui.gotoAndPlay(frame, scene);
			}catch(e:Error){}
		}
		
		override public function gotoAndStop(frame:Object, scene:String=null):void
		{
			try
			{
				m_ui.gotoAndStop(frame, scene);
			}catch(e:Error){}
		}
		

		
		override public function set filters(value:Array):void{m_ui.filters = value;}
		override public function get filters():Array{return m_ui.filters;}
	}
}

class BindedProperty 
{
	public var mine:String = "";
	public var data:Object;
	public var property:String = "";
}