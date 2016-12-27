package com.tencent.fge.framework.vermanager
{
	public  class VersionItem
	{
		public static const NODE_NAME: String = "VersionItem";
		
		public var md5: String;
		public var path: String;
		public var type: String;
		
		public function VersionItem()
		{
		}
		
		public function get realPath(): String
		{
			return path.replace(originName, realName);
		}
		
		public function get extension(): String
		{
			if (isNullString(type))
			{
				var name: String = this.originName;
				var index: int = name.lastIndexOf(".");
				return index >= 0 ? name.substring(index + 1) : "";
			}
			return this.type;
		}
		
		public function get mainName(): String
		{
			var name: String = this.originName;
			var index: int = name.lastIndexOf(".");
			return index >= 0 ? name.substring(0, index) : name;
		}
		
		public function get originName(): String
		{
			var index: int = path.lastIndexOf("/");
			return path.substring(index + 1);
		}
		
		public function get realName(): String
		{
			var ext: String = this.extension;
			return this.mainName + "_" + md5 + (isNullString(ext) ? "" : "." + ext);
		}
		
		public function forEachItem(callback: Function, args: Array = null): *
		{
			if (args)
			{
				args = args.concat(this);
			}
			else
			{
				args = [this];
			}
			return callback.apply(null, args);
		}
		
		public function fromXML(xml: XML): Boolean
		{
			try
			{
				this.md5 = xml.@md5;
				this.path = xml.@path;
				this.type = xml.@type;
				return true;
			}
			catch (e: Error)
			{}
			return false;
		}
		
		public function toXMLString(): String
		{
			return	"<" + NODE_NAME + 
					" md5=\"" + nonNullString(md5) + 
					"\" path=\"" + nonNullString(path) + 
					"\" type=\"" + nonNullString(type) + "\"/>\r\n";
		}
		
		private static function isNullString(str: String): Boolean
		{
			return str == null || str == "";
		}
		
		private static function nonNullString(str: String): String
		{
			return isNullString(str) ? "" : str;
		}
	}
}