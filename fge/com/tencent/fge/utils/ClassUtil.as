package com.tencent.fge.utils
{
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;
	
	public class ClassUtil
	{
		private var m_fullName:String = "";
		private var m_name:String = "";
		private var m_domain:ApplicationDomain;
		
		public function ClassUtil(value:Object, domain:ApplicationDomain = null)
		{
			m_fullName = getQualifiedClassName(value);
			var i:int = m_fullName.lastIndexOf("::");
			m_name = m_fullName.substring(i+2);	
			m_domain = domain;
			if(m_domain == null)
			{
				m_domain = ApplicationDomain.currentDomain;
			}
		}
		
		public function get fullValue():String
		{
			return m_fullName;
		}
		
		public function get value():String
		{
			return m_name;
		}
		
		public function getDefinition():Class
		{
			return m_domain.getDefinition(m_fullName) as Class;
		}
		
		public static function getFullName(value:Object):String
		{
			return getQualifiedClassName(value);
		}
		
		public static function getName(value:Object):String
		{
			var fullName:String = getQualifiedClassName(value);
			var i:int = fullName.lastIndexOf("::");
			return fullName.substring(i+2);	
		}

	}
}