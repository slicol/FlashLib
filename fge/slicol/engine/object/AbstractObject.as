package slicol.engine.object
{
	import com.tencent.fge.utils.ClassUtil;
	
	import flash.utils.Dictionary;

	public class AbstractObject
	{
		private static var m_mapTypeCount:Dictionary = new Dictionary;
		
		private var m_type:String = "";
		private var m_id:String = "";

		public function get type():String{return m_type;}
		public function get id():String{return m_id;}
		
		public function AbstractObject(type:String = "", id:String = "")
		{
			m_type = type;
			
			if(!m_type)
			{
				m_type = ClassUtil.getName(this);
			}
			
			m_id = id;
			if(!m_id)
			{
				var cnt:int = m_mapTypeCount[m_type];
				cnt++;
				m_id = m_type + "#" + cnt;
				m_mapTypeCount[m_type] = cnt;
			}
			
		}
	}
}