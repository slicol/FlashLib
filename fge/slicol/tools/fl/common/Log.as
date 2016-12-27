package slicol.tools.fl.common
{
	import adobe.utils.MMExecute;
	
	import spark.components.TextArea;

	public class Log
	{
		public static var txtOutput:TextArea;
		
		public static function trace(...args):void
		{
			var s:String = args.join(",");

			if(EnvChecker.IsInFlashCS)
			{
				MMExecute("fl.trace(\""+s+"\");");
			}
			txtOutput.appendText(s + "\n");
		}
	}
}

