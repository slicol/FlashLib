/*************************************************************************
 版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
 *************************************************************************/
/*************************************************************************
 #   File Name   :   BasePlugin.as
 #   Version     :   1.0.0
 #   Author      :   slicoltang
 #   Date        :   2010-8
 #   Comment     :  一个辅助类，让插件的定义更加方便
 * 					
 
 #  	Modify      :   2010-8 文件创建 
 #
 *************************************************************************/

package com.tencent.fge.framework.pluginsystem
{
	import com.tencent.fge.framework.pluginsystem.data.PluginData;
	import com.tencent.fge.framework.pluginsystem.interfaces.IPlugin;
	import com.tencent.fge.framework.pluginsystem.interfaces.IPluginStub;
	import com.tencent.fge.framework.pluginsystem.interfaces.IPluginSystem;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class BasePlugin extends Sprite implements IPlugin
	{
		protected var m_stub:IPluginStub;
		
		public function BasePlugin()
		{
		}
		
		public function create(stub:IPluginStub):void
		{
			m_stub = stub;
		}
		
		public function initialize():void
		{
	
		}
		
		public function finalize():void
		{
		}
		
		public function loadExtensionPoint(localExtPoint:String, startParam:*):void
		{
			m_stub.loadExtensionPoint(localExtPoint,startParam);
		}
		
		public function queryInterface(iid:*, ver:int=0):*
		{
			return m_stub.queryInterface(iid, ver);
		}
		
		public function regInterface(iid:*, ref:*):void
		{
			m_stub.regInterface(iid, ref);
		}
		
		public function unregInterface(iid:*, ref:*):void
		{
			m_stub.unregInterface(iid, ref);
		}
		
		public function get id():String
		{
			return m_stub.data.id;
		}
	}
}