package slicol.foundation.so
{
	import com.tencent.fge.utils.ClassUtil;
	import com.tencent.fge.utils.StringUtil;
	
	import flash.net.SharedObject;

	public dynamic class SOLocalData extends Object
	{
		private var m_name:String = "";
		private var m_so:SharedObject;
		private var m_autoFlush:Boolean = false;
		
		public function SOLocalData(autoFlush:Boolean = false)
		{
			super();
			m_autoFlush = autoFlush;
			m_name = ClassUtil.getFullName(this);
			m_name = StringUtil.replace(m_name, "::", ".");
			
			try
			{
				m_so = SharedObject.getLocal(m_name);
			}
			catch(e:Error)
			{
				
			}
		}
		
		public function get name():String
		{
			return m_name;
		}
		
		public function flush():void
		{
			if(m_so)
			{
				m_so.flush();
			}
		}
		
		public function save(id:String, value:*):void
		{
			if(m_so)
			{
				m_so.data[id] = value;
				if(m_autoFlush)
				{
					flush();
				}			
			}

		}
		
		public function read(id:String):*
		{
			if(m_so)
			{
				return m_so.data[id];
			}
			return undefined;
		}
	}
}