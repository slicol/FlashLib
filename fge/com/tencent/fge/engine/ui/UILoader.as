package com.tencent.fge.engine.ui
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.resmanager.ResFile;
	import com.tencent.fge.framework.resmanager.ResManager;
	import com.tencent.fge.framework.resmanager.data.ResType;
	import com.tencent.fge.framework.resmanager.events.ResEvent;
	import com.tencent.fge.utils.SWFUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;

	/**
	 * ...
	 * @author DonaldWu
	 */
	
	 
	
	/*=============================================================================
	*	Class:	IconLoader
	*	Desc:	IconLoader is responsible for loading icons.
	*
	*			if the desired icon hasn't been loaded, IconLoader displays a default
	*			waiting icon.
	*			after the desired icon is loaded, IconLoader shows it automatically.
	*============================================================================*/
	[Event(name="complete", type="flash.events.Event")]
	public class UILoader extends Sprite
	{
		protected var m_resMgr:ResManager;
		
		protected var m_contentDisired:DisplayObject;
		//protected var m_iconWaiting:DisplayObject;
		protected var m_content:DisplayObject;
		
		protected var m_byteArrayLoader:Loader;
		
		protected var m_strURL:String;
		protected var m_strVer:String;
		protected var m_strResType:String;
		protected var m_strResGroup:String;
		
		private var m_width:Number;
		private var m_height:Number;
		
		private var m_bLoad:Boolean;
		private var m_bCompleted:Boolean;
		
		private static var log:Log = new Log(UILoader);
		
		private var m_bmpDefaultIcon:Bitmap;
		private var m_bmpDefaultData:BitmapData;
		
		public function UILoader(w:int = 0, h:int = 0, defaultData:BitmapData = null)
		{
			m_width = w;
			m_height = h;
			
			m_strResType = ResType.FLASH;
			m_strResGroup = null;
			
			m_resMgr = ResManager.getResManager("UILoader");
			
			m_bmpDefaultData = defaultData;
			
			/*
			if(s_claDefaultIcon != null)
			{
				var obj:Object = new s_claDefaultIcon;
				var dispObj:DisplayObject = obj as DisplayObject;
				if(dispObj != null)
				{
					m_iconWaiting = dispObj;
				}
			}
			*/
			
			m_bLoad = false;
			m_bCompleted = false;
		}
		
		/*---------------------------------------------------------
		*	Getter: completed
		*--------------------------------------------------------*/
		public function get completed():Boolean { return m_bCompleted; }
		
		/*---------------------------------------------------------
		* Setter and Getter: iconDesired
		*--------------------------------------------------------*/
		public function get iconDesired():DisplayObject { return m_contentDisired; }
		
		/*---------------------------------------------------------
		* Setter and Getter: iconWaiting
		*--------------------------------------------------------*/
		//public function get iconWaiting():DisplayObject { return m_iconWaiting; }
		
		
		
		
		 
		/*---------------------------------------------------------
		* Getter: content
		*--------------------------------------------------------*/
		public function set content(value:DisplayObject):void
		{
			m_content = value;
			SWFUtil.clearChildren(this);
			
			if(value != null)
			{
				addChild(m_content);
				
				if(m_width > 0 && m_height > 0)
				{
					m_content.width = m_width;
					m_content.height = m_height;
					m_content.cacheAsBitmap = true;
				}
				else
				{
					m_width = m_content.width;
					m_height = m_content.height;
				}
			}
			else
			{
				log.warn("content", "null content when url=" + m_strURL + "!");
			}
		}
		public function get content():DisplayObject { return m_content; }
		
		/*---------------------------------------------------------
		* Setter and Getter: url
		*--------------------------------------------------------*/
		public function get url():String { return m_strURL; }
		
		/*---------------------------------------------------------
		* Setter and Getter: resType
		*--------------------------------------------------------*/
		public function set resType(value:String):void { m_strResType = value; }
		public function get resType():String { return m_strResType; }
		
		/*---------------------------------------------------------
		* Setter and Getter: resGroup
		*--------------------------------------------------------*/
		public function set resGroup(value:String):void { m_strResGroup = value; }
		public function get resGroup():String { return m_strResGroup; }
		
		
		
		
		
		
		override public function set width(value:Number):void
		{
			m_width = value;
			resize(m_width, m_height);
		}
		
		override public function set height(value:Number):void
		{
			m_height = value;
			resize(m_width, m_height);
		}
		
		public override function get width():Number
		{
			return m_width;
		}
		
		public override function get height():Number
		{
			return m_height;
		}
		
		public function resize(w:Number, h:Number):void
		{
			m_width = w;
			m_height = h;
			
			if(m_content != null && m_width > 0 && m_height > 0)
			{
				m_content.width = m_width;
				m_content.height = m_height;
			}
		}
		
		 
		
		public function load(strUrl:String, ver:String = null):void
		{
			if(m_strURL == strUrl && m_strVer == ver)
			{
				return;
			}
						
			unload();
			
			m_strURL = strUrl;
			m_strVer = ver;
			
			m_resMgr.addEventListener(ResEvent.LOAD_SUCCESS, onResEvent);
			m_resMgr.addEventListener(ResEvent.LOAD_FAILED, onResEvent);
			m_resMgr.loadRes(m_strURL, null, (m_strVer == null ? "0" : m_strVer), m_strResGroup);
			m_bLoad = true;
			
			m_bCompleted = false;
			
			log.trace("load", "url = " + m_strURL + ", w=" + m_width + ", h=" + m_height);
		}
		
		 
		public function unload():void
		{
			if(m_strURL != null && m_strURL.length > 0)
			{
				log.trace("unload", "url = " + m_strURL);
				this.content = null;
				
				m_resMgr.removeEventListener(ResEvent.LOAD_SUCCESS, onResEvent);
				m_resMgr.removeEventListener(ResEvent.LOAD_FAILED, onResEvent);
				if(true == m_bCompleted)
				{
					m_resMgr.releaseRes(m_strURL);
				}
				if(true == m_bLoad)
				{
					m_resMgr.unloadRes(m_strURL);
				}
				
				if(null != m_byteArrayLoader)
				{
					m_byteArrayLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderCompelte);
					m_byteArrayLoader.unload();
				}
				
				m_strURL = "";
				m_bCompleted = false;
				m_bLoad = false;
			}
		}
		
		
		protected function onResEvent(e:ResEvent):void
		{
			switch(e.type)
			{
			case ResEvent.LOAD_SUCCESS:
				var res:ResFile;
				if(e.path == m_strURL)
				{
					e.currentTarget.removeEventListener(ResEvent.LOAD_SUCCESS, onResEvent);
					e.currentTarget.removeEventListener(ResEvent.LOAD_FAILED, onResEvent);
					
					res = m_resMgr.getRes(m_strURL);
					
					log.trace("onIconLoaded", "path=" + m_strURL);
					loadComplete(res);
				}
				break;
			
			default:
				if(e.path == m_strURL)
				{
					e.currentTarget.removeEventListener(ResEvent.LOAD_SUCCESS, onResEvent);
					e.currentTarget.removeEventListener(ResEvent.LOAD_FAILED, onResEvent);
				}
				
				m_resMgr.unloadRes(m_strURL);
				log.error("onIconFailed", "url = " + m_strURL);
				break;
			}
		}
		
		private function loadComplete(res:ResFile):void
		{
			m_bCompleted = true;
			
			if(null != res)
			{
				if(res.content is Bitmap)
				{
					var bmp:Bitmap = res.content as Bitmap;
					m_contentDisired = new Bitmap(bmp.bitmapData);
					(m_contentDisired as Bitmap).smoothing = true;
					content = m_contentDisired;
				}
				else if(res.content is BitmapData)
				{
					var bmpData:BitmapData = res.content as BitmapData;
					m_contentDisired = new Bitmap(bmpData);
					(m_contentDisired as Bitmap).smoothing = true;
					content = m_contentDisired;
				}
				else if(res.content is DisplayObject)
				{
					m_contentDisired = res.content as DisplayObject;
					content = m_contentDisired;
				}
				else if(res.content is ByteArray)
				{
					if(null != m_byteArrayLoader)
					{
						m_byteArrayLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderCompelte);
						m_byteArrayLoader.unload();
					}
					
					var bytes:ByteArray = res.content as ByteArray;
					m_byteArrayLoader = new Loader;
					m_byteArrayLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderCompelte);
					m_byteArrayLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderError);
					m_byteArrayLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
					try
					{
						m_byteArrayLoader.loadBytes(bytes);
					}
					catch(e:Error)
					{
						handleError();
					}
				}
				else
				{
					log.error("loadComplete", "url=" + m_strURL + ", has unknown file type:" + res.content);
				}
				
				
			}
			else
			{
				log.error("loadComplete", "url=" + m_strURL + ", res is null!!!");
			}
			
			this.dispatchEvent(new Event(Event.COMPLETE));		
		}
		
		private function onLoaderCompelte(e:Event):void
		{
			var bmp:Bitmap = m_byteArrayLoader as Bitmap;
			if(null != bmp)
			{
				bmp.smoothing = true;
			}
			
			m_contentDisired = m_byteArrayLoader as DisplayObject;
			content = m_contentDisired;
		}
		
		private function onLoaderError(e:Event):void
		{
			handleError();
		}
		
		private function handleError():void
		{
			if(m_bmpDefaultData != null)
			{
				if(m_bmpDefaultIcon == null)
				{
					m_bmpDefaultIcon = new Bitmap(m_bmpDefaultData);
					content = m_bmpDefaultIcon;
				}
			}
		}
	}
}