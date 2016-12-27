package com.tencent.fge.framework.mutexmanager
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.mutexmanager.enum.MutexResult;
	import com.tencent.fge.framework.mutexmanager.enum.MutexState;
	import com.tencent.fge.framework.mutexmanager.events.MutexEvent;
	import com.tencent.fge.framework.mutexmanager.interfaces.IMutex;
	import com.tencent.fge.utils.IDGen;
	
	import flash.utils.Dictionary;
	
	internal class Mutex implements IMutex
	{
		private const HI_SECURED:String = "hiSecured";
		private const LO_SECURED:String = "loSecured";
		
		private var m_mid:String;
		private var m_ref:int;
		private var m_status:String;
		
		private var m_lstOrder:Array;
		private var m_lstOrderWeak:Array;
		
		private var m_bCreated:Boolean;
		
		private static var m_log:Log = new Log(Mutex);
		
		public function Mutex()
		{
			super();
			this.m_ref = 0;
			m_lstOrder = new Array;
			m_lstOrderWeak = new Array;
			
			m_bCreated = false;
		}
		
		public function create(strMid:String):void
		{
			if(m_bCreated == false)
			{
				m_mid = strMid;
				m_bCreated = true;
			}
		}
		
		public function get mid():String { return m_mid; }
		public function get ref():int { return m_ref; }
		public function get status():String { return m_status; }
		
		
		public function acquire(type:String, orderID:String, listener:Function = null, priority:int = 0):String
		{
			var orderIndex:int = getOrderIndex(orderID);
			
			var order:MutexOrder = m_lstOrder[orderIndex];
			
			if(order == null || order.status != MutexOrder.STATUS_FREE)
			{
				return MutexResult.FAILED_ORDER_ERROR;
			}
			
			if(m_status == MutexState.EXCLUSIVE)
			{
				addOrder(orderID, type, priority, listener);
				return MutexResult.FAILED_EXCLUSIVE;
			}
			else if(type == MutexState.EXCLUSIVE && m_ref > 0)
			{
				addOrder(orderID, type, priority, listener);
				return MutexResult.FAILED_EXCLUSIVE;
			}
			else
			{
				++m_ref;
				m_status = type;
				order.status = MutexOrder.STATUS_ACQUIRED;
				
				return MutexResult.SUCCESS;
			}
			
			
		}
		
		public function release(orderID:String):String
		{
			var orderIndex:int = getOrderIndex(orderID);
			
			if(m_lstOrder[orderIndex] == null
				|| (m_lstOrder[orderIndex] as MutexOrder).status != MutexOrder.STATUS_ACQUIRED
			)
			{
				//	the order doesn't exist or the order can't used to release this mutex, return error
				return MutexResult.FAILED_ORDER_ERROR;
			}
			
			--m_ref;
			removeOrder(orderID);
			
			if(m_ref == 0)
			{
				m_status = MutexState.FREE;
				dispatchMutexEvent(HI_SECURED);
			}
			
			return MutexResult.SUCCESS;
		}
		
		
		public function acquireWeak(type:String, listener:Function = null, priority:int = 0):String
		{
			if(m_status == MutexState.EXCLUSIVE)
			{
				addOrder("", type, priority, listener);
				return MutexResult.FAILED_EXCLUSIVE;
			}
			else if(type == MutexState.EXCLUSIVE && m_ref > 0)
			{
				addOrder("", type, priority, listener);
				return MutexResult.FAILED_EXCLUSIVE;
			}
			else
			{
				++m_ref;
				m_status = type;
				
				return MutexResult.SUCCESS;
			}
			
			
		}
		
		public function releaseWeak():String
		{
			--m_ref;
			
			if(m_ref == 0)
			{
				m_status = MutexState.FREE;
				dispatchMutexEvent(LO_SECURED);
			}
			
			return MutexResult.SUCCESS;
		}
		
		/*---------------------------------------------------------
		* 	Func:	_generateOrder
		* 	Desc:	This function may worth notice.
		*			(Auto generated description)
		* 	Param:	
		*	Return:	
		* 	Remark:	this key generating algorithm is temp,
		*			maybe use the GUID algorithm in the future
		*--------------------------------------------------------*/
		internal function _generateOrder():String
		{
			var newOrder:MutexOrder = new MutexOrder;
			
			do
			{
				newOrder.orderID = IDGen.singleton.generate();
			}while(-1 != getOrderIndex(newOrder.orderID));
				
			newOrder.status = MutexOrder.STATUS_FREE;

			m_lstOrder.push(newOrder);
			
			return newOrder.orderID;
		}
		
		
		/*---------------------------------------------------------
		* 	Func:	addOrder
		* 	Desc:	add an order into the order list (weak list or strong list)
		* 	Param:	
		*	Return:	
		* 	Remark:	
		*--------------------------------------------------------*/
		protected function addOrder(orderID:String, acqType:String, priority:int = 0, listener:Function = null):void
		{
			if(listener == null)
			{
				//	no listener is provided, hence there is no need to
				//	store this order
				return;
			}
			
			var order:MutexOrder;
			
			if(orderID != "")
			{
				//	this is a strong security order
				order = m_lstOrder[getOrderIndex(orderID)];
				order.priority = priority;
				order.type = acqType;
				order.listener = listener;
			}
			else
			{
				//	this is a weak security order
				order = m_lstOrderWeak[getWeakOrderIndex(listener)];
				if(order == null)
				{
					order = new MutexOrder;
					m_lstOrderWeak.push(order);
				}
				order.priority = priority;
				order.type = acqType;
				order.listener = listener;
			}
		}
		
		protected function removeOrder(orderID:String):void
		{
			var orderIndex:int = getOrderIndex(orderID);
			
			if(m_lstOrder[orderIndex] == null)
			{
				m_log.exthrow("removeOrder", "can't remove order with orderID="
					+ orderID);
			}
			
			m_lstOrder.splice(orderIndex, 1);
		}
		
		/*---------------------------------------------------------
		* 	Func:	dispatchMutexEvent
		* 	Desc:	collect MutexAcquirers which need to dispatch the MutexEvent.AVAILABLE
		*			these collected MutexAcquirers must meet only one of the following two conditions:
		*				1.	only one MutexAcquirer, and its acqType is EXCLUSIVE
		*				2.	several MutexAcquirers, and their acqType are SHARED
		*					(because the last collected MutexAcquirer's next one is EXCLUSIVE)
		* 	Param:	
		*	Return:	
		* 	Remark:	
		*--------------------------------------------------------*/
		protected function dispatchMutexEvent(secureMode:String):void
		{
			var lstOrder:Array;
			
			if(secureMode == HI_SECURED)
			{
				lstOrder = m_lstOrder;
			}
			else if(secureMode == LO_SECURED)
			{
				lstOrder = m_lstOrderWeak;
			}
			
			//	sort by priority, from lower to higher
			lstOrder.sort(MutexOrder.sortOnPriority);
			
			var collectedMutexAcquirers:Array = new Array;
			
			var i:int;
			var one:MutexOrder;
			var lastIndex:int = lstOrder.length - 1;
			for(i = lastIndex; i >= 0; --i)
			{
				one = lstOrder[i] as MutexOrder;
				
				if(i == lastIndex && one.type == MutexState.EXCLUSIVE)
				{
					//		1.	only one MutexAcquirer, and its acqType is EXCLUSIVE
					collectedMutexAcquirers = lstOrder.splice(lastIndex, 1);
					break;
				}
				

				if(one.type == MutexState.SHARED)
				{
					//		2.	several MutexAcquirers, and their acqType are SHARED
					//			(because the last collected MutexAcquirer's next one is EXCLUSIVE)
					collectedMutexAcquirers.concat(lstOrder.splice(i, 1));
				}
				else if(one.type == MutexState.EXCLUSIVE)
				{
					break;
				}
			}
			
			//	dispatch event to colletected MutexAcquirers
			var e:MutexEvent = new MutexEvent(MutexEvent.AVAILABLE);
			e.mid = this.mid;
			for(i = 0; i < collectedMutexAcquirers.length; ++i)
			{
				one = collectedMutexAcquirers[i] as MutexOrder;
				one.listener(e);
			}
			
		}
		
		
		/*---------------------------------------------------------
		* 	Func:	getOrderIndex
		* 	Desc:	get an order from the strong security order list
		*			according to the orderID
		* 	Param:	
		*	Return:	
		* 	Remark:	
		*--------------------------------------------------------*/
		private function getOrderIndex(orderID:String):int
		{
			var i:int;
			var one:MutexOrder;
			for(i = 0; i < m_lstOrder.length; ++i)
			{
				one = m_lstOrder[i] as MutexOrder;
				if(one.orderID == orderID)
				{
					return i;
				}
			}
			
			return -1;
		}
		
		/*---------------------------------------------------------
		* 	Func:	getWeakOrderIndex
		* 	Desc:	get an order from weak security order list
		*			according to the listener
		* 	Param:	
		*	Return:	
		* 	Remark:	
		*--------------------------------------------------------*/
		private function getWeakOrderIndex(listener:Function):int
		{
			var i:int;
			var one:MutexOrder;
			for(i = 0; i < m_lstOrderWeak.length; ++i)
			{
				one = m_lstOrderWeak[i] as MutexOrder;
				if(one.listener == listener)
				{
					return i;
				}
			}
			
			return -1;
		}
	}
}

