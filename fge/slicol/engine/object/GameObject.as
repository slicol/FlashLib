package slicol.engine.object
{

	import Box2D.Common.Math.b2Transform;
	
	import flash.utils.Dictionary;
	
	import slicol.engine.math.Transform;
	import slicol.engine.scene.GameScene;
	import slicol.engine.slicol_engine_internal;
	
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	

	public class GameObject extends AbstractObject
	{
		private static var ms_lstInstance:Vector.<AbstractObject> = new Vector.<AbstractObject>;

		public static function find(id:String):GameObject
		{
			for each(var instance:AbstractObject in ms_lstInstance)
			{
				if(instance.id == id)
				{
					return instance as GameObject;
				}
			}
			return null;
		}
		
		private static function add(instance:AbstractObject):void
		{
			ms_lstInstance.push(instance);
		}
		
		private static function remove(instance:AbstractObject):void
		{
			var i:int = ms_lstInstance.indexOf(instance);
			if(i >= 0)
			{
				ms_lstInstance.splice(i,1);
			}
		}

		
		
		//---------------------------------------------------------------
		
		public var tag:String = "";
		public var layer:String = "";
		
		internal var m_xf:b2Transform = new b2Transform;
		public function get transform():b2Transform{return m_xf;}
		
		private var m_renderer:RenderComponent;
		public function get renderer():RenderComponent{return m_renderer;}

		private var m_lstComponent:Vector.<ComponentObject> = new Vector.<ComponentObject>;
		private var m_lstComponentNew:Vector.<ComponentObject> = new Vector.<ComponentObject>;
		
		
		

		public function GameObject(type:String = "", id:String = "")
		{
			super(type, id);
			add(this);
		}
		
		
		public function dispose():void
		{
			remove(this);
			
			m_renderer = null;
			
			for each(var obj:ComponentObject in m_lstComponent)
			{
				obj.dispose();
			}
			m_lstComponent.length = 0;
		}
		
		//---------------------------------------------------------------
		
		public function addComponent(comp:ComponentObject):void
		{
			if(m_lstComponent.indexOf(comp) < 0 && m_lstComponentNew.indexOf(comp) < 0)
			{
				m_lstComponentNew.push(comp);
				comp._awake(this);
			}
		}
		
		public function removeComponent(comp:ComponentObject):void
		{
			var hasFound:Boolean = false;
			
			var i:int = m_lstComponent.indexOf(comp);
			if(i >= 0)
			{
				hasFound = true;
				m_lstComponent.splice(i,1);
			}
			else
			{
				i = m_lstComponentNew.indexOf(comp);
				if(i >= 0)
				{
					hasFound = true;
					m_lstComponentNew.splice(i,1);
				}
			}
			
			if(hasFound)
			{
				if(m_renderer == comp)
				{
					m_renderer = null;
				}
				comp.dispose();
			}
		}
		
		public function findComponent(id:String):ComponentObject
		{
			for each(var instance:AbstractObject in m_lstComponent)
			{
				if(instance.id == id)
				{
					return instance as ComponentObject;
				}
			}
			return null;
		}
		
		//---------------------------------------------------------------
		
		slicol_engine_internal function _awake():void
		{
			awake();
		}
		
		slicol_engine_internal function _start():void
		{
			startNewComponent();
			start();
		}
		
		public function awake():void
		{

		}
				
		public function start():void
		{

		}
		
		private function startNewComponent():void
		{
			if(m_lstComponentNew.length == 0)
			{
				return;
			}
			
			var lstTmp:Vector.<ComponentObject> = m_lstComponentNew.concat();
			m_lstComponentNew.length = 0;
			
			var comp:ComponentObject;
			
			for each(comp in lstTmp)
			{
				comp._start();
			}
			
			m_lstComponent = m_lstComponent.concat(lstTmp);
		}
		
		public function fixedUpdate():void
		{
			for each(var comp:ComponentObject in m_lstComponent)
			{
				comp.fixedUpdate();
			}
		}
		
		public function update():void
		{
			for each(var comp:ComponentObject in m_lstComponent)
			{
				comp.update();
			}
		}
		
		slicol_engine_internal function customRender(support:RenderSupport, parentAlpha:Number):void
		{	
			if(m_renderer)
			{
				m_renderer.customRender(support, parentAlpha);
			}
		}
		
		public function lateUpdate():void
		{
			for each(var comp:ComponentObject in m_lstComponent)
			{
				comp.lateUpdate();
			}
			
			startNewComponent();
		}

	}
}