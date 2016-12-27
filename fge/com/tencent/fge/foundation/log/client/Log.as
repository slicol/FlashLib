/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   Log.as
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
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.external.ExternalInterface;
	import flash.net.LocalConnection;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	public class Log implements ILog
	{
		public static const OUT2IDE:int = 0;
		public static const OUT2LC:int = 1;
		public static const OUT2API:int = 2;
		public static const OUT2CUSTOM:int = 3;
		public static const OUT2SO:int = 4;
		
		public static var connServerName:String = "DebugServer";
		
		private static var glbTraceChanged:Boolean = false;
		private static var glbErrorChanged:Boolean = false;
		private static var glbDebugChanged:Boolean = false;
		private static var glbWarnChanged:Boolean = false;
		
		private static var cfgChanged:Boolean = false;
		private static var useConfig:Boolean = false;
		private static var outTarget:int = OUT2IDE;
		private static var customOutput:ICustomOutput;

		private static var logList:Vector.<Log> = new Vector.<Log>;
		private static var conn:LocalConnection = new LocalConnection;
		private static var logConfig:LogConfig = new LogConfig;

		
		private static var bTrace:Boolean = false;
		private static var bError:Boolean = true;
		private static var bThrow:Boolean = false;
		private static var bDebug:Boolean = true;
		private static var bWarn:Boolean = true;
		private static var logCount:int = 0;
		
		private var bTrace:Boolean = false;
		private var bError:Boolean = true;
		private var bThrow:Boolean = false;
		private var bDebug:Boolean = true;
		private var bWarn:Boolean = true;
		private var logCount:int = 0;
		
		private var clsName:String = "*";
		private var funName:String = "*";
		private var curDate:Date = new Date;
		
		private static var outLog:Function;
		
		
		

		public function Log(cls:Object = null, funName:String = null, 
			bTrace:Boolean = true, 
			bError:Boolean = true, 
			bDebug:Boolean = true,
			bThrow:Boolean = true,
			bWarn:Boolean = true
			)
		{
			if(cls != null)
			{
				if(cls is String)
				{
					this.clsName = cls as String;
				}
				else
				{
					this.clsName = getQualifiedClassName(cls);
					var i:int = this.clsName.lastIndexOf("::");
					if(i >= 0) this.clsName = this.clsName.substring(i+2);
				}
			}
			
			if(funName != null)
			{
				this.funName = funName;
			}
			
			if(Log.useConfig)
			{
				this.bError = logConfig.logError(this.clsName);
				this.bTrace = logConfig.logTrace(this.clsName);
				this.bDebug = logConfig.logDebug(this.clsName);
				this.bThrow = logConfig.logThrow(this.clsName);		
				this.bWarn = logConfig.logWarn(this.clsName);		
			}
			else
			{
				this.bTrace = bTrace;
				this.bError = bError;
				this.bDebug = bDebug;
				this.bThrow = bThrow;		
				this.bWarn = bWarn;
			}
		
			
			logList.push(this);
		}
		

		
		//用于初始化整个日志系统。
		//整个程序只调用一次。
		//useConfig:决定是使用外部配置文件，还是使用构造函数的参数，来打开日志开关。
		//logTarget:决定将日志输出到哪里。有３种选择，详见相关定义。
		public static function initialize(useConfig:Boolean,logTarget:int, 
										  customOut:ICustomOutput = null, param:Object = null):void
		{
			//调试器
			conn.addEventListener(StatusEvent.STATUS, Log.onStatusEvent);
			if(useConfig)
			{
				logConfig.load();
				logConfig.addEventListener(LogConfig.EVENT_LOAD_COMPLETE, Log.onLoadConfig);
			}
			else
			{
				Log.bTrace = true;
				Log.bError = true;
				Log.bDebug = true;
				Log.bThrow = true;			 
				Log.bWarn = true;
				
				//Log.bTrace = false;
				//Log.bError = false;
				//Log.bDebug = false;
				//Log.bThrow = false;			
			}

			Log.customOutput = customOut;
			Log.useConfig = useConfig;
			
			setLogTarget(logTarget, param);
		}
		

		public static function loadConfig(url:String):void
		{
			Log.cfgChanged = true;
			Log.useConfig = true;
			logConfig.load(url);
			logConfig.addEventListener(LogConfig.EVENT_LOAD_COMPLETE, Log.onLoadConfig);
		}
		
		public static function loadConfigContent(content:String):void
		{
			Log.cfgChanged = true;
			Log.useConfig = true;
			if(logConfig.loadContent(content))
			{
				updateGlobalFlag();
			}
		}
		
		public static function clearConfig():void
		{
			Log.cfgChanged = false;
		}
		
		public static function getAllLogList():Vector.<Log>
		{
			return logList.concat();
		}
		
		public static function setCustomOut(customOut:ICustomOutput):void
		{
			Log.customOutput = customOut;
		}
		
		public static function setLogTarget(logTarget:int, param:Object = null):void
		{
			Log.outTarget = logTarget;
		
			switch(Log.outTarget)
			{
				case Log.OUT2API:	Log.outLog = Log.outLog2Api; break;
				case Log.OUT2IDE:	Log.outLog = Log.outLog2Ide; break;
				case Log.OUT2LC:	Log.outLog = Log.outLog2LC; break;
				case Log.OUT2SO:	Log.outLog = Log.outLog2SO; break;
				case Log.OUT2CUSTOM:Log.outLog = 
					(Log.customOutput != null ? Log.customOutput.outLog : Log.outLog2Custom);break;
				default: 			Log.outLog = Log.outLog2Ide; 
			}
			
			if(Log.outTarget == Log.OUT2SO)
			{
				SOLog.ready(param);
			}
		}
		
		public static function setTraceEnable(value:Boolean):void
		{
			Log.glbTraceChanged = true;
			Log.bTrace = value;
		}
		
		public static function getTraceEnable():Boolean
		{
			return bTrace;
		}
		
		public static function setErrorEnable(value:Boolean):void
		{
			Log.glbErrorChanged = true;
			Log.bError = value;
		}
		
		public static function getErrorEnable():Boolean
		{
			return bError;
		}
		
		public static function setThrowEnable(value:Boolean):void
		{
			Log.bThrow = value;
		}
		
		public static function getThrowEnable():Boolean
		{
			return bThrow;
		}
		
		public static function setDebugEnable(value:Boolean):void
		{
			Log.glbDebugChanged = true;
			Log.bDebug = value;
		}
		
		public static function getDebugEnable():Boolean
		{
			return bDebug;
		}
		
		public static function setWarnEnable(value:Boolean):void
		{
			Log.glbWarnChanged = true;
			Log.bWarn = value;
		}
		
		public static function getWarnEnable():Boolean
		{
			return bWarn;
		}
		
		//不处理，但必须写在这里，以防止提示错误。
		private static function onStatusEvent(e:StatusEvent):void
		{
		}
		
		private static function onLoadConfig(e:Event):void
		{
			updateGlobalFlag();
		}
		
		private static function updateGlobalFlag():void
		{
			Log.bError = logConfig.logError();
			Log.bTrace = logConfig.logTrace();
			Log.bDebug = logConfig.logDebug();
			Log.bThrow = logConfig.logThrow();
			Log.bWarn = logConfig.logWarn();
			Log.outTarget = logConfig.logOutTarget();
		}
		
		//修改标题
		public function attachClassName(clsName:String):void
		{
			this.clsName = clsName;
			
			if(Log.useConfig)
			{
				this.bError = logConfig.logError(this.clsName);
				this.bTrace = logConfig.logTrace(this.clsName);
				this.bDebug = logConfig.logDebug(this.clsName);
				this.bThrow = logConfig.logThrow(this.clsName);		
				this.bWarn = logConfig.logWarn(this.clsName);
			}		
		}
		
		public function getClsName():String
		{
			return this.clsName;
		}
		
		public function getLogCount():int
		{
			return this.logCount;
		}
		
		
		//Trace日志
		public function trace(funName:String, ... arg):void
		{
			if(Log.bTrace)
			{
				if(Log.glbTraceChanged)
				{
					_log("Trace", funName, arg);
				}
				else if(Log.cfgChanged)
				{
					if(logConfig.logTrace(this.clsName))
					{
						_log("Trace", funName, arg);
					}
				}
				else
				{
					if(this.bTrace)
					{
						_log("Trace", funName, arg);
					}
				}
			}
		}
		
		//Error日志
		public function error(funName:String, ... arg):void
		{
			if(Log.bError)
			{
				if(Log.glbErrorChanged)
				{
					_log("Error", funName, arg);
				}
				else if(Log.cfgChanged)
				{
					if(logConfig.logError(this.clsName))
					{
						_log("Error", funName, arg);
					}
				}
				else
				{
					if(this.bError)
					{
						_log("Error", funName, arg);
					}
				}
			}
		}
		
		
		//Warn日志
		public function warn(funName:String, ... arg):void
		{
			if(Log.bWarn)
			{
				if(Log.glbWarnChanged)
				{
					_log("Warn", funName, arg);
				}
				else if(Log.cfgChanged)
				{
					if(logConfig.logWarn(this.clsName))
					{
						_log("Warn", funName, arg);
					}
				}
				else
				{
					if(this.bWarn)
					{
						_log("Warn", funName, arg);
					}
				}
			}
			
		}
		
		
		//Debug日志
		public function debug(funName:String, ... arg):void
		{
			if(Log.bDebug)
			{
				if(Log.glbDebugChanged)
				{
					_log("Debug", funName, arg);
				}
				else if(Log.cfgChanged)
				{
					if(logConfig.logDebug(this.clsName))
					{
						_log("Debug", funName, arg);
					}
				}
				else
				{
					if(this.bDebug)
					{
						_log("Debug", funName, arg);
					}
				}
			}
		}
		
		
		//抛出异常，及日志
		public function exthrow(funName:String, ... arg):void
		{
			var flag:Boolean = false;
			
			if(Log.bThrow)
			{
				if(Log.cfgChanged)
				{
					if(logConfig.logThrow(this.clsName))
					{
						flag = true;
					}
				}
				else
				{
					if(this.bThrow)
					{
						flag = true;
					}
				}
			}
			
			if(flag)
			{
				_log("Throw", funName, arg);
				var info:String = 
					this.clsName + "." + funName + "() " + arg.toString();
				throw("抛出异常："+info);
			}
			else
			{
				if(Log.bError)
				{
					if(Log.cfgChanged)
					{
						if(logConfig.logError(this.clsName))
						{
							_log("Error", funName, arg);
						}
					}
					else
					{
						if(this.bError)
						{
							_log("Error", funName, arg);
						}
					}
				}
			}
		}
		
		
		//可以指定日志类型的日志函数
		public function log(type:String, cls:String, func:String, ... arg):void
		{
			this.logCount++;
			Log.outLog(curDate.toTimeString(), type, cls, func, arg);
		}
		
		
		
		private function _log(type:String, funName:String, arg:Array):void
		{			
			if(funName != null)
			{
				this.funName = funName;
			}
			this.logCount++;
			
			var date:Date = new Date;
			var timeStr:String = date.hours + ":" + 
				date.minutes + ":" + 
				date.seconds + "." + 
				int(date.milliseconds);
			
			Log.outLog(timeStr, type, this.clsName, this.funName, arg);
		}
		
		
		//将日志输出到自定义的一个地方去
		private static function outLog2Custom(time:String, type:String, 
									cls:String, func:String, arg:Array):void
		{			
			if(customOutput != null)
			{
				Log.logCount ++;
				customOutput.outLog(time, type, cls, func, arg);
				Log.outLog = customOutput.outLog
			}
			else
			{
				outLog2Ide(time, type, cls, func, arg);
			}
		}
	
		//将日志输出到另外一个日志监视器（Flash，或者Client开发，基于端口通讯）
		private static function outLog2LC(time:String, type:String, 
			cls:String, func:String, arg:Array):void
		{			
			Log.logCount ++;
			conn.send(connServerName, "outputLog", time , type, cls, func, arg);
		}
		
		
		//将日志输出到Client的API，作为Client日志的一部分，可以记录在日志文件里。
		private static function outLog2Api(time:String, type:String, 
			cls:String, func:String, arg:Array):void
		{
			Log.logCount ++;
			var info:String = cls + "." + func + "() " + arg.toString();
			ExternalInterface.call("API.Log", info);
		}
		
		//将日志输出到SO里
		private static function outLog2SO(time:String, type:String, 
										   cls:String, func:String, arg:Array):void
		{			
			Log.logCount ++;
			var info:String = "[" + time + "]["+Log.logCount+"]["+type+"] " + cls + "." + func + "() " + arg.toString();
			SOLog.out(info);
		}
		
		
		//将日志输出在IDE。
		private static function outLog2Ide(time:String, type:String, 
			cls:String, func:String, arg:Array):void
		{			
			Log.logCount ++;
			
			var info:String = "[" + time + "]["+Log.logCount+"]["+type+"] " + cls + "." + func + "() " + arg.toString();
			IdeLog.out(info);
		}
		
		
		
		public static function exthrow(funName:String, ... arg):void
		{
			if(Log.outLog != null)
			{
				Log.outLog(null, "Throw", "*", funName, arg);
			}
			
			if(Log.bThrow)
			{
				var info:String = 
					"*." + funName + "() " + arg.toString();
				throw("抛出异常："+info);
			}
		}
		
		public static function trace(funName:String, ... arg):void
		{
			if(Log.outLog != null && Log.bTrace)
			{
				Log.outLog(null, "Trace", "*", funName, arg);
			}
		}
		
		public static function error(funName:String, ... arg):void
		{
			if(Log.outLog != null && Log.bError)
			{
				Log.outLog(null, "Error", "*", funName, arg);
			}
		}
		
		public static function warn(funName:String, ... arg):void
		{
			if(Log.outLog != null && Log.bWarn)
			{
				Log.outLog(null, "Warn", "*", funName, arg);
			}
		}
		
		public static function debug(funName:String, ... arg):void
		{
			if(Log.outLog != null && Log.bDebug)
			{
				Log.outLog(null, "Debug", "*", funName, arg);
			}
		}
		
		public static function log(type:String, cls:String, func:String, ... arg):void
		{
			if(Log.outLog != null)
			{
				Log.outLog(null, type, cls, func, arg);
			}
		}
		
		
		//---------------------------------------------------------------
		//提供一些辅助函数
		//---------------------------------------------------------------
	
		public static function getLSOLogList(name:String = null):Dictionary
		{
			return SOLog.getLogList(name);
		}
		

		//---------------------------------------------------------------
		//---------------------------------------------------------------
		protected var version:String = "1.0.0";
		protected var author:String = "slicoltang,slicol@qq.com";
		protected var copyright:String = "腾讯计算机系统有限公司";	     
	}
}
import com.tencent.fge.foundation.log.client.Log;

