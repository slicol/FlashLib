/*************************************************************************
 版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
 *************************************************************************/
/*************************************************************************
 #   File Name   :   PluginManager.as
 #   Version     :   1.0.0
 #   Author      :   slicoltang
 #   Date        :   2010-8
 #   Comment     :  该类负责根据配置文件里所描述的各个插件的数据，建立一个PluginNode树（结点树）。
 * 					它仅仅是建立结点树，并不加载实际的插件。
 
 #  	Modify      :   2010-8 文件创建 
 #
 *************************************************************************/

package com.tencent.fge.framework.pluginsystem
{
	import com.tencent.fge.framework.pluginsystem.data.ExtensionPointData;
	import com.tencent.fge.framework.pluginsystem.data.PluginData;
	import com.tencent.fge.framework.pluginsystem.events.ExtensionPointEvent;
	import com.tencent.fge.framework.pluginsystem.events.PluginEvent;
	import com.tencent.fge.framework.pluginsystem.interfaces.IPlugin;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	

	public class PluginManager extends PluginNode
	{
		private var m_lstExtPoint:Dictionary = new Dictionary;
		private var m_lstPluginNode:Dictionary = new Dictionary;
		private var m_rootdata:PluginData = new PluginData;
		
		public function PluginManager()
		{
			m_rootdata.id = getQualifiedClassName(this);
			m_rootdata.name = m_rootdata.id;
			super(m_rootdata);
		}
		
		public function addPluginData(data:PluginData):void
		{
			var node:PluginNode;
			var extPt:ExtensionPoint;
			
			node = m_lstPluginNode[data.id];
			if(node == null)
			{
				node = new PluginNode(data);
				
				var nodeParent:PluginNode = m_lstPluginNode[node.parentPluginId];
				if(nodeParent != null)
				{
					node.parent = nodeParent;
					nodeParent.addChildPlugin(node);
					
					extPt = m_lstExtPoint[node.extension];
					if(extPt != null)
					{
						extPt.addExtension(node);
					}
				}
				
				for(var i:int = 0; i < data.extPoints.length; ++i)
				{
					var dataExtPt:ExtensionPointData = data.extPoints[i];
					extPt = new ExtensionPoint(data.id, dataExtPt);
					
					for each(var nodTmp:PluginNode in m_lstPluginNode)
					{
						if(nodTmp.extension == extPt.id)
						{
							node.addChildPlugin(nodTmp);
							nodTmp.parent = node;
							
							extPt.addExtension(nodTmp);
						}
					}
					
					m_lstExtPoint[extPt.id] = extPt;
					node.addExtensionPoint(extPt);
				}
				
				m_lstPluginNode[node.id] = node;
			}
		}
		
		public function loadPlugin(id:String):void
		{
			var node:PluginNode = m_lstPluginNode[id];
			if(node)
			{
				this.addChildPlugin(node);
				node.parent = this;
				node.load(true, null);
			}
		}
		
		//插件管理器是一个特殊的Node，如果需要，它可以获取系统内的所有插件
		override public function queryInterface(iid:*, ver:int = 0):*
		{
			if(!(iid is String))
			{
				iid = getQualifiedClassName(iid);
			}
			
			var ref:* = null;
			
			for each(var nodTmp:PluginNode in m_lstPluginNode)
			{
				ref = nodTmp.queryInterfaceLocal(iid, ver);
				if(ref != null)
				{
					break;
				}
			}
			
			return ref;
		}
		
		public function getPluginExtensionPointDataList(plgid:String):Array
		{
			var node:PluginNode = m_lstPluginNode[plgid];
			if(node)
			{
				return node.getExtensionPointDataList();
			}
			return [];
		}
		
		
		public function getPluginChildrenDataList(plgid:String):Array
		{
		
			var node:PluginNode = m_lstPluginNode[plgid];
			if(node)
			{
				return node.getChildrenDataList();
			}
			return [];
			
		}
		
		public function getPluginChildrenDataListByPoint(plgid:String, extpt:String):Array
		{
			var node:PluginNode = m_lstPluginNode[plgid];
			if(node)
			{
				return node.getChildrenDataListByPoint(extpt);
			}
			return [];
			
		}
	}
}