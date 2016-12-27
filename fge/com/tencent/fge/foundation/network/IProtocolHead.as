/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   IProtocolHead.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-4
#   Comment     :   协议头（包头）的接口。不管具体协议的包头结构如何，都必定要提供如下数据。
 * 				
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-4 文件创建 
#
*************************************************************************/

package com.tencent.fge.foundation.network
{
	import flash.utils.ByteArray;
	
	public interface IProtocolHead
	{
		//协议数据写入，然后解析出协议头
		function writeBytes(bytes:ByteArray):uint;
		function copy(bytes:ByteArray):IProtocolHead;
		
		
		//可以读取解析后的协议头字段。
		//对于NetWork模块来说，这些字段足够了。
		//如果具体业务如果协议头字段比这更多，
		//可以在该接口的实现类里添加。
		function get pid():uint;
		function get headsize():uint;
		function get datasize():uint;
		function get length():uint;
		function get checksum():uint;
		function get index():uint;

		
		//将(协议头+协议体)的数据填充（读取）到bytes里。
		//在这个函数里，将计算CheckSum，并设置到bytes里。
		//index，	此次协议发送的顺序号
		//pid, 		此次协议的ID（命令字）
		//pdata, 	此次协议体的数据。
		function readBytes(bytes:ByteArray, 
						   index:uint, pid:uint, pdata:ByteArray):uint;

		
		//协议的加解密函数。
		//bytes, 	协议包数据
		//dec,		具体某条协议的编码算法ID（安全级别），目前全是1
		//key,		存储在协议头的现实类里。
		//			不同的协议头存储的Key可能一样，也可能不一样。
		//			这方便在同时连接不同的服务器时，可以使用不同的Key
		function encrypt(bytes:ByteArray, dec:int, pid:uint):ByteArray;
		function decrypt(bytes:ByteArray, dec:int, pid:uint):ByteArray;
	}
}