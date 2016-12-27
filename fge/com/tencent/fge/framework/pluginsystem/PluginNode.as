/*************************************************************************
 版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
 *************************************************************************/
/*************************************************************************
 #   File Name   :   PluginNode.as
 #   Version     :   1.0.0
 #   Author      :   slicoltang
 #   Date        :   2010-8
 #   Comment     :  对一个实际插件的封装。插件系统会先建立一个PluginNode树。
 * 					然后插件系统再根据这棵“结点树”的父子关系，去调用各个PluginNode加载其应对的实际插件。
 * 					
 
 #  	Modify      :   2010-8 文件创建 
 #
 *************************************************************************/

package com.tencent.fge.framework.pluginsystem
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.pluginsystem.data.PluginData;
	import com.tencent.fge.framework.pluginsystem.data.PluginRes;
	import com.tencent.fge.framework.pluginsystem.events.ExtensionPointEvent;
	import com.tencent.fge.framework.pluginsystem.events.PluginEvent;
	import com.tencent.fge.framework.pluginsystem.interfaces.IPlugin;
	import com.tencent.fge.framework.pluginsystem.interfaces.IPluginStub;
	import com.tencent.fge.framework.pluginsystem.interfaces.IPluginSystem;
	
	import flash.events.EventDispatcher;
	import flash.sampler.getInvocationCount;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	

	[Event(name="loadComplete", type="com.tencent.fge.framework.pluginsystem.events.ExtensionPointEvent")]
	[Event(name="loadError", type="com.tencent.fge.framework.pluginsystem.events.ExtensionPointEvent")]
	[Event(name="loadComplete", type="com.tencent.fge.framework.pluginsystem.events.PluginEvent")]
	[Event(name="loadError", type="com.tencent.fge.framework.pluginsystem.events.PluginEvent")]
	
	public class PluginNode extends EventDispatcher implements IPluginStub
	{
		private var m_data:PluginData = new PluginData;
		private var m_loader:PluginLoader = null;
		private var m_plugin:IPlugin = null;
		private var m_startParam:* = null;
		private var m_tblCondition:Dictionary = new Dictionary;
		
		private var m_parent:PluginNode;
		private var m_parentPluginId:String = "";
		private var m_parentExtPoint:String = "";
		
		
		private var m_tblInterface:Dictionary = new Dictionary();
		private var m_children:Array = new Array;
		private var m_tblExtPoint:Array = new Array;

		
		private var m_directInit:Boolean = false;
		private var m_hasCreated:Boolean = false;
		private var m_hasInit:Boolean = false;
		private var m_loadExtPtIndex:int = -1;
		private var m_loadAllExtPtIndex:int = -1;
		
		private var log:Log = new Log(this);

		
		public function PluginNode(data:PluginData)
		{
			m_data.value = data;
			m_loader = new PluginLoader(this);
			var i:int = m_data.extension.lastIndexOf(".");
			m_parentPluginId = m_data.extension.substring(0, i);
			m_parentExtPoint = m_data.extension.substring(i + 1);
		}
		
		
		public function get id():String{return m_data.id;}
		public function get data():PluginData{return m_data;}
		public function get pluginSystem():IPluginSystem{return PluginSystem.getInstance();}
		
		public function get parent():PluginNode{return m_parent;}
		public function set parent(value:PluginNode):void{m_parent = value;}
		
		public function get extension():String{return m_data.extension;}
		public function get parentPluginId():String{return m_parentPluginId;}
		public function get startParam():* { return m_startParam; }
		
		
		public function addChildPlugin(node:PluginNode):void
		{
			var i:int = m_children.indexOf(node);
			if(i >= 0) return;
			m_children.push(node);
		}
		
		public function addExtensionPoint(extPoint:ExtensionPoint):void
		{
			var i:int = m_tblExtPoint.indexOf(extPoint);
			if(i < 0)
			{
				m_tblExtPoint.push(extPoint);
			}
		}
		
		
		public function getExtensionPointDataList():Array
		{
			var lst:Array = new Array;
			
			for(var i:int = 0; i < m_tblExtPoint.length; ++i)
			{
				var ep:ExtensionPoint = m_tblExtPoint[i];
				lst.push(ep.data.clone());
			}
			
			return lst;
		}
		
		public function getChildrenDataList():Array
		{
			var lst:Array = new Array;

			for(var i:int = 0; i < m_children.length; ++i)
			{
				var node:PluginNode = m_children[i];
				var data:PluginData = node.data.clone();
				lst.push(data);
			}
			
			return lst;
		}
		
		public function getChildrenDataListByPoint(extpt:String):Array
		{
			var lst:Array = new Array;
			var lstExt:Array = null;
			
			for(var i:int = 0; i < m_tblExtPoint.length; ++i)
			{
				var extPt:ExtensionPoint = m_tblExtPoint[i];
				if(extPt.localId == extpt)
				{
					lstExt = extPt.getExtension();
					break;
				}
			}
			
			if(lstExt)
			{
				for(i = 0; i < lstExt.length; ++i)
				{
					var node:PluginNode = lstExt[i];
					var data:PluginData = node.data.clone();
					lst.push(data);
				}
			}
			
			return lst;
		}
		
		
		public function load(directInit:Boolean, startParam:*):void
		{
			m_startParam = startParam;
			m_directInit = directInit;
			m_loader.load(m_data);
			m_loader.addEventListener(PluginEvent.LOAD_COMPLETE, onLoadEvent);
			m_loader.addEventListener(PluginEvent.LOAD_PROGRESS, onLoadEvent);
			m_loader.addEventListener(PluginEvent.LOAD_ERROR, onLoadEvent);
		}
		
		public function initialize():void
		{
			if(m_hasInit) return;
			if(m_plugin)
			{
				var tmp:int = getTimer();
				
				if(PluginSystem.IgnorePluginInitializeError)
				{
					try
					{
						m_plugin.initialize();
					}
					catch(e:Error)
					{
						log.error("initialize", "Plugin[" + this.id + "] Init Error!");
					}
				}
				else
				{
					m_plugin.initialize();
				}
				
				tmp = getTimer() - tmp;
				
				PluginDebuger.timestats_init(id, tmp);
				
				loadExtensionPointAuto();
				m_hasInit = true;
			}
		}
		
		public function loadExtensionPoint(localExtPtId:String, startParam:*):void
		{
			for(var i:int = 0; i < m_tblExtPoint.length; ++i)
			{
				var extPt:ExtensionPoint = m_tblExtPoint[i];
				if(extPt.localId == localExtPtId)
				{
					extPt.load(startParam);
					extPt.addEventListener(ExtensionPointEvent.LOAD_COMPLETE, onExtPointEvent);
					extPt.addEventListener(ExtensionPointEvent.LOAD_ERROR, onExtPointEvent);
					break;
				}
			}
		}
		
		public function loadExtensionPointEx(globalExtPtId:String, startParam:*):int
		{
			var i:int = globalExtPtId.lastIndexOf(".");
			var localExtPtId:String = globalExtPtId.slice(i+1);
			var plgId:String = globalExtPtId.slice(0, i);
			
			if(plgId == this.id)
			{
				if(m_hasCreated)
				{
					loadExtensionPoint(localExtPtId, startParam);
					return -1;
				}
				return 0;
			}
			else
			{
				var node:PluginNode;
				for(i = 0; i < m_children.length; ++i)
				{
					node = m_children[i];
					var ret:int = node.loadExtensionPointEx(globalExtPtId, startParam);
					
					if(ret <= 0)
					{
						return ret;
					}
				}
				
				return 1;
			}
		}
		
		
		public function setExtensionPointLazy(localExtPtId:String, lazy:Boolean):void
		{
			for(var i:int = 0; i < m_tblExtPoint.length; ++i)
			{
				var extPt:ExtensionPoint = m_tblExtPoint[i];
				if(extPt.localId == localExtPtId)
				{
					extPt.lazy = lazy;
					break;
				}
			}
		}
		
		
		public function setExtensionPointLazyEx(globalExtPtId:String, lazy:Boolean):int
		{
			var i:int = globalExtPtId.lastIndexOf(".");
			var localExtPtId:String = globalExtPtId.slice(i+1);
			var plgId:String = globalExtPtId.slice(0, i);
			
			if(plgId == this.id)
			{
				setExtensionPointLazy(localExtPtId, lazy);
				return 0;
			}
			else
			{
				var node:PluginNode;
				for(i = 0; i < m_children.length; ++i)
				{
					node = m_children[i];
					var ret:int = node.setExtensionPointLazyEx(globalExtPtId, lazy);
					
					if(ret == 0)
					{
						return ret;
					}
				}
				
				return 1;
			}
		}
		
		
		public function loadAllExtensionPoint():void
		{
			loadAllExtensionPointAuto();
		}
		
		public function loadExtensionPointAuto():void
		{
			m_loadExtPtIndex = 0;
			loadExtensionPointAutoNext();
		}
		
		public function loadAllExtensionPointAuto():void
		{
			m_loadAllExtPtIndex = 0;
			loadAllExtensionPointAutoNext();
		}
		
		
		
		private function loadExtensionPointAutoNext():void
		{
			var extPt:ExtensionPoint;
			for(var i:int = m_loadExtPtIndex; i < m_tblExtPoint.length; ++i)
			{
				extPt = m_tblExtPoint[i];
				if(!extPt.lazy)
				{
					break;
				}
			}
			
			if(i < m_tblExtPoint.length)
			{
				m_loadExtPtIndex = i;
				extPt.load(false);
				extPt.addEventListener(ExtensionPointEvent.LOAD_COMPLETE, onExtPointEvent);
				extPt.addEventListener(ExtensionPointEvent.LOAD_ERROR, onExtPointEvent);
			}
		}
		
		private function loadAllExtensionPointAutoNext():void
		{
			var extPt:ExtensionPoint;
			for(var i:int = m_loadAllExtPtIndex; i < m_tblExtPoint.length; ++i)
			{
				extPt = m_tblExtPoint[i];
				if(extPt != null)
				{
					break;
				}
			}

			if(i < m_tblExtPoint.length)
			{
				m_loadAllExtPtIndex = i;
				extPt.load(false);
				extPt.addEventListener(ExtensionPointEvent.LOAD_COMPLETE, onAllExtPointEvent);
				extPt.addEventListener(ExtensionPointEvent.LOAD_ERROR, onAllExtPointEvent);
			}
		}
		
		
		public function queryInterface(iid:*, ver:int = 0):*
		{
			if(!(iid is String))
			{
				iid = getQualifiedClassName(iid);
			}
			
			var ref:* = m_tblInterface[iid];
			if(ref == null)
			{
				if(m_parent != null)
				{
					return m_parent.queryInterface(iid, ver);
				}
			}
			return ref;
		}
		
		public function getCondition(id:String):Boolean
		{
			var value:* = m_tblCondition[id];
			if(value == null)
			{
				if(m_parent != null)
				{
					return m_parent.getCondition(id);
				}
				
				return false;
			}
			
			return Boolean(value);
		}
		
		public function setCondition(id:String, value:Boolean):void
		{
			m_tblCondition[id] = value;
		}
		
		
		internal function queryInterfaceLocal(iid:String, ver:int = 0):*
		{
			return m_tblInterface[iid];
		}
		
		public function regInterface(iid:*, ref:*):void
		{
			if(!(iid is String))
			{
				iid = getQualifiedClassName(iid);
			}
						
			var r:* = m_tblInterface[iid];
			if(r == null)
			{
				m_tblInterface[iid] = ref;
			}
			if(m_parent)
			{
				m_parent.regBrotherInterface(iid, ref);
			}
		}
		
		private function regBrotherInterface(iid:*, ref:*):void
		{
			if(!(iid is String))
			{
				iid = getQualifiedClassName(iid);
			}
			
			var r:* = m_tblInterface[iid];
			if(r == null)
			{
				m_tblInterface[iid] = ref;
			}
		}
		
		public function unregInterface(iid:*, ref:*):void
		{
			if(!(iid is String))
			{
				iid = getQualifiedClassName(iid);
			}
			
			var r:* = m_tblInterface[iid];
			if(r != null && r == ref)
			{
				delete m_tblInterface[iid];
			}
			if(m_parent)
			{
				m_parent.unregBrotherInterface(iid, ref);
			}
			
		}
		
		private function unregBrotherInterface(iid:*, ref:*):void
		{
			if(!(iid is String))
			{
				iid = getQualifiedClassName(iid);
			}
			
			var r:* = m_tblInterface[iid];
			if(r != null && r == ref)
			{
				delete m_tblInterface[iid];
			}
		}
		
		public function getPluginRes(id:String):PluginRes
		{
			for(var i:int = 0; i < m_data.res.length; ++i)
			{
				var res:PluginRes = m_data.res[i];
				if(res.id == id)
				{
					return res;
				}
			}
			return null;
		}
		
		private function createPlugin():void
		{
			if(m_hasCreated) return;
			
			m_plugin = m_loader.getPlugin(m_data.runtime);
			
			var tmp:int = getTimer();
			
			m_plugin.create(this);
			
			tmp = getTimer() - tmp;
			PluginDebuger.timestats_create(this.id, tmp);
			
			m_hasCreated = true;
		}
		
		
		
		private function onLoadEvent(e:PluginEvent):void
		{
			var evt:PluginEvent;
			
			switch(e.type)
			{
			case PluginEvent.LOAD_PROGRESS:
				pluginSystem.dispatchEvent(e);
				break;
			
			case PluginEvent.LOAD_COMPLETE:
				createPlugin();
				if(m_directInit)
				{
					initialize();
				}
				
				this.dispatchEvent(e);
				pluginSystem.dispatchEvent(e);
				break;
			
			case PluginEvent.LOAD_ERROR:
				this.dispatchEvent(e);
				pluginSystem.dispatchEvent(e);
				break;
			
			default:
				break;
			}
		}
		

		private function onExtPointEvent(e:ExtensionPointEvent):void
		{
			var extPt:ExtensionPoint = e.target as ExtensionPoint;
			extPt.removeEventListener(ExtensionPointEvent.LOAD_COMPLETE, onExtPointEvent);
			extPt.removeEventListener(ExtensionPointEvent.LOAD_ERROR, onExtPointEvent);
			
			if( m_loadExtPtIndex >= 0 &&
				m_loadExtPtIndex < m_tblExtPoint.length && 
				extPt == m_tblExtPoint[m_loadExtPtIndex])
			{
				++m_loadExtPtIndex;
				if(m_loadExtPtIndex < m_tblExtPoint.length)
				{
					loadExtensionPointAutoNext();
				}
				else
				{
					m_loadExtPtIndex = -1;
				}
			}
			else
			{
				this.dispatchEvent(e);
			}
		}		
		
		
		private function onAllExtPointEvent(e:ExtensionPointEvent):void
		{
			var extPt:ExtensionPoint = e.target as ExtensionPoint;
			extPt.removeEventListener(ExtensionPointEvent.LOAD_COMPLETE, onAllExtPointEvent);
			extPt.removeEventListener(ExtensionPointEvent.LOAD_ERROR, onAllExtPointEvent);
			
			if( m_loadAllExtPtIndex >= 0 &&
				m_loadAllExtPtIndex < m_tblExtPoint.length && 
				extPt == m_tblExtPoint[m_loadAllExtPtIndex])
			{
				++m_loadAllExtPtIndex;
				if(m_loadAllExtPtIndex < m_tblExtPoint.length)
				{
					loadAllExtensionPointAutoNext();
				}
				else
				{
					m_loadAllExtPtIndex = -1;
				}
			}
			else
			{
				this.dispatchEvent(e);
			}
		}
		
	}
}