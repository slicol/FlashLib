package com.tencent.fge.framework.vermanager
{
	final public class VersionTable
	{
		public static const ROOT_NAME: String = "VersionTable";
		
		protected var lists: Vector.<VersionList>;
		
		public function VersionTable()
		{
			this.lists = new Vector.<VersionList>();
		}
		
		public function forEachItem(callback: Function, args: Array = null): *
		{
			var done: * = undefined;
			for each (var list: VersionList in this.lists)
			{
				done = list.forEachItem(callback, args);
				if (done) break;
			}
			return done;
		}
		
		public function dispose(): void
		{
			for each (var list: VersionList in this.lists)
			{
				list.dispose();
			}
			this.lists.length = 0;
		}
		
		public function get isEmpty(): Boolean
		{
			for each (var list: VersionList in this.lists)
			{
				if (!list.isEmpty)
					return false;
			}
			return true;
		}
		
		public function fromXML(xml: XML): Boolean
		{
			try
			{
				this.dispose();
				var subXmls: XMLList = xml.children();
				for each (var subXml: XML in subXmls)
				{
					var list: VersionList = new VersionList();
					if (list.fromXML(subXml))
					{
						this.lists.push(list);
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
			var xml: String = "<" + ROOT_NAME + ">\r\n";
			for each (var list: VersionList in this.lists)
			{
				xml += list.toXMLString();
			}
			xml += "</" + ROOT_NAME + ">";
			return xml;
		}
	}
}