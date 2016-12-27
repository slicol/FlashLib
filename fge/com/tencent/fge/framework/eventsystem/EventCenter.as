package com.tencent.fge.framework.eventsystem
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.eventsystem.interfaces.IEventCenter;
	import com.tencent.fge.utils.ClassUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	/**
	 * ...
	 * @author DonaldWu
	 */
	
	/*=============================================================================
	*	Class:	EventCenter
	*	Desc:	EventCenter is a singleton.
	*============================================================================*/
	public class EventCenter implements IEventCenter
	{
		 //{ region singleton
		 private static var ms_instance:EventCenter = null;
		 private static var ms_bSigletonCreated:Boolean = false;
		 private static var ms_iCountInstances:int = 0;
		 
		 public function EventCenter() 
		 {   
			  ++ms_iCountInstances;   
			  if(!ms_bSigletonCreated || ms_iCountInstances != 1)
			  {
				   --ms_iCountInstances;
				   throw new Error( "Access EventCenter by EventCenter.singleton!" );
			  }
		 }
		  
		 public static function get singleton():EventCenter
		 {
			  if(EventCenter.ms_instance == null)
			  {
				   EventCenter.ms_bSigletonCreated = true;
				   EventCenter.ms_instance = new EventCenter;
				   
				   EventCenter.ms_instance.initialize();
			  }
			   
			  return ms_instance;
		 }
		 
		 public static function addEventListener(type:String, listener:Function, priority:int=0, obj:* = null, listenerName:String = ""):void
		 {
			 singleton.addEventListener(type, listener, priority, obj, listenerName);
		 }
		 
		 public static function removeEventListener(type:String, listener:Function, obj:* = null, listenerName:String = ""):void
		 {
			 singleton.removeEventListener(type, listener, obj, listenerName);
		 }
			 
		 public static function dispatchEvent(event:Event, obj:* = null, dispatcherFuncName:String = ""):Boolean
		 {
			 return singleton.dispatchEvent(event, obj, dispatcherFuncName);
		 }
		 //} endregion
		 
	
		 
	
		 private var m_eventDispatcher:EventDispatcher;
		 private var log:Log;
		 
		 private var m_lstListener:Dictionary;
		 
		 public function initialize():void 
		 {
			 m_eventDispatcher = new EventDispatcher;
			 log = new Log(this);
			 
			 m_lstListener = new Dictionary(false);
			 // add additional initialization here
		 }
	
		 
	
		 public function finalize():void
		 {
			 m_lstListener = null;
			  // finalize the singleton
		 }
		 
		 public function addEventListener(type:String, listener:Function, priority:int=0, obj:* = null, listenerName:String = ""):void
		 {
			 const useCapture:Boolean = false;
			 const useWeakReference:Boolean = false;
			 
			 m_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
			 
			 
			 
			 //	store it for log
			 if(m_lstListener[type] == null)
			 {
				 m_lstListener[type] = new Array;
			 }
			 
			 
			 var listeners:Array = m_lstListener[type] as Array;
			 var foundIndex:int = getListenerIndex(type, listener);
			 if(foundIndex == -1)
			 {
				 var evtLstn:EventListener = new EventListener;
				 evtLstn.m_type = type;
				 evtLstn.m_priority = priority;
				 evtLstn.m_listener = listener;
				 evtLstn.m_objName = ClassUtil.getName(obj);
				 evtLstn.m_listenerName = listenerName;
				 evtLstn.m_useCapture = useCapture;
				 evtLstn.m_useWeakReference = useWeakReference;
				 
				 _addListenerAndSort(listeners, evtLstn);
				 
				 showLog_addEventListener(type, obj, listenerName, priority);
			 }
		 }
		 
		 public function removeEventListener(type:String, listener:Function, obj:* = null, listenerName:String = ""):void
		 {
			 m_eventDispatcher.removeEventListener(type, listener, false);
			 
			 
			 //	store it for log
			 var foundIndex:int = getListenerIndex(type, listener);
			 if(foundIndex != -1)
			 {
				 showLog_removeEventListener(type, obj, listenerName);
				 (m_lstListener[type] as Array).splice(foundIndex, 1);
			 }
		 }
		 
		 public function dispatchEvent(event:Event, obj:* = null, dispatcherFuncName:String = ""):Boolean
		 {
			 showLog_dispatchEvent(event, obj, dispatcherFuncName);
			 if(null != event)
			 {
				 return m_eventDispatcher.dispatchEvent(event);
			 }
			 else
			 {
				 return false;
			 }
		 }
		 

		 
		 private function showLog_addEventListener(type:String, obj:* = null, listenerName:String = "", priority:int = 0):void
		 {
			 log.trace("EventCenter.addEventListener", "priority=" + priority +
				 ", type=" + type + ", obj=" + ClassUtil.getName(obj) + ", listener=" + listenerName);
		 }
		 
		 private function showLog_removeEventListener(type:String, obj:* = null, listenerName:String = ""):void
		 {
			 log.trace("removeEventListener", "type=" + type + ", obj=" + ClassUtil.getName(obj) + ", listener=" + listenerName);
		 }
		 
		 private function showLog_dispatchEvent(event:Event, obj:* = null, dispatchFuncName:String = ""):void
		 {
			 var strLog:String;
			 
			 if(null != event)
			 {
				 var arr:Array = m_lstListener[event.type];
				 
				 strLog = "event=" + event.type
					 + ", dispatcher=" + ClassUtil.getName(obj) + ", dispatch func=" + dispatchFuncName + "()"
					 + ", receive listeners=...";
				 
				 if(Log.getTraceEnable())
				 {
					 const tab:String = "\t";
					 
					 if(arr == null || arr.length == 0)
					 {
						 strLog += "N/A";
					 }
					 else
					 {
						 strLog += "\n";
						 var i:int;
						 var one:EventListener;
						 for(i = 0; i < arr.length; ++i)
						 {
							 one = arr[i] as EventListener;
							 strLog += tab + i.toString() + ": ";
							 strLog += "priority=" + one.m_priority + ",\t";
							 strLog += "obj.listener()=" + one.m_objName + "::" + one.m_listenerName + "()";
							 
							 if(i != arr.length - 1)
							 {
								 strLog += "\n";
							 }
						 }
					 }
				 }
			 }
			 else
			 {
				 strLog = "event=null";
			 }
			 
			 log.trace("dispatchEvent", strLog);
		 }
		 
		 private function getListenerIndex(type:String, listener:Function):int
		 {
			 var arr:Array = m_lstListener[type];
			 if(arr == null)
			 {
				 return -1;
			 }
			 
			 var i:int;
			 var one:EventListener;
			 for(i = 0; i < arr.length; ++i)
			 {
				 one = arr[i] as EventListener;
				 if(one.m_type == type
					 && one.m_listener == listener)
				 {
					 return i;
				 }
			 }
			 
			 return -1;
		 }
		 
		 /*---------------------------------------------------------
		 * 	Func:	_addListenerAndSort
		 * 	Desc:	insert the new listener into the array at the proper index
		 *			after inserted, the priority is from higher to lower
		 * 	Param:	
		 *	Return:	
		 * 	Remark:	
		 *--------------------------------------------------------*/
		 private function _addListenerAndSort(listeners:Array, listener:EventListener):void
		 {
			 var insertIndex:int;
			 var one:EventListener;
			 for(insertIndex = 0; insertIndex < listeners.length; ++insertIndex)
			 {
			 	one = listeners[insertIndex] as EventListener;
				if(one.m_priority < listener.m_priority)
				{
					break;
				}
			 }
			 
			 listeners.splice(insertIndex, 0, listener);
		 }
	}
}