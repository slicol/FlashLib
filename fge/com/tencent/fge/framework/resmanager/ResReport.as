package com.tencent.fge.framework.resmanager
{
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class ResReport
	{
		public static var enable:Boolean = false;
		
		private static var ms_node:int = 20;
		private static var ms_offset:int = 1000000;
		private static var ms_type:int = 2;
		
		
		private static var ms_instance:ResReport;
		private var m_content:String = "";
		private var m_cgiReport:String = "";
		private var m_uin:uint;
		private var m_index:int;
		
		
		public function ResReport()
		{
		}
		
		public static function getInstance():ResReport
		{
			if(ms_instance == null)
			{
				ms_instance = new ResReport;
			}
			
			return ms_instance;
		}
		
		
		public static function initialize(uin:uint, cgi:String):void
		{
			getInstance().m_uin = uin;
			getInstance().m_cgiReport = cgi;
		}
		
		public static function setStatsParam(node:int, full_id_offset:int, type:int):void
		{
			ms_node = node;
			ms_offset = node * full_id_offset;
			ms_type = type;
		}
		
		
		public function reportResError(filePath:String, ver:String, retry:int, elapse:int, reason:int):void
		{
			if(!enable)
			{
				return;
			}
			
			++m_index;
			
			if(m_cgiReport != null && m_cgiReport.length != 0)
			{				
				var url:String = m_cgiReport + "?";
				url += ("node=" + ms_node + "&");
				url += ("full_id=" + (ms_offset + reason).toString() + "&");
				url += ("type=" + ms_type + "&");
				url += ("value=" + elapse + "&");
				url += ("uin=" + m_uin + "&");
				url += ("info=" + filePath);
				
				var loader:URLLoader = new URLLoader();
				loader.addEventListener(Event.COMPLETE, onReportComplete);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onReportError);
				loader.addEventListener(IOErrorEvent.IO_ERROR, onReportError);
				
				try
				{  
					Log.trace("ResReport.reportResError", "正在上报资源加载统计......" );
					loader.load(new URLRequest(url));
				}
				catch(error:Error)
				{  
					Log.error("ResReport.reportResError", "上报资源加载统计失败！" + error.toString());
				}
				

				/*
				
				m_content = "RptRes | "+m_uin+" | "+m_index+" | "+filePath+" | "+ver+" | "+retry+" | "+elapse+" | "+reason+"\n";
				
				var param:URLVariables = new URLVariables();
				param.qq = m_uin;
				param.file = m_content;
				param.reason = "ReportRes";
				
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
					Log.trace("ResReport.reportResError", "正在上传资源加载报告......" );
					loader.load(request);  
				}
				catch(error:Error)
				{  
					Log.error("ResReport.reportResError", "上传资源加载报告失败！" + error.toString());
				}  
				*/
			}
			
		}
		
		private function onReportComplete(e:Event):void
		{
			Log.trace("ResReport.reportResError", "上传资源加载报告成功！" );
		}
		
		private function onReportError(e:Event):void
		{
			Log.error("ResReport.reportResError", "上传资源加载报告失败！" + e.toString());
		}
	}
}