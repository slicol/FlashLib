/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   NetWork.as
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
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-4 文件创建 
#
*************************************************************************/

package com.tencent.fge.foundation.network
{	
	import flash.utils.getQualifiedClassName;
	
	public class NetWork
	{
		public static var LocalDebug:Boolean = false;

		public function NetWork()
		{
			if (getQualifiedClassName(this) == "com.tencent.fge.foundation.network::NetWork") 
			{
				throw new ArgumentError("NetWork can't be instantiated directly");
			}				
		}
		
		public static function initialize():Boolean
		{
			ConnectManager.initialize();
			ProtocolManager.initialize();
			return true;
		}
		
		public static function finalize():void
		{
			ConnectManager.finalize();
			ProtocolManager.finalize();
		}
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";			
	}
}