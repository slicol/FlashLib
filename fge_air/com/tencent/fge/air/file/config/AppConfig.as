package com.tencent.fge.air.file.config
{
	import com.tencent.fge.air.file.utils.FileUtil;
	
	import flash.filesystem.File;
	import flash.utils.Dictionary;

	public class AppConfig
	{
		private static var ms_mapConfig:Dictionary = new Dictionary;
		
		public static function getConfig(name:String):AppConfig
		{
			var cfg:AppConfig = ms_mapConfig[name];
			if(!cfg)
			{
				cfg = new AppConfig(name);
				ms_mapConfig[name] = cfg;
			}
			return cfg;
		}
		
		public static function open(name:String):AppConfig
		{
			var cfg:AppConfig = getConfig(name);
			cfg.open();
			return cfg;
		}
		
		public static function save(name:String):AppConfig
		{
			var cfg:AppConfig = getConfig(name);
			cfg.save();
			return cfg;
		}
		
		
		public static function getItem(cfgname:String, itemid:String):*
		{
			var cfg:AppConfig = getConfig(cfgname);
			return cfg.getItem(itemid);
		}
		
		public static function setItem(cfgname:String, itemid:String, value:*):void
		{
			var cfg:AppConfig = getConfig(cfgname);
			cfg.setItem(itemid, value);
		}
		
		public static function getItemIDList(cfgname:String):Vector.<String>
		{
			var cfg:AppConfig = getConfig(cfgname);
			return cfg.getItemIDList();
		}
		
		
		private var m_name:String = "";
		private var m_filename:String = "";
		
		private var m_mapItem:Dictionary = new Dictionary;
		

		public function AppConfig(name:String)
		{
			m_name = name;
			
			if(!name)
			{
				throw Error("name is NULL!");
			}
			
			m_filename = m_name + ".xml";
		}
		
		public static var debug:Boolean = true;
		
		public static function getFullPath(filename:String):String
		{
			var file:File = File.applicationStorageDirectory;
			file = file.resolvePath(filename);
			
			if(debug)
			{
				file = File.desktopDirectory;
				file = file.resolvePath(filename);
			}
			
			return file.nativePath;
		}
		
		public function open(filename:String = ""):void
		{
			if(filename)
			{
				m_filename = filename;
			}
			
			var path:String = getFullPath(m_filename);

			var s:String = FileUtil.openTextFile(path);
			
			if(s)
			{
				var xmlCfg:XML = new XML(s);
				
				var xl:XMLList = xmlCfg..Item;
				
				for(var i:int = 0; i < xl.length(); ++i)
				{
					var xml:XML = xl[i];
					var item:CfgItem = new CfgItem(xml);
					m_mapItem[item.id] = item;
				}
			}

		}
		
		public function save(filename:String = ""):void
		{
			if(filename)
			{
				m_filename = filename;
			}			
			
			var s:String = "<Config>\n";
			
			for each(var item:CfgItem in m_mapItem)
			{
				s += item.toXmlString() + "\n";
			}
			
			s += "</Config>";
			
			
			var path:String = getFullPath(m_filename);
			
			FileUtil.saveTextFile(path, s);
		}
		

		
		public function setItem(id:String, value:*):void
		{
			var item:CfgItem = m_mapItem[id];
			if(!item)
			{
				item = new CfgItem();
				m_mapItem[id] = item;
				item.id = id;
				item.value = value;
			}
			else
			{
				item.value = value;
			}
		}
		
		public function getItem(id:String):*
		{
			var item:CfgItem = m_mapItem[id];
			if(item)
			{
				return item.value;
			}
			
			return null;
		}
		
		public function getItemIDList():Vector.<String>
		{
			var list:Vector.<String> = new Vector.<String>;
			
			for each(var item:CfgItem in m_mapItem)
			{
				list.push(item.id);
			}
			
			return list;
		}
	}
}

class CfgItem
{
	public static const TYPE_NULL:String = "";
	public static const TYPE_STR:String = "string";
	public static const TYPE_NUM:String = "number";
	public static const TYPE_BOOL:String = "boolean";
	public static const TYPE_ARR_STR:String = "array_string";
	public static const TYPE_ARR_NUM:String = "array_number";

	public var id:String = "";	
	private var m_value:*;
	
	
	public function CfgItem(xml:XML = null):void
	{
		if(xml)
		{
			id = xml.@id;
			
			setXmlValue(xml.@type, xml.@value);			
		}
	}
	
	public function get value():*
	{
		return m_value;
	}
	
	public function set value(data:*):void
	{
		m_value = data;
	}
	
	public function getXmlValue(type:String):String
	{
		var ret:String = "";
		
		switch(type)
		{
			case TYPE_STR:
			case TYPE_NUM:
			case TYPE_BOOL:
				ret = String(m_value);
				break;
			case TYPE_ARR_STR:
			case TYPE_ARR_NUM:
				ret = array2string(m_value);
				break;
			default:
				ret = String(m_value);
				break;
		}
		
		return ret;
	}
	
	public function setXmlValue(type:String, data:String):void
	{
		switch(type)
		{
			case TYPE_STR:
				m_value = !data ? "" : data;
				break;
			case TYPE_NUM:
				m_value = Number(data);
				break;
			case TYPE_BOOL:
				m_value = data == "true";
				break;
			case TYPE_ARR_STR:
				m_value = data.split(",");
				break;
			case TYPE_ARR_NUM:
				m_value = data.split(",");
				toNumArray(m_value);
				break;
			default:
				m_value = !data ? "" : data;
				break;
		}
	}
	
	
	public function toXmlString():String
	{
		var type:String = getValueType();
		
		return "<Item id='"+id+"' type='"+type+"' value='"+getXmlValue(type)+"'/>";
	}
	
	
	public function getValueType():String
	{
		if(m_value is int || m_value is Number)
		{
			return TYPE_NUM;
		}
		else if(m_value is Boolean)
		{
			return TYPE_BOOL;
		}
		else if(m_value is Array)
		{
			if(m_value.length <= 0)
			{
				return TYPE_ARR_STR;
			}
			else
			{
				if(m_value[0] is int || m_value[0] is Number)
				{
					return TYPE_ARR_NUM;
				}
				
				return TYPE_ARR_STR;
			}
		}
		
		return TYPE_STR;
	}
	
	
	private static function toNumArray(array:Array):void
	{
		for(var i:int = 0; i < array.length; ++i)
		{
			array[i] = Number(array[i]);
		}
	}
	
	private static function array2string(array:Array):String
	{
		var ret:String = "";
	
		if(array.length > 0)
		{
			ret = String(array[0]);
			
			if(array.length > 1)
			{
				for(var i:int = 1; i < array.length; ++i)
				{
					var data:String = String(array[i]);
					ret = ret + "," + data;
				}
			}
		}

		return ret;
		
	}
}