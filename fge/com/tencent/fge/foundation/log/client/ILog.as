/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   ILog.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2009-1
#   Comment     :   一个基于AS3的日志系统，支持3+X种日志输出方式。
 * 					1、可以将日志输出到IDE里。
 * 					2、可以将日志输出到一个配套的DebugView工具里。方便脱离IDE时查看日志
 * 					3、可以将日志输出到ExternalInterface。方便第三方开发日志查看器。
 * 					比如可以在JavaScript里写一个工具查看日志。
 * 					X、可以将日志输出到自定义的接口ICustomOutput。
 * 					
 * 					它支持通过一个外部的配置文件控制日志的开关。控制粒度精确到类。		
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-1 文件创建 
 * 					2010-3 增加ICustomOutput功能
#
*************************************************************************/

package com.tencent.fge.foundation.log.client
{
	public interface ILog
	{
		//Trace日志
		function trace(funName:String, ... arg):void;
		//Error日志
		function error(funName:String, ... arg):void;
		//Verbose日志
		function debug(funName:String, ... arg):void;
		//抛出异常，及日志
		function exthrow(funName:String, ... arg):void;
		//可以指定日志类型的日志函数
		function log(type:String, cls:String, func:String, ... arg):void;	
	}
}