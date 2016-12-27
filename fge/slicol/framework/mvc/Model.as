package slicol.framework.mvc
{
	import slicol.foundation.singleton.SingletonFactory;
	

	public class Model extends SingletonFactory
	{
	
		public function Model()
		{
			SingletonFactory.regSingleton(this, true);
		}
		
		public static function get me():Model
		{
			return SingletonFactory.getInstance(Model);
		}
		
		public static function addModel(item:*):void
		{
			SingletonFactory.getFactory(Model).regSingleton(item, false);
		}
		
		public static function getInstance(name:*):*
		{
			return SingletonFactory.getFactory(Model).getInstance(name);
		}
		
	}
}

