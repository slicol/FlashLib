/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   ICustomOutput.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-3
#   Comment     :   支持自定义的日志输出
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-3 文件创建 
 * 					
#
*************************************************************************/

package com.tencent.fge.foundation.log.client
{
	public interface ICustomOutput
	{
		function outLog(time:String, type:String, 
			cls:String, func:String, arg:Array):void;
	}
}