package slicol.framework.mvc
{
	import com.tencent.fge.utils.ClassUtil;
	
	import flash.utils.Dictionary;

	public class Controller
	{
		private static var ms_mapCmd:Dictionary = new Dictionary;
		
		public function Controller()
		{
		}
		
		
		public static function addCommand(cmd:Class):void
		{
			var name:String = ClassUtil.getFullName(cmd);
			ms_mapCmd[name] = cmd;
		}
		

		
		public static function removeCommand(cmd:*):void
		{
			var name:String = adjustName(cmd);
			try
			{
				delete ms_mapCmd[name];
			}
			catch(e:Error)
			{}
		}
		
		private static function adjustName(name:*):String
		{
			if(name is Class)
			{
				name = ClassUtil.getFullName(name);
			}
			
			if(!(name is String))
			{
				name = String(name);
			}
			
			return name;
		}
		
		
		
		public static function execute(cmd:*, ...arg):void
		{
			if(!(cmd is Class))
			{
				var name:String = adjustName(cmd);
				cmd = ms_mapCmd[name];
			}
			
			if(cmd is Class)
			{
				var theCmd:Command = new cmd;
				theCmd.execute(arg);
				return;
			}
			
			
			
		}
	}
}