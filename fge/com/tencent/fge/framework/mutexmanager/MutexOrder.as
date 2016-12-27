package com.tencent.fge.framework.mutexmanager
{
	/**
	 * ...
	 * @author DonaldWu
	 */
	
	 
	
	/*=============================================================================
	*	Class:	MutexOrder
	*	Desc:	a MutexOrder has a key, which is used to identify diffenrent MutexOrders
	*============================================================================*/
	internal class MutexOrder
	{
		public static const STATUS_FREE:String = "STATUS_FREE";
		public static const STATUS_ACQUIRED:String = "STATUS_ACQUIRED";
		
		public var orderID:String;	//	identify different MutexAcquirers
		public var status:String = STATUS_FREE;
		
		public var listener:Function;
		public var priority:int;
		public var type:String;
		
		public function hasListener(item:*, index:int, array:Array):Boolean
		{
			var order:MutexOrder = item as MutexOrder;
			if(order.listener == this.listener)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public static function sortOnPriority(a:MutexOrder, b:MutexOrder):Number 
		{
			if(a.priority > b.priority) return 1;
			else if(a.priority < b.priority) return -1;
			else return 0;
		}
	}
}