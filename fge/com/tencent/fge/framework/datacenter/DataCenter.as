/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   DataCenter.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-1
#   Comment     :   一个DataCenter的实现类。在AS里将数据抽象封装起来。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-6 文件创建 
#
*************************************************************************/


package com.tencent.fge.framework.datacenter
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	public class DataCenter extends EventDispatcher implements IDataCenter
	{
		public var m_useExtImpl:Boolean = false;
		
		static private var ms_instance:DataCenter;
		private var m_mapData2Listener:Dictionary = new Dictionary;



		public function DataCenter(target:IEventDispatcher=null)
		{
			super(target);
			if(ms_instance)
			{
				throw Error("DataCenter 必须是一个单例！");
			}
		}
		
		static public function getInstance():DataCenter
		{
			if(ms_instance == null)
			{
				ms_instance = new DataCenter;
			}
			return ms_instance;
		} 
		
		public static function initialize(useExtImpl:Boolean):Boolean
		{
			return getInstance().initialize(useExtImpl);
		}
		
		
		private function initialize(useExtImpl:Boolean):Boolean
		{
			m_useExtImpl = useExtImpl;
			if(useExtImpl && ExternalInterface.available)
			{
				ExternalInterface.addCallback("DataCenter_OnDataChange", onDataChange);
			}
			return true;
		}
		
		public function get useExtImpl():Boolean{return m_useExtImpl;}
		
		
		protected function onDataChange(sDataName:String, xValue:*):void
		{
			var helper:DataHelper = m_mapData2Listener[sDataName];
			if(helper != null)
			{
				helper.update(xValue);
			}
		}
		
		
		public function dbgDataChange(sDataName:String, xValue:*):void
		{
			onDataChange(sDataName, xValue);
		}
		
		
		//------------------------------------------------------------------------
		
		public function addDataListener(sDataName:String, listener:Function, bAsy:Boolean = true):void
		{
			var helper:DataHelper = m_mapData2Listener[sDataName];
			if(helper == null)
			{
				helper = new DataHelper(sDataName);
				m_mapData2Listener[sDataName] = helper;
			}
			
			if(helper.addListener(listener, bAsy) == 1)
			{
				if(ExternalInterface.available)
				{
					ExternalInterface.call("DataCenter_AddDataListener", sDataName);
				}
			}
		}
		
		public function removeDataListener(sDataName:String, listener:Function):void
		{
			var helper:DataHelper = m_mapData2Listener[sDataName];
			if(helper != null)
			{
				if(helper.removeListener(listener) == 0)
				{
					if(ExternalInterface.available)
					{
						ExternalInterface.call("DataCenter_RemoveDataListener", sDataName);
					}
					delete m_mapData2Listener[sDataName];
				}
			}
		}
		
		//------------------------------------------------------------------------
		
		protected function internalWrite(type:String, sName:String, xValue:*):Boolean
		{
			var helper:DataHelper = m_mapData2Listener[sName];
			if(helper == null)
			{
				helper = new DataHelper(sName, type);
				m_mapData2Listener[sName] = helper;
			}
			
			if(!helper.checkType(type))
			{
				return false;
			}
			
			helper.setValue(xValue);
			return true;				
		}
		
		public function writeInt32(sName:String, xValue:int):Boolean
		{
			if(useExtImpl)
			{
				return ExternalInterface.call("DataCenter_WriteInt32", sName, xValue);
			}
			else
			{
				return internalWrite("Int32", sName, xValue);
			}
		}
		
		public function writeInt64(sName:String, xValue:String):Boolean
		{
			if(useExtImpl)
			{
				return ExternalInterface.call("DataCenter_WriteInt64", sName, xValue);
			}
			else
			{
				return internalWrite("Int64", sName, xValue);	
			}
		}
		
		public function writeNumber(sName:String, xValue:Number):Boolean
		{
			if(useExtImpl)
			{
				return ExternalInterface.call("DataCenter_WriteNumber", sName, xValue);
			}
			else
			{
				return internalWrite("Number", sName, xValue);	
			}
		}
		
		public function writeString(sName:String, xValue:String):Boolean
		{
			if(useExtImpl)
			{
				return ExternalInterface.call("DataCenter_WriteString", sName, xValue);
			}
			else
			{
				return internalWrite("String", sName, xValue);	
			}
		}
		
		public function writeBytes(sName:String, xValue:ByteArray):Boolean
		{
			if(useExtImpl)
			{
				return ExternalInterface.call("DataCenter_WriteBytes", sName, xValue);
			}
			else
			{
				return internalWrite("Bytes", sName, xValue);	
			}
		}
		
		
		//------------------------------------------------------------------------
		
		protected function internalRead(type:String, sName:String):*
		{
			var helper:DataHelper = m_mapData2Listener[sName];
			if(helper != null)
			{
				if(helper.getType() == type)
				{
					return helper.getValue();
				}
			}
			return DataHelper.getNull(type);
		}
		
		public function readInt32(sName:String):int
		{
			if(useExtImpl)
			{
				return ExternalInterface.call("DataCenter_ReadInt32", sName);
			}
			else
			{
				return internalRead("Int32", sName);
			}
		}
		
		public function readInt64(sName:String):String
		{			
			if(useExtImpl)
			{
				return ExternalInterface.call("DataCenter_ReadInt64", sName);
			}
			else
			{
				return internalRead("Int64", sName);
			}			
		}
		
		public function readNumber(sName:String):Number
		{
			if(useExtImpl)
			{
				return ExternalInterface.call("DataCenter_ReadNumber", sName);
			}
			else
			{
				return internalRead("Number", sName);
			}
		}
		
		public function readString(sName:String):String
		{
			if(useExtImpl)
			{
				return ExternalInterface.call("DataCenter_ReadString", sName);
			}
			else
			{
				return internalRead("String", sName);
			}
		}
		
		public function readBytes(sName:String):ByteArray
		{
			if(useExtImpl)
			{
				return ExternalInterface.call("DataCenter_ReadBytes", sName);
			}
			else
			{
				return internalRead("Bytes", sName);
			}
		}
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";			
	}
}
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	


