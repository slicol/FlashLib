package com.tencent.fge.framework.mutexmanager
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.mutexmanager.interfaces.IMutexManager;
	
	import flash.utils.Dictionary;

	/**
	 * ...
	 * @author DonaldWu
	 */
	
	/*=============================================================================
	*	Class:	MutexManager
	*	Desc:	MutexManager is a singleton.
	*			MutexManager has two kind of mutexs:
	*				mutex with security and mutex without security
	*
	*			these two kinds mutex are seperated from each other
	*			for the high security mutexs, call acquire() & release() 
	*			for the weak security mutexs, call acquireWeak() & releaseWeak() 
	*============================================================================*/
	public class MutexManager implements IMutexManager
	{
		 //{ region singleton
		 private static var ms_instance:MutexManager = null;
		 private static var ms_bSigletonCreated:Boolean = false;
		 private static var ms_iCountInstances:int = 0;
		 
		 public function MutexManager() 
		 {   
			  ++ms_iCountInstances;   
			  if(!ms_bSigletonCreated || ms_iCountInstances != 1)
			  {
				  --ms_iCountInstances;
				  throw new Error( "Access MutexManager by MutexManager.singleton!" );
			  }
		 }
		  
		 public static function get singleton():IMutexManager
		 {
			  if(MutexManager.ms_instance == null)
			  {
				  MutexManager.ms_bSigletonCreated = true;
				  MutexManager.ms_instance = new MutexManager;
				  
				  MutexManager.ms_instance.init();
			  }
			   
			  return ms_instance;
		 }
		 //} endregion
		 
		 
		 
		 
		 
		 
		
		 
		 private var m_lstMutex:Dictionary;
		 private var m_lstMutexWeak:Dictionary;
		 
		 private var m_log:Log;
		 
		 public function init():void 
		 {
			 m_lstMutex = new Dictionary(true);
			 m_log = new Log(this);
			 // add additional initialization here
		 }
	
		 
	
		 public function finalize():void
		 {
			 m_lstMutex = null;
			  // finalize the singleton
		 }
		 
		 /*---------------------------------------------------------
		 * 	Func:	generateOrder
		 * 	Desc:	generate an order for acquirer before it acquires a mutex
		 * 	Param:	
		 *	Return:	the orderID of this new order
		 * 	Remark:	
		 *--------------------------------------------------------*/
		 public function generateOrder(mid:String):String
		 {
			 var mutex:Mutex;
			 
			 if(m_lstMutex[mid] == null)
			 {
				 m_lstMutex[mid] = new Mutex;
				 (m_lstMutex[mid] as Mutex).create(mid);
			 }
			
			 mutex = m_lstMutex[mid];
			 
			 return mutex._generateOrder();
		 }
		 
		 /*---------------------------------------------------------
		 * 	Func:	acquire
		 * 	Desc:	acquire the mutex with high security
		 * 	Param:	orderID: call MutexManager::generateKey() to get a key and pass it here
		 *	Return:	
		 * 	Remark:	
		 *--------------------------------------------------------*/
		 public function acquire(mid:String, type:String, orderID:String, listener:Function = null, priority:int = 0):String
		 {
			 var mutex:Mutex = m_lstMutex[mid];
			 
			 var result:String = mutex.acquire(type, orderID, listener, priority);
			 
			 m_log.trace("acquire", "result=" + result +
				 ", mid=" + mid + ", type=" + type + ", key=" + orderID + ", listener=" + listener);
			 
			 return result;
		 }
		 
		 
		 /*---------------------------------------------------------
		 * 	Func:	release
		 * 	Desc:	release a mutex with high security
		 * 	Param:	orderID: use a key which has been successfully acuqired the mutex with the same mid
		 *	Return:	
		 * 	Remark:	
		 *--------------------------------------------------------*/
		 public function release(mid:String, orderID:String):String
		 {
		 	var mutex:Mutex = m_lstMutex[mid];
			
			var result:String = mutex.release(orderID);
			
			
			m_log.trace("release", "result=" + result +
				", mid=" + mid + ", key=" + orderID);
			
			return result;
		 }
		 
		 /*---------------------------------------------------------
		 * 	Func:	acquireWeek
		 * 	Desc:	acquire a mutex without security
		 * 	Param:	
		 *	Return:	
		 * 	Remark:	
		 *--------------------------------------------------------*/
		 public function acquireWeak(mid:String, type:String, listener:Function = null, priority:int = 0):String
		 {
			 var mutex:Mutex;
			 
			 if(m_lstMutex[mid] == null)
			 {
				 m_lstMutex[mid] = new Mutex;
				 (m_lstMutex[mid] as Mutex).create(mid);
			 }
			 
			 mutex = m_lstMutex[mid];
			 
			 var result:String = mutex.acquireWeak(type, listener, priority);
			 
			 m_log.trace("acquireWeak", "result=" + result +
				 ", mid=" + mid + ", type=" + type + ", listener=" + listener);
			 
			 return result;
		 }
		 
		 public function releaseWeak(mid:String):String
		 {
			 var mutex:Mutex = m_lstMutex[mid];
			 
			 var result:String = mutex.releaseWeak();
			 
			 m_log.trace("releaseWeak", "result=" + result +
				 ", mid=" + mid);
			 
			 return result;
		 }
	}
}