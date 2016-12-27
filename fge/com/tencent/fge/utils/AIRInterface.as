package com.tencent.fge.utils
{
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	public class AIRInterface
	{
		private var m_lc_back:LocalConnection;
		private var m_lc_call:LocalConnection;
		
		private var m_name:String = "";
		private var m_mapCallBack:Dictionary = new Dictionary;
		
		private var log:Log;
		
		public function AIRInterface(name:String)
		{
			log = new Log("AIRInterface["+name+"]");
			
			var thisname:String = getQualifiedClassName(this);
			thisname = thisname.replace("::", ".");
			thisname = thisname.replace(".", "_");
			
			if(name.substr(0,1) == "_")
			{
				m_name = "_" + thisname + "["+name+"]";
			}
			else
			{
				m_name = thisname + "["+name+"]";
			}
		}
		
		
		public function addCallBack(functionName:String, closure:Function, thisObject:*):void
		{
			if(m_name)
			{
				if(!m_lc_back)
				{
					m_lc_back = new LocalConnection();
					m_lc_back.allowDomain("*");
					m_lc_back.client = this;
					m_lc_back.addEventListener(StatusEvent.STATUS, onBackStatusEvent);
					m_lc_back.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onBackErrorEvent);
					m_lc_back.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onBackErrorEvent);
					
					try 
					{
						m_lc_back.connect(m_name);
					}
					catch (error:ArgumentError) 
					{
						m_lc_back = null;
						log.error("addCallBack", 
							"The connection name is already being used by another SWF!");
					}
				}
				
				var lst:Array = m_mapCallBack[functionName];
				if(lst == null)
				{
					lst = new Array;
					m_mapCallBack[functionName] = lst;
				}
				
				for(var i:int = 0; i < lst.length; ++i)
				{
					var o:Object = lst[i];
					if(o.thisObject == thisObject && o.closure == closure)
					{
						break;
					}
				}
				
				if(i >= lst.length)
				{
					lst.push({thisObject:thisObject, closure:closure});
				}
			}
		}
		
		private function onBackErrorEvent(e:Event):void
		{
			log.error("onBackErrorEvent", e);
		}
		
		private function onBackStatusEvent(e:Event):void
		{
			log.trace("onBackErrorEvent", e);
		}
		
		public function onCallBack(functionName:String, argArray:Array):void
		{
			log.trace("onCallBack", functionName, argArray);
			
			var lst:Array = m_mapCallBack[functionName];
			if(lst)
			{
				for(var i:int = 0; i < lst.length; ++i)
				{
					var o:Object = lst[i];
					if(o != null)
					{
						var closure:Function = o.closure;
						var thisObject:* = o.thisObject;
					 	if(thisObject != null && closure != null)
						{
							try
							{
								closure.apply(thisObject, argArray);
							}
							catch(e:Error)
							{
								log.error("onCallBack", e);
							}
						}
					}
				}
			}
		}
		
		
		
		public function call(functionName:String, ...parameters):void
		{
			if(m_name)
			{
				if(!m_lc_call)
				{
					m_lc_call = new LocalConnection();
					m_lc_call.addEventListener(StatusEvent.STATUS, onCallStatusEvent);
					m_lc_call.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onCallErrorEvent);
					m_lc_call.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onCallErrorEvent);
				}
				
				m_lc_call.send(m_name, "onCallBack", functionName, parameters);
			}
		}
			
		
		
		private function onCallErrorEvent(e:Event):void
		{
			log.error("onCallErrorEvent", e);
		}
		
		private function onCallStatusEvent(e:Event):void
		{
			log.trace("onCallStatusEvent", e);
		}
		

		

	}
}