package slicol.framework.mvc
{
	import com.tencent.fge.foundation.signals.Signal;
	import com.tencent.fge.utils.ClassUtil;
	
	public class Command 
	{
		private var m_fullname:String = "";
		private var m_name:String = "";
		
		public function Command()
		{
			
		}
		
		public function get fullname():String
		{
			if(!m_fullname)
			{
				m_fullname = ClassUtil.getFullName(this);
			}
			return m_fullname;
		}
		
		public function get name():String
		{
			if(!m_name)
			{
				m_name = ClassUtil.getName(this);
			}
			return m_name;
		}
		
		
		
		public function execute(args:Array):void
		{
			
		}
	}
}