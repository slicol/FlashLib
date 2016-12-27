package com.tencent.fge.framework.resmanager
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.resmanager.events.ResEvent;
	import com.tencent.fge.framework.resmanager.events.ResGroupEvent;
	import com.tencent.fge.framework.resmanager.interfaces.IResManager;
	import com.tencent.fge.utils.FlashVerUtil;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.net.LocalConnection;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	[Event(name = "loadSuccess", type="com.tencent.fge.framework.resmanager.events.ResEvent")]
	[Event(name = "loadFailed", type="com.tencent.fge.framework.resmanager.events.ResEvent")]
	[Event(name = "unload", type="com.tencent.fge.framework.resmanager.events.ResEvent")]
	[Event(name = "loadGroupComplete", type="com.tencent.fge.framework.resmanager.events.ResGroupEvent")]
	[Event(name = "loadGroupProgress", type="com.tencent.fge.framework.resmanager.events.ResGroupEvent")]
	public class ResManager extends EventDispatcher implements IResManager
	{
		public static const VM_DEFAULT:int = 0;
		public static const VM_MANAGED:int = 1;
		public static const VM_RANDOM:int = 2;
		
		public static var crossDomain:Boolean = true;
		public static var useVerManager:int = VM_DEFAULT;
		public static var retryTimes:int = 3;
		public static var retryInterval:int = 2000;
		public static var timeout:int = 20000;
		public static var libx:* = null;
		public static var netspeed:int = 0;
		public static var usep2p:Boolean = false;
		//public static var flashVer:Number = 0;
		
		private static var ms_lstManager:Dictionary = new Dictionary;
		private var m_name:String = "";
		private var m_domain:ApplicationDomain;
		private var m_debuger:ResDebuger;
		
		public function ResManager(name:String, domain:ApplicationDomain = null)
		{
			super();
			m_name = name;
			m_domain = domain;
			m_debuger = new ResDebuger(name, domain);
		}
		
		public static function initialize():Boolean
		{
			//flashVer = FlashVerUtil.flashVer;
			return true;
		}
		

				
		public static function createResManager(
			name:String, domain:ApplicationDomain = null, 
			type:String="default"):Boolean
		{
			var rm:ResManager = ms_lstManager[name];
			if(rm == null)
			{
				rm = new ResManager(name, domain);
				ms_lstManager[name] = rm;
				return true;
			}
			return true;
		}
		
		public static function getResManager(name:String):ResManager
		{
			var rm:ResManager = ms_lstManager[name];
			if(rm == null)
			{
				rm = new ResManager(name, null);
				ms_lstManager[name] = rm;
			}
			return rm;
		}
		
		public static function dump(name:String):String
		{
			var mgr:ResManager = ms_lstManager[name];
			if(mgr)
			{
				return mgr.dump();
			}
			else
			{
				return ResDebuger.dump(ms_lstManager);
			}
		}
		
		//-----------------------------------------------------------
		//-----------------------------------------------------------
		
		//资源分组池
		private var m_mapResGroup:Dictionary = new Dictionary;
		
		//资源池
		private var m_mapResHelper:Dictionary = new Dictionary;
		
		public function get name():String{return m_name;}
		public function get domain():ApplicationDomain{return m_domain;}
		
		//-----------------------------------------------------------
		
		
		public function initialize():Boolean
		{
			return true;
		}
		
		public function finalize():void
		{
			
		}
		
		//-----------------------------------------------------------
		//-----------------------------------------------------------
		
		public function dump():String
		{
			return m_debuger.dump(m_mapResGroup, m_mapResHelper);
		}
		
		//-----------------------------------------------------------
		
		public function loadRes(path:String, type:String, ver:String, group:String = null):ResHelper
		{			
			return loadResWithDomain(path, type, ver, null, group);
		}
		
		public function loadResWithDomain(path:String, type:String, ver:String, 
										domain:ApplicationDomain, group:String = null, 
										allEventListener:Function = null):ResHelper
		{
			//得到一个分组，如果未指定分组，则使用资源路径作为分组
			//每一个资源必定存在于一个分组中
			if(group == null || group == "") 
			{
				group = path;
			}
			
			
			//看是否能找到分组
			var grp:ResGroup = m_mapResGroup[group];
			if(grp == null)
			{
				//拿不到便创建一个分组
				grp = new ResGroup(group,this);
				m_mapResGroup[group] = grp;
			}
			
			//看是否能找到资源，因为说不定这个资源已经被加载过了
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp == null)
			{
				//如果没有找到，则创建一个资源
				hlp = new ResHelper(path, type);
				m_mapResHelper[path] = hlp;
				//资源加载只有成功和失败事件
				hlp.addEventListener(ResEvent.LOAD_SUCCESS, onResEvent);
				hlp.addEventListener(ResEvent.LOAD_FAILED, onResEvent);
			}
			
			//如果已经有资源，或者已经创建资源，则将资源加入分组。
			grp.addRes(hlp);
			
			if(allEventListener != null)
			{
				hlp.addAllEventListener(allEventListener);
			}
			
			//不管创建已经有，或者是新创建的，都统一其加载行为
			if(domain != null)
			{
				hlp.loadRes(ver, domain);
			}
			else
			{
				hlp.loadRes(ver, m_domain);
			}
			
			return hlp;
		}
		
		
		//卸载一个资源，忽略引用计数
		public function unloadRes(path:String):void
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null)
			{
				//Unload一个资源
				hlp.unloadRes();
				if(hlp.isNull())
				{
					delete m_mapResHelper[path];
				}
			}
		}
		

		//Unload所有的资源,忽略引用计数
		public function unloadAll():void
		{
			var lstRes:Array;
			var grp:ResGroup;
			var hlp:ResHelper;

			for each(grp in m_mapResGroup)
			{
				if(grp != null)
				{
					grp.removeAll();
				}
			}
			m_mapResGroup = new Dictionary;
			

			for each(hlp in m_mapResHelper)
			{
				if(hlp != null)
				{
					hlp.unloadRes(true);
				}
			}
			
			m_mapResHelper = new Dictionary;
		}
		


		//---------------------------------------------------------------
		//---------------------------------------------------------------
		
		public function releaseRes(path:String):void
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null)
			{
				hlp.unloadRes();
				if(hlp.isNull())
				{
					delete m_mapResHelper[path];
				}
			}
		}
		
		public function getRes(path:String):ResFile
		{		
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null && hlp.file != null)
			{
				hlp.addRef();
				return hlp.file;
			}	
			return null;
		}
		
		private function getResWorker(path:String):ResFile
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null)
			{
				return hlp.file;
			}	
			return null;
		}
		
		public function hasRes(path:String, type:Class = null, def:String = ""):Boolean
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null && hlp.file != null)
			{
				if(type == null)
				{
					return true;
				}
				else if(type == ApplicationDomain)
				{
					return hlp.file.domain != null;
				}
				else if(type == Class)
				{
					if(hlp.file.domain != null)
					{
						return hlp.file.domain.hasDefinition(def);
					}
				}
			}	
			return false;
		}
		//---------------------------------------------------------------
		
		public function getResDomain(path:String):ApplicationDomain
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null && hlp.file != null && hlp.file.domain != null)
			{
				hlp.addRef();
				return hlp.file.domain;
			}
			return null;
		}
		
		public function getResContent(path:String):*
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null && hlp.file != null && hlp.file.content != null)
			{
				hlp.addRef();
				return hlp.file.content;
			}
			return null;
		}
		
		public function getResBitmapData(path:String):BitmapData
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null && hlp.file != null && hlp.file.content is BitmapData)
			{
				hlp.addRef();
				return hlp.file.content;
			}
			return null;
		}
		
		public function getResMovieClip(path:String):MovieClip
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null && hlp.file != null && hlp.file.content is MovieClip)
			{
				hlp.addRef();
				return hlp.file.content;
			}
			return null;
		}
		
		public function getResDisplayObject(path:String):DisplayObject
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null && hlp.file != null && hlp.file.content is DisplayObject)
			{
				hlp.addRef();
				return hlp.file.content;
			}
			return null;
		}
		
		public function getResText(path:String):String
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null && hlp.file != null && hlp.file.content is String)
			{
				hlp.addRef();
				return hlp.file.content;
			}
			return null;
		}
		
		public function getResByteArray(path:String):ByteArray
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null && hlp.file != null && hlp.file.content is ByteArray)
			{
				hlp.addRef();
				return hlp.file.content;
			}
			return null;
		}
		
		public function getResClass(path:String, def:String):Class
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null && hlp.file != null && hlp.file.domain != null)
			{
				var clazz:Class = hlp.file.domain.getDefinition(def) as Class;
				if(clazz != null)
				{
					hlp.addRef();
					return clazz;
				}
			}
			
			return null;
		}
		
		public function getResSound(path:String):Sound
		{
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null && hlp.file != null && hlp.file.content is Sound)
			{
				hlp.addRef();
				return hlp.file.content;
			}
			return null;
		}
		
		
		
		
		//-----------------------------------------------------------
		//-----------------------------------------------------------
		
		public function addGroupEventListener(group:String, type:String, listener:Function):void
		{
			if(group == null || group == "") 
			{
				return;
			}
			
			var grp:ResGroup = m_mapResGroup[group];
			if(grp == null)
			{
				grp = new ResGroup(group, this);
				m_mapResGroup[group] = grp;
			}
			
			grp.addEventListener(type, listener);
		}
		
		public function removeGroupEventListener(group:String, type:String, listener:Function):void
		{
			if(group == null || group == "") 
			{
				return;
			}
			
			var grp:ResGroup = m_mapResGroup[group];
			if(grp == null)
			{
				return;
			}
			
			grp.removeEventListener(type, listener);
		}
		
		
		public function addResEventListener(path:String, type:String, listener:Function):void
		{
			if(path == null || path == "")
			{
				return;
			}
			
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null)
			{
				hlp.addEventListener(type, listener);
			}
		}
		
		public function addResAllEventListener(path:String, listener:Function):void
		{
			if(path == null || path == "")
			{
				return;
			}
			
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null)
			{
				hlp.addAllEventListener(listener);
			}
		}
		
		public function removeResEventListener(path:String, type:String, listener:Function):void
		{
			if(path == null || path == "")
			{
				return;
			}
			
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null)
			{
				hlp.removeEventListener(type, listener);
			}
		}
		
		public function removeResAllEventListener(path:String, listener:Function):void
		{
			if(path == null || path == "")
			{
				return;
			}
			
			var hlp:ResHelper = m_mapResHelper[path];
			if(hlp != null)
			{
				hlp.removeAllEventListener(listener);
			}
		}
		
		
		private function onResEvent(e:ResEvent):void
		{
			this.dispatchEvent(e);
		}
		
		
	}
}