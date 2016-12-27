package com.tencent.fge.foundation.network.demo
{
	import com.tencent.fge.foundation.network.BaseProtocol;
	import com.tencent.fge.foundation.network.IProtocolSender;
	
	import flash.utils.ByteArray;

	public class PTL_X extends BaseProtocol
	{
		//协议ID
		public static const ID:uint = 1;
		
		public function PTL_X(listener:Function = null)
		{
			super(ID, 60, 1, listener);
		}

		//------------------------------------------------------------
		//这里面的代码部分，是框架要求必需实现的.
		//且所有的具体协议类，这部分代码都是相同的。
		//它们是在协议注册时被协议管理器调用。
		private static var ms_sender:IProtocolSender
		override protected function bindProtocolSender(sender:IProtocolSender):void
		{
			ms_sender = sender;
		}
		
		override protected function getSender():IProtocolSender
		{
			return ms_sender;
		}
		
		//------------------------------------------------------------
		
		//以下都是具体协议的具体结构的定义
		public var cs_param1:uint = 0; //请求包的结构
		public var cs_param2:uint = 0; //请求包的结构
		public var cs_param3:uint = 0; //请求包的结构
		
		public var sc_param1:uint = 0;//应答包的结构
		public var sc_param2:uint = 0;//应答包的结构
		public var sc_param3:uint = 0;//应答包的结构
		
		
		//------------------------------------------------------------
		
		//从一个字节Buffer里，解出每一个字段
		override public function decode(bytes:ByteArray):Object
		{
			this.sc_param1 = bytes.readUnsignedInt();
			this.sc_param2 = bytes.readUnsignedInt();
			this.sc_param3 = bytes.readUnsignedInt();
			return this;
		}
		
		
		//将一个协议类（数据对象）编码成一个Buffer。
		//这个Object就是PTL_X类型的,也就是this
		override public function encode(o:Object):ByteArray
		{
			if(o != this) throw Error("Encode Error!");
			var bytes:ByteArray = new ByteArray;
			bytes.writeUnsignedInt(this.cs_param1);
			bytes.writeUnsignedInt(this.cs_param2);
			bytes.writeUnsignedInt(this.cs_param3);
			return bytes;
		}
		
		//------------------------------------------------------------
		//以上：	
		//是不是很整洁？
		//以上代码具有规律性，可以用专用的工具自动生成上面代码.
		//------------------------------------------------------------
	}
}