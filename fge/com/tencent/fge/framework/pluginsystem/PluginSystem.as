/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   PluginSystem.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-8
#   Comment     :   一个基于AS的通用插件系统框架。
 * 					它的基本原理是为每一个插件对应一个PluginNode。
 * 					在分析完所有的插件配置文件后，根据配置文件为每个插件生成一个PluginNode，且建立父子关系。
 * 					这时，插件系统就维护了一张完整的树状关系结构。
 * 					然后，插件系统会从startup（）函数开始，找到启动插件的PluginNode，再让PluginNode去加载对应的插件。
 * 					当这个插件加载完成后，再去寻找它的子插件对应的PluginNode，然后让该PluginNode去加载对应的插件。
 * 					它支持立即加载，和懒加载，两种加载方式。
 * 					立即加载，是指，在A的父插件被加载后，A必定会被框架自动加载。
 * 					懒加载，是指，在A的父插件被加载后，A不会被框架自动加载，而是需要在业务逻辑中显式的加载。
 * 
 * 					如有疑问，请与本人联系。
 * 					
 * 					插件配置的定义格式如下：
 
 	<!--------------------- ??插件---------------------DEL_ME>

	<!--定义插件的PluginID，用于在框架中唯一标志该插件，它是一个任意的字符串。示例中的命名规则可作为一个建议。-->
	<Plugin id="com.tencent.tnt.??" name="??" ver="0">

		<!--申明该插件所扩展的点的ID，即该插件将会被挂在该ID所对应的父插件上。
		这里描述该插件里拥有哪些模块，只是起到一个说明的作用，可有可无。--> 
		<Extension point="com.tencent.tnt.??">			
			<Module id="??" name="??" type="com.tencent.tnt.interfaces.??"/>	
		</Extension>
		 *
		<!--该插件的运行时。即，主文件。类似于C++里的DLL。-->
		<Runtime path="plugin_??.swf"/>
		
		<!--插件的一些参数，可以在插件内获取-->
		<Params>							
			<Param id="??">??</Param>
		</Params>

 		<!--插件所依赖的资源，会在加载Runtime之前，先加载这些 。-->
		<Resource>
			<Res id="??" path="assets/??/??.swf"/>
		</Resource>
	</Plugin>
	</-->
 
 * 
 * 
 * 
 * 					 一个完整的插件类的定义示例如下：
  
 	public class plugin_?? extends BasePlugin
	{
		//这个插件里有两个模块
		private var m_a:ModuleA;
		private var m_b:ModuleB;
		
		public function plugin_??()
		{
			
		}
		
		override public function create(stub:IPluginStub):void
		{
			super.create(stub);
			
			//创建这两个模块，并将其对外接口注册进插件系统。
			
			m_a = new :ModuleA(stub);
			stub.regInterface(IModuleA, m_a);

			 m_b = new ModuleB(stub);
			stub.regInterface( IModuleB,  m_b);
		}
		
		override public function initialize():void
		{
			//初始化这两个模块
			m_a.initialize();
			m_b.initialize();
		}
	}
 
 * 
 * 					插件系统的启动示例：
 * 
			Framework.initialize(this);
			Framework.addConfig("plugin_dbg.xml?timestamp=" + Math.random().toString());
			Framework.startup("com.tencent.tnt");
* 
#  	Modify      :   2010-8 文件创建 
#
*************************************************************************/

