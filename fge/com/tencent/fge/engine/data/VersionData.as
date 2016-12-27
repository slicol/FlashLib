package com.tencent.fge.engine.data
{
	import flash.utils.Dictionary;

	/**
	 * 自身带有可版本管理的数据基类。
	 * 
	 * 数据提供者创建并管理VersionData的子类，子类可以有它们自己的业务变量。
	 * 
	 * 
	 * 数据提供者直接更改VersionData子类的业务变量。
	 * 当他认为关键数据已被修改时，数据提供者可以调用VersionData::increaseVersion()进行版本更新
	 * 
	 * 数据使用者直接访问VersionData的子类的业务变量。
	 * 数据使用者调用VersionData::isCurrentVersion()检查自己当前是否最新版本
	 * 当数据使用者发现自己的版本等于最新版本时，数据使用者不必执行更新数据的逻辑
	 * 当数据使用者发现自己的版本老于最新版本时，数据使用者才执行更新数据的逻辑
	 * 
	 * @author donaldwu
	 * 
	 */
	public class VersionData
	{
		private var m_mapDataTaker:Dictionary = new Dictionary(true);
		private var m_currVersion:uint;
		
		public function VersionData()
		{
			m_currVersion = 0;
		}
		
		/**
		 *当本对象对应的关键数据被数据提供者修改时，数据提供者可以调用本函数，进而提高本对象的版本号 
		 * 
		 */
		public function increaseVersion():void
		{
			// 不考虑超出uint范围的情况
			++m_currVersion;
		}
		
		
		/**
		 * 数据使用者检查自己当前是否最新版本，
		 * 当数据使用者发现自己的版本等于最新版本时，数据使用者不必执行更新数据的逻辑，
		 * 当数据使用者发现自己的版本老于最新版本时，数据使用者才执行更新数据的逻辑。
		 * 同时，传入对象将和本VersionData当前的版本绑定起来，以供下一次调用isCurrentVersion()时进行判断。
		 * 
		 * 
		 * @param object 数据使用者的实例对象
		 * @return 是否为最新版本
		 * 
		 */
		public function isCurrentVersion(object:Object):Boolean
		{
			var isCurrent:Boolean;
			if(null == m_mapDataTaker[object] || undefined == m_mapDataTaker[object] || m_currVersion > m_mapDataTaker[object])
			{
				isCurrent = false;
			}
			else
			{
				isCurrent = true;
			}
			
			if(false == isCurrent)
			{
				m_mapDataTaker[object] = m_currVersion;
			}
			
			return isCurrent;
		}
	}
}