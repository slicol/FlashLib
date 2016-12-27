package slicol.foundation.singleton.test
{
	import slicol.foundation.singleton.SingletonFactory;
	
	public class CaseSubFactory extends SingletonFactory
	{
		public function CaseSubFactory()
		{
			
		}
		
		public static function regMySingleton(item:*):void
		{
			SingletonFactory.getFactory(CaseSubFactory).regSingleton(item);
		}
		
		public static function getMySingletonInstance(name:*):*
		{
			return SingletonFactory.getFactory(CaseSubFactory).getInstance(name);
		}
	}
}