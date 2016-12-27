package slicol.tools.fl.common
{
	import adobe.utils.MMExecute;
	
	import flashx.textLayout.formats.LeadingModel;

	public class JSFL
	{
		private var m_path:String = "";

		public function JSFL(path:String)
		{
			m_path = JSFL.configURI + "WindowSWF/" + path;
			Log.trace("Create JSFL: " + m_path);
		}
		
		public static function call(func:String, ...args):*
		{
			var s:String = args.join(",");
			var cmd:String = func + "("+s+");";
			
			if(EnvChecker.IsInFlashCS)
			{
				return MMExecute(cmd);
			}
			return null;
		}
		
		public static function getter(property:String):*
		{
			if(EnvChecker.IsInFlashCS)
			{
				return MMExecute(property);
			}
			return null;
		}
		
		public static function runScript(path:String, func:String, ...args):*
		{
			return runScriptWorker(path, func, args);
		}
		
		public static function get configURI():String
		{
			return getter("fl.configURI");
		}
		
		
		public function call(func:String, ...args):*
		{
			return runScriptWorker(m_path,func,args);
		}
		
		
		private static function runScriptWorker(path:String, func:String, args:Array):*
		{
			var s:String = "";
			for(var i:int = 0; i < args.length; ++i)
			{
				var a:* = args[i];
				if(a is Number || a is int || a is uint)
				{
					a = a.toString();
				}
				else
				{
					a = "'" + a + "'";
				}
				
				if(i < args.length - 1)
				{
					s = s + a + ",";
				}
				else
				{
					s = s + a;
				}
				
				
			}
			
	
			var cmd:String = "fl.runScript" + "('"+path+"','"+func+"',"+s+");";
			
			if(!func)
			{
				cmd = "fl.runScript" + "('"+path+"');";
			}
			
			if(!s)
			{
				cmd = "fl.runScript" + "('"+path+"','"+func+"');";
			}
			
			if(EnvChecker.IsInFlashCS)
			{
				return MMExecute(cmd);
			}
			
			return null;
		}

		
		
		
		
	}
}