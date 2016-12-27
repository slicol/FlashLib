package slicol.foundation.singleton.test
{
	import slicol.foundation.singleton.SingletonFactory;

	public class CaseA
	{
		public function CaseA()
		{
			SingletonFactory.regSingleton(this, true);
		}
		
		public static function get me():CaseA
		{
			return SingletonFactory.getInstance(CaseA);
		}
		
		
	}
}