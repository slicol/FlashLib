package com.tencent.fge.framework.resmanager.events
{
	import flash.events.Event;

	public class ResGroupEvent extends Event
	{
		public static const LOAD_GROUP_COMPLETE:String = "loadGroupComplete";
		public static const LOAD_GROUP_PROGRESS:String = "loadGroupProgress";
		
		public var group:String = "";
		public var listPath:Array = null;
		public var curPath:String;
		public var curSuccess:Boolean = true;

		public var errorCount:int = 0;
		public var count:int = 0;
		public var total:int = 0;
		
		public function ResGroupEvent(type:String, 
			bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			var newE:ResGroupEvent = new ResGroupEvent(this.type, this.bubbles, this.cancelable);
			newE.group = this.group;
			newE.listPath = this.listPath;
			newE.curPath = this.curPath;
			newE.curSuccess = this.curSuccess;

			newE.errorCount = this.errorCount;
			newE.count = this.count;
			newE.total = this.total;
			
			return newE;
		}
	}
}