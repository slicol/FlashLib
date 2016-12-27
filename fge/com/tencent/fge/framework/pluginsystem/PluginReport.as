package com.tencent.fge.framework.pluginsystem
{
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class PluginReport extends EventDispatcher
	{	
		public static var enable:Boolean = false;
		
		private static var ms_instance:PluginReport;
		private var m_content:String = "";
		private var m_cgiReport:String = "";
		private var m_uin:uint;
		private var m_index:int;
		
		public function PluginReport()
		{
		}

		public static function getInstance():PluginReport
		{
			if(ms_instance == null)
			{
				ms_instance = new PluginReport;
			}
			
			return ms_instance;
		}
		
		
		public static function initialize(uin:uint, cgi:String):void
		{
			getInstance().m_uin = uin;
			getInstance().m_cgiReport = cgi;
		}
	
		
		public function record(plgId:String, filePath:String, elapse:int, success:Boolean):void
		{
			++m_index;
			m_content += ""+m_index+" | "+plgId+" | "+filePath+" | "+success+" | "+elapse+"\n";
		}
		
		
		public static function report(totalTimecost:int):void
		{
			getInstance().report(totalTimecost);
		}
		
		public function report(totalTimecost:int):void
		{
			if(!enable)
			{
				return;
			}
			
			if(m_cgiReport != null && m_cgiReport.length != 0)
			{
				m_content = m_content + "\n TotalTimeCost = " + totalTimecost + "\n";
				
				Log.trace("PluginReport.report", "\n" + m_content);
				
				var param:URLVariables = new URLVariables();
				param.qq = m_uin;
				param.file = m_content;
				param.reason = "ReportPlugin";
				
				var request:URLRequest = new URLRequest(m_cgiReport);
				request.data = param;
				request.method = URLRequestMethod.POST;
				
				
				var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.TEXT;
				loader.addEventListener(Event.COMPLETE, onReportComplete);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onReportError);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onReportError);
				
				try
				{  
					Log.trace("PluginReport.report", "正在上传插件加载报告......" );
					loader.load(request);  
				}
				catch(error:Error)
				{  
					Log.error("PluginReport.report", "上传插件加载报告失败！" + error.toString());
				}  
				
			}
			else
			{
				Log.debug("PluginReport.report", "\n" + m_content);
			}
			
		}
		
		private function onReportComplete(e:Event):void
		{
			Log.trace("PluginReport.report", "上传插件加载报告成功！" );
		}
		
		private function onReportError(e:Event):void
		{
			Log.error("PluginReport.report", "上传插件加载报告失败！" + e.toString());
		}
		
	}
}