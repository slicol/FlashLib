package com.tencent.fge.framework.vermanager
{
	import com.tencent.fge.framework.resmanager.data.ResType;
	
	import flash.utils.Dictionary;

	final public class VersionManager
	{
		private static var ms_instance:VersionManager;
		
		private var verTable: VersionTable;
		private var mapVersionDatas: Dictionary;
		
		public static function getInstance():VersionManager
		{
			if(ms_instance == null)
			{
				ms_instance = new VersionManager;
			}
			return ms_instance;
		}
		
		public static function initialize(cfg:*):void
		{
			getInstance().initialize(cfg);
		}
		
		public static function getVersionData(path: String): VersionData
		{
			return getInstance().getVersionData(path);
		}
		
		public static function getVersionDataEx(path: String): VersionData
		{
			return getInstance().getVersionDataEx(path);
		}
		
		public static function reloadVersionConfig(cfgContent:String):Boolean
		{
			return getInstance().reloadVersionConfig(cfgContent);
		}
		
		public function VersionManager()
		{
			verTable = new VersionTable();
			mapVersionDatas = new Dictionary();
		}
		
		public function initialize(versionXML: *): void
		{
			if(versionXML is String)
			{
				versionXML = new XML(versionXML);
			}
			
			verTable.fromXML(versionXML);
			verTable.forEachItem(doMapVersionData, []);
			verTable.dispose();
		}
		
		public function reloadVersionConfig(cfgContent:String):Boolean
		{
			var newVerTable:VersionTable = new VersionTable();
			var ret:Boolean = newVerTable.fromXML(new XML(cfgContent));
			if(ret)
			{
				newVerTable.forEachItem(doMapVersionData, []);
				newVerTable.dispose();
			}
			return ret;
		}
		
		
		private function doMapVersionData(list: VersionList, item: VersionItem): *
		{
			var data: VersionData = new VersionData();
			data.realurl = list.resolvePath(item.realPath);
			data.encrypt = item.type;
			data.restype = ResType.NULL;
			data.md5 = item.md5;
			
			var mapVersionData: Dictionary = getMapVersionData(list.baseUrl);
			mapVersionData[item.path] = data;
		}
		
		private function getMapVersionData(baseUrl: String): Dictionary
		{
			if (mapVersionDatas[baseUrl] == null)
			{
				mapVersionDatas[baseUrl] = new Dictionary();
			}
			return mapVersionDatas[baseUrl];
		}
		
		//以相对路径查表
		public function getVersionData(path: String): VersionData
		{
			for (var baseUrl: String in mapVersionDatas)
			{
				var mapVersionData: Dictionary = mapVersionDatas[baseUrl];
				var data: VersionData = mapVersionData[path];
				if (data)
				{
					return data;
				}
			}
			return null;
		}
		
		//优先以绝对路径查表，找不到再以相对路径查表
		public function getVersionDataEx(path: String): VersionData
		{
			if (path.substr(0,7) == "http://")
			{
				for (var baseUrl: String in mapVersionDatas)
				{
					var mapVersionData: Dictionary = mapVersionDatas[baseUrl];
					var prefix: String = path.substr(0, baseUrl.length);
					if (prefix == baseUrl)
					{
						//去除baseUrl前缀（包含一个/分隔符）
						var subPath: String = path.substring(baseUrl.length + 1);
						var data: VersionData = mapVersionData[subPath];
						if (data)
						{
							return data;
						}
					}
				}
				return null;
			}
			else
			{
				return getVersionData(path);
			}
		}
	}
}