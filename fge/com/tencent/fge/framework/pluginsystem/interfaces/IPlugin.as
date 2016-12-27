package com.tencent.fge.framework.pluginsystem.interfaces
{
	import com.tencent.fge.framework.pluginsystem.data.PluginData;
	
	import flash.events.IEventDispatcher;
	
	public interface IPlugin extends IEventDispatcher
	{
		function create(stub:IPluginStub):void;
		function initialize():void;
		function finalize():void;
		function get id():String;
	}
}