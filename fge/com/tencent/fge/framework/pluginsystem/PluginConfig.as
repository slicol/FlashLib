package com.tencent.fge.framework.pluginsystem
{
	import com.tencent.fge.framework.pluginsystem.data.ExtensionPointData;
	import com.tencent.fge.framework.pluginsystem.data.PluginData;
	import com.tencent.fge.framework.pluginsystem.data.PluginRes;
	import com.tencent.fge.utils.PathUtil;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	[Event(name="error", type="flash.events.ErrorEvent")]
	[Event(name="complete", type="flash.events.Event")]
	
	public class PluginConfig extends EventDispatcher
	{
		internal static var PATH_CFG:String = "plugin.xml";
		internal static var BaseUrl_Runtime:String = "";
		internal static var BaseUrl_Res:String = "";
		
		private var m_ldrCfg:URLLoader;
		private var m_tblPluginData:Array = new Array;
		private var m_path:String = "";
		private var m_timAsyComplete:Timer = new Timer(10,1);
		private var m_timAsyError:Timer = new Timer(10,1);
		
		public function PluginConfig(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function getPluginDataList():Array{return m_tblPluginData;};
		public function get path():String{return m_path;}
		
		public function load(cfgPath:String):void
		{
			m_path = PATH_CFG;
			if(cfgPath != null && cfgPath.length > 0)
			{
				m_path = cfgPath;
			}
			m_ldrCfg = new URLLoader();
			m_ldrCfg.load(new URLRequest(m_path));
			m_ldrCfg.addEventListener(Event.COMPLETE, onLoaderEvent);
			m_ldrCfg.addEventListener(IOErrorEvent.IO_ERROR, onLoaderEvent);
			m_ldrCfg.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderEvent);
		}
		
		public function loadContent(content:String):void
		{
			var tmp:XML;
			try
			{
				tmp = new XML(content);
			}
			catch(e:Error)
			{
				m_timAsyError.addEventListener(TimerEvent.TIMER, onAsyErrorTimer);
				m_timAsyError.start();
				return;
			}
			
			xml2Cfg(tmp, m_tblPluginData);
			
			m_timAsyComplete.addEventListener(TimerEvent.TIMER, onAsyCompleteTimer);
			m_timAsyComplete.start();
		}
		
		private function onAsyCompleteTimer(e:Event):void
		{
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onAsyErrorTimer(e:Event):void
		{
			this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}
		
		private function onLoaderEvent(e:Event):void
		{
			var ldr:URLLoader = e.target as URLLoader;
			if(ldr != null)
			{	
				ldr.removeEventListener(Event.COMPLETE, onLoaderEvent);
				ldr.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderEvent);
				ldr.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderEvent);
			}
			
			if(e.type == Event.COMPLETE)
			{
				var tmp:XML;
				try
				{
					tmp = new XML(e.currentTarget.data);
				}
				catch(e:Error)
				{
					this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
					return;
				}
				
				if(ldr == m_ldrCfg)
				{
					m_ldrCfg = null;
					xml2Cfg(tmp, m_tblPluginData);
				}
				
				if(m_ldrCfg == null)
				{
					this.dispatchEvent(new Event(Event.COMPLETE));
					return;
				}
			}
			else
			{
				this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
			}
		}
		
		
		private function xml2Cfg(xml:XML, tblCfgData:Array):void
		{
			var xmlPluginList:XMLList = xml["Plugin"];
			var i:int = 0;

			for(i = 0; i < xmlPluginList.length(); ++i)
			{
				var xmlPlugin:XML = xmlPluginList[i];
				var data:PluginData = new PluginData;
				
				data.id = xmlPlugin.@id;
				data.name = xmlPlugin.@name;
				data.ver = xmlPlugin.@ver;
				data.extension = xmlPlugin.Extension.@point;
				data.runtime = xmlPlugin.Runtime.@path;
				
				//加上BaseUrl
				data.runtime = PathUtil.makeFullPath(BaseUrl_Runtime, data.runtime, true);


				var j:int = 0;
				
				var xmlExtPtList:XMLList = xmlPlugin.elements("ExtensionPoint");
				for(j = 0; j < xmlExtPtList.length(); ++j)
				{
					var xmlExtPt:XML = xmlExtPtList[j];
					var dataExtPt:ExtensionPointData = new ExtensionPointData;
					dataExtPt.id = xmlExtPt.@id;
					dataExtPt.name = xmlExtPt.@name;
					dataExtPt.lazy = (xmlExtPt.@lazy == "true");
					data.extPoints.push(dataExtPt);
				}
				
				
				var xmlResList:XMLList = xmlPlugin.Resource.children()
				for(j = 0; j < xmlResList.length(); ++j)
				{
					var xmlRes:XML = xmlResList[j];
					var res:PluginRes = new PluginRes;
					res.id = xmlRes.@id;
					res.path = xmlRes.@path;
					res.ver = xmlRes.@ver;
					res.domain = xmlRes.@domain;
					res.condition = xmlRes.@condition;
					res.lazy = (xmlRes.@lazy == "true");
					data.res.push(res);
					
					//加上BaseUrl
					res.path = PathUtil.makeFullPath(BaseUrl_Res, res.path, true);
				}
				
				var xmlParamList:XMLList = xmlPlugin.Params.children()
				for(j = 0; j < xmlParamList.length(); ++j)
				{
					var xmlParam:XML = xmlParamList[j];
					data.params[xmlParam.@id] = xmlParam.toString();
				}
				
				tblCfgData.push(data);
			}
		}			
	}
}