import flash.net.SharedObject;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

class IdeLog
{
	public function IdeLog():void
	{
		
	}
	
	public static function out(s:String):void
	{
		trace(s);
	}
}

class SOLog
{
	private static var ms_so:SharedObject;
	private static var ms_log:Vector.<String> = new Vector.<String>;
	
	private static function getLSOName(name:String = null):String
	{
		var pre:String = "";
		pre = getQualifiedClassName(Log);
		pre = pre.replace("::", ".");
		if(name != null && name != "")
		{
			pre = pre + "[" + name + "]";
		}
		return pre;
	}
	
	public static function ready(param:Object):void
	{
		var name:String = "";

		if(param == null)
		{
			return;
		}
		
		if(param.hasOwnProperty("name"))
		{
			name = getLSOName(param["name"]);
		}
		else
		{
			name = getLSOName(null);
		}
		
		try
		{
			ms_so = SharedObject.getLocal(name, "/");
		}
		catch(e:Error)
		{
			return;
		}
		
		if(ms_so)
		{
			var list:Dictionary;
			
			if(ms_so.data.hasOwnProperty("list"))
			{
				list = ms_so.data["list"];
			}
			
			if(list == null)
			{
				list = new Dictionary;
				ms_so.data["list"] = list;
			}
			
			//计算日志列表生成日期
			var date:Date = new Date;
			var time:String = getTimeString(date);

			//计算是否需要清除旧日志
			var keepDate:int = 0;
			if(param.hasOwnProperty("keepDate"))
			{
				keepDate = Number(param["keepDate"]);
				
				if(keepDate > 0)
				{
					date.date -= keepDate;
					var timeOld:String = getTimeString(date);
					//清除1周前的日志
					clearOldLog(list, timeOld);
				}
			}
			
			//关联日志列表到SO
			list[time] = ms_log;
		}
	}
	
	
	public static function getLogList(name:String):Dictionary
	{
		var ret:Dictionary = null;
		var so:SharedObject;
		
		name = getLSOName(name);
		
		try
		{
			so = SharedObject.getLocal(name, "/");
		}
		catch(e:Error)
		{
			return ret;
		}
		
		if(so != null)
		{
			ret = so.data["list"];
		}
		
		return ret;
	}
	
	
	
	private static function getTimeString(date:Date):String
	{
		date.date < 10 ? "0" + date.date.toString() : date.date.toString();
		
		var time:String = date.fullYear + "." + 
			num2string(date.month + 1) + "." + 
			num2string(date.date) + "_" + 
			num2string(date.hours) + ":" + 
			num2string(date.minutes) + ":" + 
			num2string(date.seconds);
		
		return time;
	}
	
	private static function num2string(num:int):String
	{
		return num < 10 ? "0" + num.toString() : num.toString();
	}
	
	private static function clearOldLog(list:Dictionary, timeOld:String):void
	{
		var listOldKey:Array = new Array;
		var key:String;
		
		for (key in list)
		{
			if(key < timeOld)
			{
				listOldKey.push(key);
			}
		}
		
		
		for(var i:int = 0; i < listOldKey.length; ++i)
		{
			key = listOldKey[i];
			delete list[key];
		}
	}
	
	public static function out(s:String):void
	{
		ms_log.push(s);
	}
}