class DataHelper
{
	private var m_name:String;
	private var m_value:*;
	private var m_type:String;
	private var m_lstSynListener:Array = new Array;
	private var m_lstAsyListener:Array = new Array;
	private var m_bAsyChange:Boolean = false;
	private var m_bSynChange:Boolean = false;
	
	static private var m_lstAsyDataChange:Array = new Array;
	static private var m_timAsyInvoke:Timer;
	
	public function DataHelper(name:String, type:String = null)
	{
		m_name = name;
		m_type = type;
		if(m_timAsyInvoke == null)
		{
			m_timAsyInvoke = new Timer(50, 1)
			m_timAsyInvoke.addEventListener(TimerEvent.TIMER, DataHelper.onAsyTimer);
		}
	}
	
	
	public function addListener(listener:Function, bAsy:Boolean):int
	{
		var lstOpListener:Array;
		
		lstOpListener = bAsy ? m_lstAsyListener : m_lstSynListener;
		for(var i:int = 0; i < lstOpListener.length; ++i)
		{
			if(lstOpListener[i] == listener)
			{
				return lstOpListener.length;
			}
		}
		lstOpListener.push(listener);
		
		lstOpListener = bAsy ? m_lstSynListener : m_lstAsyListener;
		removeListenerFrom(lstOpListener, listener);
		return getListenerNumber();
	}
	
	public function getListenerNumber():int
	{
		return m_lstSynListener.length + m_lstAsyListener.length;
	}
	
	public function removeListener(listener:Function):int
	{
		removeListenerFrom(m_lstAsyListener, listener);
		removeListenerFrom(m_lstSynListener, listener);
		return getListenerNumber();		
	}
	
	public function update(data:*):void
	{
		m_value = data
		m_bAsyChange = true;
		m_bSynChange = true;
		
		dispatchSynDataChange();
		
		m_lstAsyDataChange.push(this);
		if(m_lstAsyDataChange.length == 1)
		{
			m_timAsyInvoke.start();
		}
	}
	
	
	public function getValue():*
	{
		return m_value;
	}
	
	public function setValue(data:*):void
	{
		if(m_value != data)
		{
			update(data);
		}
	}
	
	public function checkType(type:String):Boolean
	{
		if(m_type == null)
		{
			m_type = type;
			return m_type != null;
		}
		else
		{
			return m_type == type;
		}
	}
	
	public function getType():String
	{
		return m_type;
	}
		
	protected function dispatchAsyDataChange():void
	{
		if(!m_bAsyChange)
		{
			return;
		}
		
		m_bAsyChange = false;
		
		for(var i:int = 0; i < m_lstAsyListener.length; ++i)
		{
			var listener:Function = m_lstAsyListener[i];
			listener(m_name, m_value);
		}		
	}
	
	protected function dispatchSynDataChange():void
	{
		if(!m_bSynChange)
		{
			return;
		}
		
		m_bSynChange = false;
		
		for(var i:int = 0; i < m_lstSynListener.length; ++i)
		{
			var listener:Function = m_lstSynListener[i];
			listener(m_name, m_value);
		}		
	}	
	
	protected function removeListenerFrom(lstListener:Array, listener:Function):void
	{
		for(var i:int = 0; i < lstListener.length; ++i)
		{
			if(lstListener[i] == listener)
			{
				lstListener.splice(i, 1);
				return;
			}
		}		
	}
	
	
	static private function onAsyTimer(e:Event):void
	{
		var lstAsyDataChange:Array = m_lstAsyDataChange;
		m_lstAsyDataChange = new Array;
		
		for(var i:int = 0; i < lstAsyDataChange.length; ++i)
		{
			var helper:DataHelper = lstAsyDataChange[i];
			helper.dispatchAsyDataChange();
		}		
	}
	
	static public function getNull(type:String):*
	{
		switch(type)
		{
		case "Int32": return 0;
		case "Int64": return "0";
		case "Number": return 0;
		case "String": return null;
		case "Bytes": return null;
		default:	return null;
		}
	}
}