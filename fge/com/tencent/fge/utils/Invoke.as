/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   Invoke.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2009-11
#   Comment     :   一个基于AS3的调用封装类，将一个“调用操作”封装成一个类
 * 					这样，就可以将该操作作为对象进行传递。
 * 					以实现比如定时执行、异步执行、延时执行等功能。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-11 文件创建 
#
*************************************************************************/

package com.tencent.fge.utils
{
	public class Invoke
	{
		private var m_fun:Function;
		private var m_arg:Object = new Object;
		
		public function Invoke(fun:Function, ...arg):void
		{
			this.m_fun = fun;
			this.m_arg = arg;
		}
		
		public function set arg(value:Object):void
		{
			if(value is Array)
			{
				m_arg = value;
			}
			else
			{
				m_arg = [value];
			}
		}
		
		public function get arg():Object
		{
			return m_arg;
		}
		
		public function get fun():Function
		{
			return m_fun;
		}
		
		public function release():void
		{
			m_fun = null;
			m_arg = null;
		}
		
		
		public function execute():void
		{
			var fun:Function = this.m_fun;
			var arg:Array = this.m_arg as Array;
			
			if(fun == null) return;
			switch(arg.length)
			{
			case 0:
				fun();
				break;
			case 1:
				fun(arg[0]);
				break;
			case 2:
				fun(arg[0], arg[1]);
				break;
			case 3:
				fun(arg[0], arg[1], arg[2]);
				break;
			case 4:
				fun(arg[0], arg[1], arg[2], arg[3]);
				break;
			case 5:
				fun(arg[0], arg[1], arg[2], arg[3], arg[4]);
				break;
			case 6:
				fun(arg[0], arg[1], arg[2], arg[3], arg[4], arg[5]);
				break;
			case 7:
				fun(arg[0], arg[1], arg[2], arg[3], arg[4], arg[5], arg[6]);
				break;
			case 8:
				fun(arg[0], arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7]);
				break;
			case 9:
				fun(arg[0], arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8]);
				break;
			case 10:
				fun(arg[0], arg[1], arg[2], arg[3], arg[4], arg[5], arg[6], arg[7], arg[8], arg[9]);
				break;
			default:
				break;
			}
		}
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	  		
	}
}