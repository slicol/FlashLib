package slicol.foundation.singleton.test
{
	public class Case0
	{
		private static var ms_me:Case0;

		public function Case0()
		{
			if(ms_me)
			{
				throw Error("The Singleton [ Case0 ]'s Instance Has Existed!");
			}
			ms_me = this;
		}
		
		private static function get me():Case0
		{
			if(!ms_me)
			{
				ms_me = new Case0();
			}
			return ms_me;
		}
		

	}
}