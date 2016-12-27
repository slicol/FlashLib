package com.tencent.fge.framework.vermanager
{
	final public class VersionList
	{
		public static const ROOT_NAME: String = "VersionList";
		
		protected var items: Vector.<VersionItem>;
		public var baseUrl: String;
		
		public function VersionList()
		{
			this.items = new Vector.<VersionItem>();
		}
		
		public function resolvePath(path: String): String
		{
			if (this.baseUrl != null && this.baseUrl != "")
			{
				return this.baseUrl + "/" + path;
			}
			return path;
		}
		
		public function forEachItem(callback: Function, args: Array = null): *
		{
			if (args)
			{
				args = args.concat(this);
			}
			
			var done: * = undefined;
			for each (var item: VersionItem in this.items)
			{
				done = item.forEachItem(callback, args);
				if (done) break;
			}
			return done;
		}
		
		public function dispose(): void
		{
			this.items.length = 0;
		}
		
		public function get isEmpty(): Boolean
		{
			return this.items == null || this.items.length == 0;
		}
		
		public function fromXML(xml: XML): Boolean
		{
			try
			{
				this.dispose();
				this.baseUrl = xml.@baseUrl;
				var subXmls: XMLList = xml.children();
				for each (var subXml: XML in subXmls)
				{
					var item: VersionItem = new VersionItem();
					if (item.fromXML(subXml))
					{
						this.items.push(item);
					}
				}
				return true;
			}
			catch (e: Error)
			{}
			return false;
		}
		
		public function toXMLString(): String
		{
			var xml: String = "<" + ROOT_NAME +" baseUrl=\"" + this.baseUrl + "\">\r\n";
			for each (var item: VersionItem in items)
			{
				xml += item.toXMLString();
			}
			xml += "</" + ROOT_NAME + ">\r\n";
			return xml;
		}
	}
}