/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   SerializeOperateQueueEvent.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2009-6
#   Comment     :   定义串行操作事件
#  	Modify      :   2009-6 文件创建 
#
*************************************************************************/

package com.tencent.fge.foundation.serialize
{
	import flash.events.Event;

	public class SerializeOperateQueueEvent extends Event
	{
		static public const EXECUTE:String = "execute";
		
		public var opTarget:Object;
		public var opParam:Object;
		
		public function SerializeOperateQueueEvent(type:String = EXECUTE, 
			bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}