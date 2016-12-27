package com.tencent.fge.framework.pluginsystem.data
{
	public class ExtensionPointData
	{
		public var id:String = "";
		public var name:String = "";
		public var lazy:Boolean = false;
		
		public function clone():ExtensionPointData
		{
			var data:ExtensionPointData = new ExtensionPointData;
			data.id = this.id;
			data.name = this.name;
			data.lazy = this.lazy;
			return data;
		}
	}
}