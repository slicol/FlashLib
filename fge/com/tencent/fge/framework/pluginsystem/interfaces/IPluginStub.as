package com.tencent.fge.framework.pluginsystem.interfaces
{
	import com.tencent.fge.framework.pluginsystem.data.PluginData;
	import com.tencent.fge.framework.pluginsystem.data.PluginRes;

	public interface IPluginStub
	{
		function regInterface(iid:*, ref:*):void;
		function unregInterface(iid:*, ref:*):void;
		function queryInterface(iid:*, ver:int = 0):*;
		function loadExtensionPoint(localExtPtId:String, startParam:*):void;
		function loadExtensionPointEx(globalExtPtId:String, startParam:*):int
		function loadAllExtensionPoint():void;
		function getPluginRes(id:String):PluginRes;
		//function getChildrenList(lazy:Boolean = false):Array;
		function get startParam():*;
		function get data():PluginData;
		function get pluginSystem():IPluginSystem;
		function getCondition(id:String):Boolean;
		function setCondition(id:String, value:Boolean):void;
		function getExtensionPointDataList():Array;
		function setExtensionPointLazyEx(globalExtPtId:String, lazy:Boolean):int;
	}
}