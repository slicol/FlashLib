/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   IConnector.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-4
#   Comment     :   连接器接口
 * 				
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-4 文件创建 
#
*************************************************************************/

package com.tencent.fge.foundation.network
{
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;

	public interface IConnector extends IEventDispatcher
	{
		function sendData(data:ByteArray):Boolean;
		function setTimeout(timeout:int):void;
		function connect(host:String, port:int):void;
		function close():void;
		function readData(data:ByteArray, offset:uint):uint;
		function get connected():Boolean;
		function get bytesAvailable():uint;
		function get host():String;
		function get port():int;
	}
}