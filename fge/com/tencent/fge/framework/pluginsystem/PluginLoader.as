package com.tencent.fge.framework.pluginsystem
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.pluginsystem.data.PluginData;
	import com.tencent.fge.framework.pluginsystem.data.PluginRes;
	import com.tencent.fge.framework.pluginsystem.events.PluginEvent;
	import com.tencent.fge.framework.pluginsystem.interfaces.IPlugin;
	import com.tencent.fge.framework.pluginsystem.interfaces.IPluginStub;
	import com.tencent.fge.framework.resmanager.ResGroup;
	import com.tencent.fge.framework.resmanager.ResManager;
	import com.tencent.fge.framework.resmanager.data.ResType;
	import com.tencent.fge.framework.resmanager.events.ResEvent;
	import com.tencent.fge.framework.resmanager.events.ResGroupEvent;
	import com.tencent.fge.framework.resmanager.loader.ResLoader;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	
	[Event(name="error", type="flash.events.ErrorEvent")]
	[Event(name="loadProgress", type="com.tencent.fge.framework.pluginsystem.events.PluginEvent")]
	[Event(name="complete", type="flash.events.Event")]
	public class PluginLoader extends EventDispatcher
	{
		private static var ms_mapDomain:Dictionary = new Dictionary;
		private static var ms_asyLoadNext:Boolean = false;
		
		private var m_stub:IPluginStub;
		private var m_data:PluginData;
		
		
		private var m_mgrRes:ResManager;
		private var m_ldrRuntime:ResLoader = new ResLoader("");
		private var m_lstResPath:Array = new Array;

		
		private var m_isResLoaded:Boolean = false;
		private var m_isResLoading:Boolean = false;
		
		private var m_isRtLoaded:Boolean = false;
		private var m_isRtLoading:Boolean = false;
		
		private var m_numResTotal:int;
		private var m_numResLoaded:int;
		private var m_numResError:int;
		private var m_idxResNext:int;
		

		private var m_timAsyComplete:Timer;
		private var m_timAsyLoadNext:Timer;
		
		private var m_report:PluginReport; 
		private var m_timResLoadBegin:int;
		private var m_timRtLoadBegin:int;
		
		
		
		public function PluginLoader(stub:IPluginStub)
		{
			m_stub = stub;
			m_report = PluginReport.getInstance();
		}
		
		public function getPlugin(runtime:String):IPlugin
		{
			return m_ldrRuntime.value;
		}
		
		
		
		public function load(data:PluginData):void
		{
			m_data = data;
			m_mgrRes = ResManager.getResManager("plugin");
			
			if(m_isResLoaded && m_isRtLoaded)
			{
				if(m_timAsyComplete == null)
				{
					m_timAsyComplete = new Timer(100,1);
				}
				
				//这个表示，要么是重复加载，抛出Complete事件
				//要么是资源和Rt都为NULL，也抛出Complete事件
				m_timAsyComplete.addEventListener(TimerEvent.TIMER, onTimerAsyComplete);
				m_timAsyComplete.start();
			}
			else
			{
				if(ms_asyLoadNext && m_timAsyLoadNext == null)
				{
					m_timAsyLoadNext = new Timer(100, 1);
					m_timAsyLoadNext.addEventListener(TimerEvent.TIMER, onTimerAsyLoadNext);
				}
				
				
				
				if(!tryLoadRes())
				{
					tryLoadRuntime();
				}
			}
		}
		
		private function tryLoadRes():Boolean
		{
			//已经加载完成，不需要再尝试
			if(m_isResLoaded == true)
			{
				return false;
			}
			
			//正在加载中，也即：正在尝试中
			if(m_isResLoading == true)
			{
				return true;
			}
			
			//判断是否需要尝试
			
			if(m_data.res != null)
			{
				//加载符合条件的资源
				var lstOriRes:Array = m_data.res;
				for(var i:int = 0; i < lstOriRes.length; ++i)
				{
					var res:PluginRes = lstOriRes[i];
					
					if(res.lazy == true)
					{
						continue;
					}
					
					if(res.condition)
					{
						if(m_stub.getCondition(res.condition))
						{
							m_lstResPath.push(res);
						}
					}
					else
					{
						m_lstResPath.push(res);
					}
				}
				//m_lstResPath = m_data.res.concat();
			}
			
			m_numResTotal = m_lstResPath.length;
			m_numResLoaded = 0;
			m_idxResNext = 0;
			
			if(m_numResTotal > 0)
			{
				//需要尝试
				m_isResLoading = true;
				//则开始正式加载
				loadResNext();
			}
			else
			{
				//不需要尝试
				m_isResLoading = false;
				m_isResLoaded = true;
			}
			
			//返回是否需要尝试
			return m_isResLoading;
		}
		
		
		private function loadResNext():void
		{
			//取出一个资源
			if(m_numResLoaded >= m_lstResPath.length)
			{
				//所有资源已经加载完成，则开始加载RT
				m_isResLoaded = true;
				m_isResLoading = false;
				tryLoadRuntime();
			}
			else
			{
				//加载插件附属的资源
				var res:PluginRes;
				var domain:ApplicationDomain;
				
				//默认通道（通道1）
				if(m_idxResNext < m_lstResPath.length)
				{
					res = m_lstResPath[m_idxResNext++];
					domain = getDomainByName(res.domain);
					m_mgrRes.loadResWithDomain(res.path, res.type, res.ver, domain, m_data.id, onLoadResEvent);
					
					//其它通道
					
					//通道2
					if( PluginSystem.PluginResLoadPipeNum >= 2 && 
						m_idxResNext == 2 && m_idxResNext < m_lstResPath.length)
					{
						res = m_lstResPath[m_idxResNext++];
						domain = getDomainByName(res.domain);
						m_mgrRes.loadResWithDomain(res.path, res.type, res.ver, domain, m_data.id, onLoadResEvent);
						
						
						//通道3
						if( PluginSystem.PluginResLoadPipeNum >= 3 && 
							m_idxResNext == 3 && m_idxResNext < m_lstResPath.length)
						{
							res = m_lstResPath[m_idxResNext++];
							domain = getDomainByName(res.domain);
							m_mgrRes.loadResWithDomain(res.path, res.type, res.ver, domain, m_data.id, onLoadResEvent);
							
							
							//通道4
							if( PluginSystem.PluginResLoadPipeNum >= 4 && 
								m_idxResNext == 4 && m_idxResNext < m_lstResPath.length)
							{
								res = m_lstResPath[m_idxResNext++];
								domain = getDomainByName(res.domain);
								m_mgrRes.loadResWithDomain(res.path, res.type, res.ver, domain, m_data.id, onLoadResEvent);
							}
							
						}
					}

				}

				
				//记录资源加载启动时间
				m_timResLoadBegin = getTimer();
			}
			
		}

		
		
		private function onLoadResEvent(e:ResEvent):void
		{
			var evt:PluginEvent;
			
			if(e.type == ResEvent.LOAD_SUCCESS)
			{
				//如果成功就不上报，以降低服务器压力。
				//m_report.record(m_data.id, e.path, getTimer() - m_timResLoadBegin, true);
				
				m_mgrRes.removeResAllEventListener(e.path, onLoadResEvent);
				++m_numResLoaded;
				
				if(ms_asyLoadNext)
				{
					m_timAsyLoadNext.reset();
					m_timAsyLoadNext.start();
				}
				else
				{
					loadResNext();
				}
			}
			else if(e.type == ResEvent.LOAD_FAILED)
			{
				m_report.record(m_data.id, e.path, getTimer() - m_timResLoadBegin, false);
				m_mgrRes.removeResAllEventListener(e.path, onLoadResEvent);
				++m_numResError;
				++m_numResLoaded;
				
				//中断插件的加载
				handleError(e.path);
			}
			else if(e.type == ResEvent.LOAD_PROGRESS)
			{
				handleProgress(e.path, e.bytesLoaded, e.bytesTotal);
			}
		}

		private function onTimerAsyLoadNext(e:Event):void
		{
			loadResNext();
		}
		
		
		private function tryLoadRuntime():Boolean
		{
			//已经完成加载，则不需要尝试加载
			if(m_isRtLoaded == true)
			{
				return false;
			}
			
			//正在加载中，也即：正在尝试中
			if(m_isRtLoading == true)
			{
				return true;
			}
			
			
			m_ldrRuntime.addAllEventListener(onLoadRtEvent);
			m_ldrRuntime.load(m_data.runtime, m_data.ver, ApplicationDomain.currentDomain);
			
			m_isRtLoading = true;
			m_timRtLoadBegin = getTimer();
			
			return true;
		}
		

		
		private function onLoadRtEvent(e:Event):void
		{
			if(e.type == Event.COMPLETE)
			{
				m_isRtLoaded = true;
				m_isRtLoading = false;
				
				//如果成功就不上报，以降低服务器压力
				//m_report.record(m_data.id, "runtime", getTimer() - m_timRtLoadBegin, true);
				
				handleComplete();
			}
			else if(e.type == ProgressEvent.PROGRESS)
			{
				var bytesLoaded:Number = ProgressEvent(e).bytesLoaded;
				var bytesTotal:Number = ProgressEvent(e).bytesTotal;
				handleProgress(m_data.runtime, bytesLoaded, bytesTotal);
			}
			else
			{
				m_report.record(m_data.id, "runtime", getTimer() - m_timRtLoadBegin, false);
				
				handleError("runtime");
			}
		}
		
		
		
		private function handleProgress(curResPath:String, 
										curResBytesLoaded:Number, curResBytesTotal:Number):void
		{
			var evt:PluginEvent = new PluginEvent(PluginEvent.LOAD_PROGRESS);
			evt.plgId = m_data.id;
			evt.plgResTotal = this.m_numResTotal + 1;
			evt.plgResLoaded = m_isRtLoaded ? (this.m_numResLoaded + 1) : this.m_numResLoaded;
			evt.plgResError = m_numResError;
			evt.curResPath = curResPath;
			evt.curResBytesLoaded = curResBytesLoaded;
			evt.curResBytesTotal = curResBytesTotal;
			
			this.dispatchEvent(evt);
		}
		
		private function handleError(curResPath:String):void
		{
			var evt:PluginEvent = new PluginEvent(PluginEvent.LOAD_ERROR);
			evt.plgId = m_data.id;
			evt.curResPath = curResPath;
			this.dispatchEvent(evt);
		}

		
		private function handleComplete():void
		{
			var evt:PluginEvent = new PluginEvent(PluginEvent.LOAD_COMPLETE);
			evt.plgId = m_data.id;
			this.dispatchEvent(evt);	
		}
		
		
		private function onTimerAsyComplete(e:Event):void
		{
			//如果成功就不上报，以降压服务器压力
			//m_report.record(m_data.id, "reload", 0, true);
			
			m_timAsyComplete.removeEventListener(TimerEvent.TIMER, onTimerAsyComplete);
			this.dispatchEvent(new PluginEvent(PluginEvent.LOAD_COMPLETE));
		}
		
		
		internal static function getDomainByName(name:String):ApplicationDomain
		{
			if(name == "current")
			{
				return ApplicationDomain.currentDomain;
			}
			else if(name != null && name != "")
			{
				var domain:ApplicationDomain = ms_mapDomain[name];
				if(domain == null)
				{
					domain = new ApplicationDomain;
					ms_mapDomain[name] = domain;
				}
				
				return domain;
			}
			
			return null;
		}
	}
}