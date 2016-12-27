package com.tencent.fge.foundation.network
{
	import flash.events.Event;

	public class ProtocolEvent extends Event
	{
		public static const PTL_SINK:String = "ptlSink";
		public static const PTL_TIMEOUT:String = "ptlTimeout";
		public static const PTL_NOT_REG:String = "ptlNotReg";
		public static const PTL_ERROR:String = "ptlError";
		
		public var protocolIndex:uint;
		public var protocolId:uint;
		public var protocolData:*;
		public var protocolLastErrCode:uint;
				
		public function ProtocolEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function toString():String
		{
			return "ProtocolEvent(" + 
					"type:"+this.type+", "+
					"pid:"+protocolId.toString()+"(0x"+protocolId.toString(16)+"), " + 
					"index:"+this.protocolIndex+")";
		}
		
	}
}