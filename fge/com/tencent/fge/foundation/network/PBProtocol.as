package com.tencent.fge.foundation.network
{
	import com.tencent.protobuf.Message;
	
	import flash.utils.ByteArray;

	public class PBProtocol extends BaseProtocol
	{
		protected var m_rsp:Message;
		protected var m_req:Message;
		
		private var m_rsp_type:Class;
		private var m_req_type:Class;
		
		public function PBProtocol(pid:uint=0, timeout:uint=60, errorTimeout:uint=1, listener:Function=null, dec:int=DEC_DEFAULT)
		{
			super(pid, timeout, errorTimeout, listener, dec);
		}
		
		protected function bindProtoBuffClass(req:Class, rsp:Class):void
		{
			m_rsp_type = rsp;
			m_req_type = req;
			
			if(m_req_type != null)
			{
				m_req = new m_req_type;
			}
		}
		
		//client->server
		override public function encode(o:Object):ByteArray
		{
			var bytes:ByteArray = new ByteArray;
			if(m_req)
			{
				m_req.writeTo(bytes);
			}
			return bytes;
		}
		
		//server->client
		override public function decode(bytes:ByteArray):Object
		{
			if(m_rsp_type != null)
			{
				m_rsp = new m_rsp_type;
				m_rsp.readFromSlice(bytes, 0);
			}
			else
			{
				throw new ArgumentError("PBProtocol: 用于解码的ProtoBuf类为NULL！");
			}
			return this;
		}
	}
}