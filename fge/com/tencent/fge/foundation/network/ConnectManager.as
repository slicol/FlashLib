/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   ConnectManager.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-4
#   Comment     :   一个基于AS的通用网络层和协议层实现。
 * 					它内置了一个基于Socket的连接器，已经足够一般的AS项目使用
 * 					它还支持外定义网络连接器，可以实现基于Http的连接器。
 * 					它提供一个几乎可以通用的协议框架。支持外定义协议头。
 * 					该框架支持在一个应用，创建多个协议管理器。每一个协议管理器都可以对应
 * 					自己的协议头。
 * 					它支持传统的1对多的协议处理模式，也支持1对1的协议处理模式。
 * 					1对多，是指一条协议可以由一个逻辑发出，其回包可以由多个逻辑接收和处理。
 * 					1对1，是指一条协议由一个逻辑发出后，其回包只会被这个逻辑接收和处理。	
 * 
 * 					这里是网络层的实现。即：连接器管理器。
 * 				
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-4 文件创建 
#
*************************************************************************/


package com.tencent.fge.foundation.network
{
	import flash.utils.getQualifiedClassName;
	import flash.utils.Dictionary;
	
	public class ConnectManager
	{
		private static var ms_lstConnector:Dictionary = new Dictionary;
		private static var ms_lstClass:Dictionary = new Dictionary;
		
		public function ConnectManager()
		{
			if (getQualifiedClassName(this) == "com.tencent.fge.foundation.network::ConnectManager") 
			{
				throw new ArgumentError("ConnectManager can't be instantiated directly");
			}				
		}
		
		public static function initialize():Boolean
		{
			ms_lstClass["default"] = TcpConnector;
			return true;
		}
		
		public static function finalize():void
		{
			
		}		
		
		public static function regConnectorClass(
			type:String, cls:Class):Boolean
		{
			var c:Class = ms_lstClass[type];
			if(c == null)
			{
				ms_lstClass[type] = cls;
				return true;
			}
			if(type == "default" && cls != null)
			{
				ms_lstClass[type] = cls;
			}
			return false;			
		}
		
		public static function regConnector(
			name:String, conn:IConnector):Boolean
		{
			var c:IConnector = ms_lstConnector[name];
			if(c == null)
			{
				ms_lstConnector[name] = conn;
				return true;
			}
			return false;
		}		
		
		public static function getConnector(
			name:String, type:String = "default"):IConnector
		{
			var c:IConnector = ms_lstConnector[name];
			if(c == null)
			{
				var cls:Class = ms_lstClass[type];
				if(cls != null)
				{
					c = new cls;
				}
			}
			return c;
		}
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";			
	}
}