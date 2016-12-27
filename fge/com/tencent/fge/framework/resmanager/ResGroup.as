package com.tencent.fge.framework.resmanager
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.resmanager.events.ResEvent;
	import com.tencent.fge.framework.resmanager.events.ResGroupEvent;
	import com.tencent.fge.framework.resmanager.loader.ResLoader;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	

	[Event(name = "loadGroupComplete", type="com.tencent.fge.framework.resmanager.events.ResGroupEvent")]
	[Event(name = "loadGroupProgress", type="com.tencent.fge.framework.resmanager.events.ResGroupEvent")]
	
	internal class ResGroup extends EventDispatcher
	{
		private var m_name:String = "";
		
		private var m_lstResFileTotal:Array = new Array;
		
		private var m_lstResFileWork:Array = new Array;
		private var m_lstResFileOkay:Array = new Array;
		private var m_lstResFileFail:Array = new Array;
		
		private var m_target:IEventDispatcher;

		internal function get name():String{return m_name;}
		
		public function ResGroup(name:String,target:IEventDispatcher=null)
		{
			super(target);
			m_target = target;
			m_name = name;
		}


		internal function addRes(hlp:ResHelper):void
		{
			if(m_lstResFileTotal.indexOf(hlp.path) >= 0)
			{
				return;
			}
			
			hlp.addAllEventListener(onResEvent);
			m_lstResFileTotal.push(hlp.path);
			m_lstResFileWork.push(hlp.path);
		}
		
		internal function removeAll():void
		{

		}
		
		private function onResEvent(e:ResEvent):void
		{	
			if(e.type == ResEvent.LOAD_PROGRESS)
			{
				return;
			}
			
			var hlp:ResHelper = e.target as ResHelper;
			if(hlp)
			{
				hlp.removeAllEventListener(onResEvent);
			}
			
			var path:String = e.path;
			var evt:ResGroupEvent;
			var i:int = m_lstResFileWork.indexOf(path);
			if(i >= 0)
			{
				m_lstResFileWork.splice(i,1);
			}
	
			
			if(e.type == ResEvent.LOAD_SUCCESS)
			{
				m_lstResFileOkay.push(path);
				checkGroupProgress(path, true);
			}
			else
			{
				m_lstResFileFail.push(path);
				checkGroupProgress(path, false);
			}
			
			
		}
		
		private function checkGroupProgress(path:String, curSuccess:Boolean):void
		{
			var evt:ResGroupEvent;
			
			evt = new ResGroupEvent(ResGroupEvent.LOAD_GROUP_PROGRESS,true);
			evt.group = m_name;
			evt.total = m_lstResFileTotal.length;
			evt.count = m_lstResFileFail.length + m_lstResFileOkay.length;
			evt.errorCount = m_lstResFileFail.length;
			evt.curPath = path;
			evt.curSuccess = curSuccess;
			//让外部可以一次性监听所有分组的事件
			m_target.dispatchEvent(evt);
			
			//让外部可以监听指定分组的事件
			this.dispatchEvent(evt.clone());
			
			
			if(m_lstResFileWork.length == 0)
			{
				evt = new ResGroupEvent(ResGroupEvent.LOAD_GROUP_COMPLETE,true);
				evt.group = m_name;
				evt.total = m_lstResFileTotal.length;
				evt.count = m_lstResFileFail.length + m_lstResFileOkay.length;
				evt.errorCount = m_lstResFileFail.length;
				evt.listPath = m_lstResFileTotal.concat([]);
				evt.curPath = path;
				evt.curSuccess = curSuccess;
				m_target.dispatchEvent(evt);
				
				this.dispatchEvent(evt.clone());
			}
		}
		
	}
}

