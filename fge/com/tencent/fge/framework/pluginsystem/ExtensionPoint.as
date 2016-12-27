/*************************************************************************
 版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
 *************************************************************************/
/*************************************************************************
 #   File Name   :   ExtensionPoint.as
 #   Version     :   1.0.0
 #   Author      :   slicoltang
 #   Date        :   2010-8
 #   Comment     :  该类封装了插件（假设为A插件）的一个扩展点。
 * 					管理挂在该扩展点下的所有“扩展插件”（即A插件的一组子插件。）。
 
 #  	Modify      :   2010-8 文件创建 
 #
 *************************************************************************/
package com.tencent.fge.framework.pluginsystem
{
	import com.tencent.fge.framework.pluginsystem.data.ExtensionPointData;
	import com.tencent.fge.framework.pluginsystem.events.ExtensionPointEvent;
	import com.tencent.fge.framework.pluginsystem.events.PluginEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	[Event(name="loadComplete", type="com.tencent.fge.framework.pluginsystem.events.ExtensionPointEvent")]
	[Event(name="loadError", type="com.tencent.fge.framework.pluginsystem.events.ExtensionPointEvent")]
	
	public class ExtensionPoint extends EventDispatcher
	{
		private var m_data:ExtensionPointData;
		private var m_id:String = "";
		private var m_lstExtension:Array = new Array;
		private var m_loadIndex:int = -1;
		private var m_timer:Timer;
		private var m_hasLoaded:Boolean = false;
		private var m_startParam:* = null;
		
		public function ExtensionPoint(pluginId:String, data:ExtensionPointData)
		{
			m_data = data;
			m_id = localToGlobal(pluginId, m_data.id);
		}
		
		public static function localToGlobal(pluginId:String, localId:String):String
		{
			return pluginId + "." + localId;
		}
		
		public function get id():String{return m_id;}
		public function get localId():String{return m_data.id;}
		public function get lazy():Boolean{return m_data.lazy;}
		public function set lazy(value:Boolean):void{m_data.lazy = value;}
		public function get data():ExtensionPointData{return m_data;}
		
		public function load(startParam:*):void
		{
			if(m_hasLoaded || m_lstExtension.length == 0)
			{
				if(m_timer == null)
				{
					m_timer = new Timer(100,1);
				}
				m_timer.addEventListener(TimerEvent.TIMER, onTimer);
				m_timer.start();
				
				return;
			}
			
			m_startParam = startParam;
			m_loadIndex = 0;
			loadExtension(m_loadIndex);
		}
		
		private function loadExtension(index:int):void
		{
			var node:PluginNode = m_lstExtension[index];
			node.load(false, m_startParam);
			node.addEventListener(PluginEvent.LOAD_COMPLETE, onPluginEvent);
			node.addEventListener(PluginEvent.LOAD_ERROR, onPluginEvent);
		}
			
		
		public function getExtension():Array
		{
			return m_lstExtension.concat();
		}
		
		public function addExtension(node:PluginNode):void
		{
			var i:int = m_lstExtension.indexOf(node);
			if(i < 0)
			{
				m_lstExtension.push(node);
			}
		}
		
		private function initExtension():void
		{
			for(var i:int = 0; i < m_lstExtension.length; ++i)
			{
				var node:PluginNode = m_lstExtension[i];
				node.initialize();
			}
		}
		
		private function onPluginEvent(e:Event):void
		{
			var node:PluginNode = e.target as PluginNode;
			node.removeEventListener(PluginEvent.LOAD_COMPLETE, onPluginEvent);
			node.removeEventListener(PluginEvent.LOAD_ERROR, onPluginEvent);
			
			if( m_loadIndex >= 0 &&
				m_loadIndex < m_lstExtension.length &&
				node == m_lstExtension[m_loadIndex])
			{
				++m_loadIndex;
				if(m_loadIndex >= m_lstExtension.length)
				{
					m_loadIndex = -1;
					initExtension();
					m_hasLoaded = true;
					this.dispatchEvent(new ExtensionPointEvent(ExtensionPointEvent.LOAD_COMPLETE, m_id));
				}
				else
				{
					loadExtension(m_loadIndex);
				}				
			}
		}
		
		private function onTimer(e:Event):void
		{
			m_hasLoaded = true;
			m_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			this.dispatchEvent(new ExtensionPointEvent(ExtensionPointEvent.LOAD_COMPLETE, m_id));
		}
	}
}