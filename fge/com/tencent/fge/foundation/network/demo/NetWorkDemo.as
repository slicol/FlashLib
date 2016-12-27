package com.tencent.fge.foundation.network.demo
{
	import com.tencent.fge.foundation.network.ConnectManager;
	import com.tencent.fge.foundation.network.IConnector;
	import com.tencent.fge.foundation.network.NetWork;
	import com.tencent.fge.foundation.network.ProtocolEvent;
	import com.tencent.fge.foundation.network.ProtocolManager;
	
	import flash.events.Event;
	
	public class NetWorkDemo
	{
		public function NetWorkDemo()
		{
		}
		
		public function initialize():void
		{
			//在所有网络应用开始的地方，初始化整个网络系统。
			NetWork.initialize();
			
			
			//从连接管理器取得一个自己命名的连接器实例。一个应用程序中，支持多个连接器。
			var conn:IConnector = ConnectManager.getConnector("game");
			
			//得到一个自己命名的协议管理器实例。一个应用中，可能会有多个协议管理器。
			//对应不同的连接器，或者同一个连接器的不同格式的协议。
			var mgrPtl:ProtocolManager = ProtocolManager.getProtocolManager("game");
			
			
			//初始化协议管理器，使其与连接器、协议头关联起来
			mgrPtl.initialize(new PTL_Head);
			mgrPtl.setConnector(conn);
			
			
			//建立连接
			conn.connect("10.0.0.1",1234);
			conn.addEventListener(Event.CONNECT, onConnEvent);	
			
			//注册协议
			mgrPtl.regProtocol(PTL_X);
			
			//在一个逻辑里，监听了X协议
			mgrPtl.addProtocolListener(PTL_X.ID, onPtlXEvent1);
			
			//在另一个逻辑里，也监听了X协议
			mgrPtl.addProtocolListener(PTL_X.ID, onPtlXEvent2);
			
			
		}
		
		private function onConnEvent(e:Event):void
		{
			if(e.type == Event.CONNECT)
			{
				//以1对1的模式，发送协议。
				//其回包只能被onPtlXEvent0监听到
				var ptl:PTL_X = new PTL_X(onPtlXEvent0);
				ptl.send();
				
				//以1对多的模式，发送协议
				//其回包可以被onPtlXEvent1和onPtlXEvent2同时监听到。
				ptl = new PTL_X();
				ptl.send();
			}
		}
		
		
		private function onPtlXEvent0(e:ProtocolEvent):void
		{
			var ptl:PTL_X = e.target as PTL_X;
			if(e.type == ProtocolEvent.PTL_SINK)
			{
				//处理协议
				ptl.sc_param1;
				ptl.sc_param2;
				ptl.sc_param3;
			}
			else if(e.type == ProtocolEvent.PTL_TIMEOUT)
			{
				//协议超时了
			}
			else
			{
				//协议出错了
			}
		}
		
		private function onPtlXEvent1(e:ProtocolEvent):void
		{
			
		}
		
		private function onPtlXEvent2(e:ProtocolEvent):void
		{
			
		}

	}
}