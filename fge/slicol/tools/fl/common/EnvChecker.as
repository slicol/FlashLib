package slicol.tools.fl.common
{
	import adobe.utils.MMExecute;

	public class EnvChecker
	{
		public static var IsInFlashCS:Boolean = true;
		
		public function EnvChecker()
		{
		}
		
		public static function check():void
		{
			try
			{
				MMExecute("fl.trace(\"\");");
			}
			catch(e:Error)
			{
				IsInFlashCS = false;
			}
		}
	}
}