package com.tencent.fge.framework.pluginsystem
{
	import com.tencent.fge.framework.Framework;
	import com.tencent.fge.framework.pluginsystem.events.ExtensionPointEvent;
	import com.tencent.fge.framework.pluginsystem.interfaces.IPlugin;
	import com.tencent.fge.framework.pluginsystem.interfaces.IPluginSystem;
	import com.tencent.fge.framework.resmanager.ResManager;
	
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	

	public final class PluginSystem extends EventDispatcher implements IPluginSystem
	{
		private static var ms_instance:PluginSystem;
		private static var ms_stage:Sprite;
		
		private var m_cfgPathList:Array = new Array;
		private var m_cfgContentList:Array = new Array;
		private var m_mgrPlugin:PluginManager = new PluginManager;
		private var m_startPluginId:String = "";
		private var m_cfgIndex:int = 0;
		private var m_starting:Boolean = false;
		private var m_complete:Boolean = false;//由业务层来设置该值
		
		public static var IgnorePluginInitializeError:Boolean = false;
		public static var PluginResLoadPipeNum:int = 0;//0是默认值，就是1个通道。
		
		public function PluginSystem()
		{
			super();
			if(ms_instance != null)
			{
				throw Error("PluginSystem 不能被重复构造！");
			}
		}
		
		public function get stage():Sprite{return ms_stage;}
		public static function get stage():Sprite{return ms_stage;}
		
		public static function getInstance():IPluginSystem
		{
			if(ms_instance == null)
			{
				ms_instance = new PluginSystem;
			}
			return ms_instance;
		}
		
		//=============================================================================
		/**
		 * Desc		初始化插件系统
		 * Param	stage, 系统中显示对象展示的舞台。如果系统中不需要显示，可以为NULL。
		 **/
		public function initialize(stage:Sprite):void
		{
			ms_stage = stage;
			
			//为插件系统创建一个名为“plugin”的资源管理器实例。
			//且该资源管理器加载的资源，都使用当前ApplicationDomain。
			//这是为了方便插件接口和传换和获取。
			ResManager.createResManager("plugin");
		}
		
		
		public static function getDomainByName(name:String):ApplicationDomain
		{
			return PluginLoader.getDomainByName(name);
		}
		
		public static function addEventListener(type:String, listener:Function, 
												useCapture:Boolean = false, 
												priority:int = 0, 
												useWeakReference:Boolean = false):void
		{
			getInstance().addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			getInstance().removeEventListener(type, listener, useCapture);
		}
		
		//=============================================================================
		
		public static function set complete(value:Boolean):void
		{
			ms_instance.m_complete = value;
		}
		
		public static function get complete():Boolean
		{
			return ms_instance.m_complete;
		}
		
		//=============================================================================
		public function setBaseUrl(baseUrlRt:String, baseUrlRes:String):void
		{
			PluginConfig.BaseUrl_Runtime = baseUrlRt;
			PluginConfig.BaseUrl_Res = baseUrlRes;
		}
		
		
		
		//=============================================================================
		/**
		 * Desc		插件系统的启动
		 * Param	startPluginId,	
		 * 			插件系统将会从这个插件startPluginId开始，启动整个应用。
		 **/ 
		public function startup(startPluginId:String):Boolean
		{
			m_startPluginId = startPluginId;
			m_cfgIndex = 0;
			m_starting = loadConfig(m_cfgIndex);
			return m_starting;
		}
		
		
		
		//=============================================================================
		/**
		 * Desc		添加插件配置文件
		 * Param	path,配置文件路径
		 * 			可以将所有插件都放在一个配置文件里，也可以放在不同的配置文件里。
		 **/
		public function addConfig(path:String):void
		{
			if(m_starting)
			{
				return;
			}

			var i:int = m_cfgPathList.indexOf(path);
			
			if(i < 0 && path != null && path.length != 0)
			{
				m_cfgPathList.push(path);
			}
		}
		
		public function addConfigContent(content:String):void
		{
			if(m_starting)
			{
				return;
			}
			
			if(content != null && content.length != 0)
			{
				m_cfgContentList.push(content);
			}
		}
		
		//=============================================================================
		
		public function regInterface(iid:*, ref:*):void
		{
			m_mgrPlugin.regInterface(iid, ref);
		}
		
		public function unregInterface(iid:*, ref:*):void
		{
			m_mgrPlugin.unregInterface(iid, ref);
		}
		
		public function queryInterface(iid:*, ver:int = 0):*
		{
			return m_mgrPlugin.queryInterface(iid, ver);
		}
		
		public function getPluginExtensionPointDataList(plgid:String):Array
		{
			return m_mgrPlugin.getPluginExtensionPointDataList(plgid);
		}
		
		
		public function getPluginChildrenDataList(plgid:String):Array
		{
			return m_mgrPlugin.getPluginChildrenDataList(plgid);
		}
		
		public function getPluginChildrenDataListByPoint(plgid:String, extpt:String):Array
		{
			return m_mgrPlugin.getPluginChildrenDataListByPoint(plgid, extpt);
		}
		
		
		//=============================================================================
		
		private function loadConfig(cfgIndex:int):Boolean
		{
			if(cfgIndex >= m_cfgPathList.length + m_cfgContentList.length)
			{
				return false;
			}
			
			var cfg:PluginConfig;
			cfg = new PluginConfig();
			
			if(cfgIndex < m_cfgContentList.length)
			{
				var content:String = m_cfgContentList[cfgIndex];
				cfg.addEventListener(ErrorEvent.ERROR, onConfigEvent);
				cfg.addEventListener(Event.COMPLETE, onConfigEvent);
				cfg.loadContent(content);
			}
			else
			{
				var path:String = m_cfgPathList[cfgIndex - m_cfgContentList.length];
				cfg.addEventListener(ErrorEvent.ERROR, onConfigEvent);
				cfg.addEventListener(Event.COMPLETE, onConfigEvent);
				cfg.load(path);
			}
			return true;
		}
		
		
		private function onConfigEvent(e:Event):void
		{
			var cfg:PluginConfig = e.target as PluginConfig;
			
			cfg.removeEventListener(ErrorEvent.ERROR, onConfigEvent);
			cfg.removeEventListener(Event.COMPLETE, onConfigEvent);
			
			if(e.type == Event.COMPLETE)
			{
				var lst:Array = cfg.getPluginDataList();
				for(var i:int = 0; i < lst.length; ++i)
				{
					//向PluginManager里依次添加所有的插件数据。
					//这些插件数据来自一个配置文件，或者多个配件文件。
					m_mgrPlugin.addPluginData(lst[i]);
				}
			}
			else
			{
				throw Error("插件配置加载失败！" + cfg.path);
			}
			
			++m_cfgIndex;
			if(!loadConfig(m_cfgIndex))
			{
				//去加载启动插件
				m_mgrPlugin.loadPlugin(m_startPluginId); 
			}
		}
		

		
	}
}