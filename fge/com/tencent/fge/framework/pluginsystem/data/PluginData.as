package com.tencent.fge.framework.pluginsystem.data
{
	import flash.utils.Dictionary;

	public class PluginData
	{
		public var id:String = "";
		public var name:String = "";
		public var ver:String = "0";
		public var runtime:String = "";
		public var extension:String = "";
		
		public var res:Array = new Array;
		
		public var extPoints:Array = new Array;
		
		public var params:Object = new Object;
		
		public function set value(data:PluginData):void
		{
			this.id = data.id;
			this.name = data.name;
			this.ver = data.ver;
			this.runtime = data.runtime;
			this.extension = data.extension;
			this.res = data.res;
			this.extPoints = data.extPoints;
			this.params = data.params;
		}
		
		public function clone():PluginData
		{
			var data:PluginData = new PluginData;
			data.id = this.id;
			data.name = this.name;
			data.ver = this.ver;
			data.runtime = this.runtime;
			data.extension = this.extension;
			data.res = this.res;
			data.extPoints = this.extPoints;
			data.params = this.params;
			return data;
		}
		
	}
}