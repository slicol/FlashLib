/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   IProtocolSender.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-4
#   Comment     :   用于发送协议的接口。
 * 				
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-4 文件创建 
#
*************************************************************************/

package com.tencent.fge.foundation.network
{
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;

	public interface IProtocolSender extends IEventDispatcher
	{
		function sendProtocol(pid:uint, data:ByteArray, protocol:BaseProtocol = null):uint;
	}
}