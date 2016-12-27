package com.tencent.fge.framework.resmanager.loader
{
	import com.tencent.fge.debug.Debugger;
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.resmanager.ResDebuger;
	import com.tencent.fge.framework.resmanager.ResManager;
	import com.tencent.fge.framework.resmanager.ResReport;
	import com.tencent.fge.framework.resmanager.ResUtil;
	import com.tencent.fge.framework.resmanager.data.ResType;
	import com.tencent.fge.framework.resmanager.interfaces.IAtomLoader;
	import com.tencent.fge.framework.vermanager.VersionData;
	import com.tencent.fge.framework.vermanager.VersionManager;
	import com.tencent.fge.utils.ClassUtil;
	import com.tencent.fge.utils.PathUtil;
	
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import com.tencent.fge.framework.resmanager.QueryResLoaderStack;

	final public class ResLoader extends EventDispatcher
	{
		private var m_ver:String = "0";
		private var m_type:String = "";
		private var m_url:String = "";
		private var m_urlReal:String = "";
		private var m_verManaged:Boolean = false;
		private var m_md5:String = "";
		
		private var m_context:LoaderContext;
		private var m_ldrAtom:IAtomLoader;
		private var m_value:*;
		private var m_bytes:ByteArray;
		private var m_size:uint;
		private var m_timAsy:Timer;
		private var m_tryTimes:int = ResManager.retryTimes;
		private var m_timLoadBegin:int;
		private var m_report:ResReport;
		private var m_timeout:Timer;
		private var m_hasRetry:Boolean = false;
		
		public function ResLoader(type:String)
		{
			super();
			m_type = type;
			m_report = ResReport.getInstance();
		}
		
		public function get value():*{return m_value;}
		public function get bytes():ByteArray{return m_bytes;}
		public function get size():uint{return m_size;}
		public function get type():String{return m_type;}
		public function get ver():String{return m_ver;}
		public function get url():String{return m_url;}
		public function get applicationDomain():ApplicationDomain
		{
			return m_ldrAtom.applicationDomain;
		}

		public function load(url:String, ver:String = "", domain:ApplicationDomain = null):void
		{
			m_url = url;
			
			if(ver == "random")
			{
				m_ver = Math.random().toString();
			}
			else
			{
				m_ver = ver;
			}
			
			m_verManaged = false;
			
			if(ResManager.useVerManager == ResManager.VM_MANAGED)
			{
				var vd:VersionData = VersionManager.getVersionDataEx(url);
				if(vd != null)
				{
					m_urlReal = vd.realurl;
					m_type = vd.restype;
					m_md5 = vd.md5;
					m_verManaged = true;
				}
				else
				{
					//开启了版本管理，但又在版本管理里的资源，都强制不能加载到当前域。
					//而只能加载到隔离域
					domain = null;
				}
			}
			else if(ResManager.useVerManager == ResManager.VM_RANDOM)
			{
				m_ver = Math.random().toString();
			}
			
			if(!m_verManaged)
			{
				m_urlReal = m_url;
			}
			
			if(m_type == "" || m_type == null)
			{
				m_type = ResType.getTypeFromPath(m_urlReal);
			}
			
			
			if(domain != null)
			{
				m_context = new LoaderContext(false, domain);
			}
			else
			{
				m_context = null;
			}
			
			
			m_timLoadBegin = getTimer();
			m_timeout = new Timer(ResManager.timeout, 1);
			m_timeout.addEventListener(TimerEvent.TIMER, onTimeout);
			
			if(m_urlReal != "" && m_urlReal != null)
			{
				if(QueryResLoaderStack._isLock)
				{
					QueryResLoaderStack.getInstance().addResLoader(this);
				}
				tryLoadWorker();
			}
			else
			{
				var timAsyError:Timer = new Timer(100, 1);
				timAsyError.addEventListener(TimerEvent.TIMER, onTimAsyError);
				timAsyError.start();
			}
		}
		
		
		private function tryLoadWorker():void
		{
			var request:URLRequest;
			
			var url:String = m_urlReal;
			
			if(m_verManaged)
			{
				url = m_urlReal + "?ver=managed";
			}
			else
			{
				if(m_ver != "" && m_ver != null)
				{
					url = m_urlReal + "?ver=" + m_ver;
				}
			}
			
			
			if(m_hasRetry)
			{
				var tmp:String = int(Math.random() * 100000).toString();
				url = url + "&retry=" + m_tryTimes + "_" + tmp;
			}
			
			
			//todo
			if(ResManager.usep2p)
			{
				url = "http://127.0.0.1:8080/getres.res?url=" + url;
			}
			
			request = new URLRequest(url);

			switch(m_type)
			{
			case ResType.TEXT:
				m_ldrAtom = new TextLoader();
				m_ldrAtom.addAllEventListener(onLoaderEvent);	
				TextLoader(m_ldrAtom).load(request);
				break;
			case ResType.BYTE:
				m_ldrAtom = new ByteLoader();
				m_ldrAtom.addAllEventListener(onLoaderEvent);	
				ByteLoader(m_ldrAtom).load(request);
				break;
			case ResType.FLASH:
				m_ldrAtom = new FlashLoader(m_md5);
				m_ldrAtom.addAllEventListener(onLoaderEvent);	
				FlashLoader(m_ldrAtom).load(request, m_context);
				break;
			case ResType.IMAGE:
				m_ldrAtom = new ImageLoader();
				m_ldrAtom.addAllEventListener(onLoaderEvent);	
				ImageLoader(m_ldrAtom).load(request);
				break;
			case ResType.SOUND:
				m_ldrAtom = new SoundLoader();
				m_ldrAtom.addAllEventListener(onLoaderEvent);	
				SoundLoader(m_ldrAtom).load(request);
				break;
			case ResType.FONT:
				m_ldrAtom = new FontLoader();
				m_ldrAtom.addAllEventListener(onLoaderEvent);	
				FontLoader(m_ldrAtom).load(request);
				break;
			case ResType.PLUGIN:
				m_ldrAtom = new FlashLoader(m_md5);
				m_ldrAtom.addAllEventListener(onLoaderEvent);	
				FlashLoader(m_ldrAtom).load(request, m_context);
				break;
			case ResType.PACK:
				m_ldrAtom = new PackLoader(m_md5);
				m_ldrAtom.addAllEventListener(onLoaderEvent);	
				PackLoader(m_ldrAtom).load(request, m_context);
				break;
			default:
				m_ldrAtom = new ImageLoader();
				m_ldrAtom.addAllEventListener(onLoaderEvent);	
				ImageLoader(m_ldrAtom).load(request);
			}
			
			if(m_timeout)
			{
				m_timeout.reset();
				m_timeout.start();
			}
			
			--m_tryTimes;
		}
		
		public function unload():void
		{
			if(m_ldrAtom)
			{
				if(QueryResLoaderStack._isLock)
				{
					QueryResLoaderStack.getInstance().unResLoader(this);
				}
				
				m_ldrAtom.removeAllEventListener(onLoaderEvent);
				m_ldrAtom.unload();
			}
			
			if(m_timeout)
			{
				m_timeout.reset();
				m_timeout.removeEventListener(TimerEvent.TIMER, onTimeout);
				m_timeout = null;
			}
		}
		

		private function onLoaderEvent(e:Event):void
		{
			if(e.type == Event.COMPLETE)
			{
				m_ldrAtom.removeAllEventListener(onLoaderEvent);
				
				if(m_timeout)
				{
					m_timeout.reset();
					m_timeout.removeEventListener(TimerEvent.TIMER, onTimeout);
					m_timeout = null;
				}
				
				this.m_value = m_ldrAtom.value;
				this.m_bytes = m_ldrAtom.bytes;
				this.m_size = m_ldrAtom.size;
				this.dispatchEvent(e);
				
				if(m_ldrAtom.usepack)
				{
					m_ldrAtom.cleanMemory();
				}
				
				if (QueryResLoaderStack._isLock) QueryResLoaderStack.getInstance().updateResLoader(this);
			}
			else if(e.type == ProgressEvent.PROGRESS)
			{
				if(m_timeout)
				{
					m_timeout.reset();
					m_timeout.start();
				}
				
				this.dispatchEvent(e);
			}
			else
			{
				m_ldrAtom.removeAllEventListener(onLoaderEvent);
				
				if(m_timeout)
				{
					m_timeout.reset();
				}
				
				if(!handleError(e.target))
				{

					if(e.type == IOErrorEvent.IO_ERROR && 
						this.hasEventListener(IOErrorEvent.IO_ERROR))
					{
						this.dispatchEvent(e);
					}
					
					if(e.type == SecurityErrorEvent.SECURITY_ERROR && 
						this.hasEventListener(SecurityErrorEvent.SECURITY_ERROR))
					{
						this.dispatchEvent(e);
					}
				}
			}
			
		}
		
		

		
		private function onTimeout(e:Event):void
		{
			if(m_timeout)
			{
				m_timeout.reset();
			}
			
			Log.warn("ResLoader.onTimeout", "加载资源["+m_url+"]超时!");
			
			if(!handleError(e.target))
			{
				var evt:IOErrorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR);
				this.dispatchEvent(evt);
			}
		}
		
		private function onTimAsyError(e:Event):void
		{
			var tim:Timer = e.target as Timer;
			if(tim)
			{
				tim.reset();
				tim.removeEventListener(TimerEvent.TIMER, onTimAsyError);
			}
			
			Log.warn("ResLoader.onTimAsyError", "加载资源["+m_url+"]错误!");
			
			var evt:IOErrorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR);
			this.dispatchEvent(evt);
		}
		
		
		private function handleError(target:Object):Boolean
		{
			m_ldrAtom.unload();
			
			var reason:int = 1;
			
			if(target is LoaderInfo)
			{
				reason = 2;
			}
			else if(target is Timer)
			{
				reason = 3;
			}

			
			if(m_tryTimes <= 0)
			{
				
				
				Log.error("ResLoader.handleError", "加载资源["+m_url+"]失败，已经重试完最大次数：" + ResManager.retryTimes, reason);
				
				//上报错误加载信息,也不上报了，以防止雪崩。
				m_report.reportResError(m_url, m_ver, ResManager.retryTimes, getTimer() - m_timLoadBegin, reason); 
				
				return false;
			}
			else
			{
				Log.warn("ResLoader.handleError", "加载资源["+m_url+"]失败，剩下重试次数：" + m_tryTimes, reason);
				
				if(m_timAsy == null)
				{
					m_timAsy = new Timer(ResManager.retryInterval, 1);
				}
				
				m_timAsy.addEventListener(TimerEvent.TIMER, onAsyTimer);
				m_timAsy.reset();
				m_timAsy.start();
				m_hasRetry = true;
				
				return true;
			}
		}
		
		private function onAsyTimer(e:Event):void
		{
			m_timAsy.removeEventListener(TimerEvent.TIMER, onAsyTimer);
			tryLoadWorker();
		}
		
		
		
		public function addAllEventListener(listener:Function):void
		{
			this.addEventListener(Event.COMPLETE, listener);
			this.addEventListener(IOErrorEvent.IO_ERROR, listener);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, listener);
			this.addEventListener(ProgressEvent.PROGRESS, listener);
		}
		
		public function removeAllEventListener(listener:Function):void
		{
			this.removeEventListener(Event.COMPLETE, listener);
			this.removeEventListener(IOErrorEvent.IO_ERROR, listener);
			this.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, listener);
			this.removeEventListener(ProgressEvent.PROGRESS, listener);
		}
		
		

	
	}
}