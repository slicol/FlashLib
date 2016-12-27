package com.tencent.fge.framework
{
	import com.tencent.fge.framework.pluginsystem.PluginSystem;
	import com.tencent.fge.framework.pluginsystem.interfaces.IPluginSystem;
	
	import flash.display.Sprite;
	
	public class Framework
	{
		public function Framework()
		{
			super();
		}
		
		public static function initialize(stage:Sprite):void
		{
			var pluginSystem:IPluginSystem = PluginSystem.getInstance();
			pluginSystem.initialize(stage);
		}
		
		public static function setBaseUrl(baseUrlRt:String, baseUrlRes:String):void
		{
			var pluginSystem:IPluginSystem = PluginSystem.getInstance();
			pluginSystem.setBaseUrl(baseUrlRt, baseUrlRes);
		}
		

		public static function addConfig(path:String):void
		{
			var pluginSystem:IPluginSystem = PluginSystem.getInstance();
			pluginSystem.addConfig(path);
		}
		
		public static function addConfigContent(content:String):void
		{
			var pluginSystem:IPluginSystem = PluginSystem.getInstance();
			pluginSystem.addConfigContent(content);
		}
		
		public static function startup(startPluginId:String):Boolean
		{
			var pluginSystem:IPluginSystem = PluginSystem.getInstance();
			return pluginSystem.startup(startPluginId);
		}
		
		public static function setPluginResLoadPipe(num:int):void
		{
			PluginSystem.PluginResLoadPipeNum = num;
		}
		
		public static function queryInterface(iid:*, ver:int = 0):*
		{
			var pluginSystem:IPluginSystem = PluginSystem.getInstance();
			return pluginSystem.queryInterface(iid, ver);
		}
		
		public static function regInterface(iid:*, ref:*):void
		{
			var pluginSystem:IPluginSystem = PluginSystem.getInstance();
			pluginSystem.regInterface(iid, ref);
		}
		
		public static function unregInterface(iid:*, ref:*):void
		{
			var pluginSystem:IPluginSystem = PluginSystem.getInstance();
			pluginSystem.unregInterface(iid, ref);
		}	
		
		public static function addEventListener(type:String, listener:Function, 
												useCapture:Boolean=false, priority:int=0, 
												useWeakReference:Boolean=false):void
		{
			var pluginSystem:IPluginSystem = PluginSystem.getInstance();
			pluginSystem.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public static function removeEventListener(type:String, listener:Function, 
												   useCapture:Boolean=false):void
		{
			var pluginSystem:IPluginSystem = PluginSystem.getInstance();
			pluginSystem.removeEventListener(type, listener, useCapture);
		}
		
	}
}