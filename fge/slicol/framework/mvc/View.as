package slicol.framework.mvc
{
	import flash.display.Sprite;
	
	import slicol.foundation.singleton.SingletonFactory;
	
	
	public class View extends SingletonFactory
	{
		public static var container:Sprite;
		
		public function View()
		{
			SingletonFactory.regSingleton(this, true);
		}
		
		public static function get me():View
		{
			return SingletonFactory.getInstance(View);
		}
		
		public static function addView(item:*):void
		{
			SingletonFactory.getFactory(View).regSingleton(item);
		}
		
		public static function getView(name:*):*
		{
			return SingletonFactory.getFactory(View).getInstance(name);
		}
		
		public static function getInstance(name:*):*
		{
			return SingletonFactory.getFactory(View).getInstance(name);
		}
		
	}
}

