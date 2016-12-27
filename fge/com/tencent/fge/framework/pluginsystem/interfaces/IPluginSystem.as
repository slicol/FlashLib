package com.tencent.fge.framework.pluginsystem.interfaces
{
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	
	
	public interface IPluginSystem extends IEventDispatcher
	{
		function initialize(stage:Sprite):void;
		function setBaseUrl(baseUrlRt:String, baseUrlRes:String):void;
		function addConfig(path:String):void;
		function addConfigContent(content:String):void;
		function startup(startPluginId:String):Boolean;
		function regInterface(iid:*, ref:*):void;
		function unregInterface(iid:*, ref:*):void;
		function queryInterface(iid:*, ver:int = 0):*;
		function getPluginExtensionPointDataList(plgid:String):Array;
		function getPluginChildrenDataList(plgid:String):Array;
		function getPluginChildrenDataListByPoint(plgid:String, extpt:String):Array;
		function get stage():Sprite;
	}
}