package slicol.engine.object
{
	
	

	public class ComponentObject extends AbstractObject
	{
		private static var ms_lstInstance:Vector.<AbstractObject> = new Vector.<AbstractObject>;
		
		public static function find(id:String):ComponentObject
		{
			for each(var instance:AbstractObject in ms_lstInstance)
			{
				if(instance.id == id)
				{
					return instance as ComponentObject;
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
		
		private var m_gameObject:GameObject;
		public function get gameObject():GameObject{return m_gameObject;}

		
		public function ComponentObject(type:String = "", id:String = "")
		{
			super(type, id)
			add(this);
		}
		
		public function dispose():void
		{
			remove(this);
			m_gameObject = null;
		}
		
		//---------------------------------------------------------------
		
		internal function _awake(gameObject:GameObject):void
		{
			m_gameObject = gameObject;
			awake();
		}
		
		internal function _start():void
		{
			start();
		}
		
		//---------------------------------------------------------------
		
		public function awake():void
		{
			
		}
		
		public function start():void
		{
			
		}

		public function fixedUpdate():void
		{
			
		}
		
		public function update():void
		{
			
		}
		
		public function lateUpdate():void
		{
			
		}
		
	}
}