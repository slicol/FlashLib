/*************************************************************************
版权所有 (C), 1998-2010, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   KeyArray.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-5
#   Comment     :   一个支持索引号和关键字查询的数组。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-5 文件创建 
#
*************************************************************************/



package com.tencent.fge.utils
{
	import flash.utils.Dictionary;
	
	public class KeyArray
	{
		private var m_array:Array;
		private var m_mapKey:Dictionary;
		private var m_sortFieldName:Array;
		private var m_numElements:int = 0;
		
		public function KeyArray(numElements:int = 0)
		{
			m_numElements = numElements;
			m_array = new Array(numElements);
			m_mapKey = new Dictionary(false);
		}
		
		public function get length():uint
		{
			return m_array.length;
		}
		
		public function push(key:*, o:Object):void
		{
			if(m_mapKey[key] != null)
			{
				return;
			}
			
			var hlp:Helper = new Helper(key, o);
			m_array.push(hlp);
			m_mapKey[key] = o;
		}
		
		public function pop():Object
		{
			var hlp:Helper = m_array.pop();
			delete m_mapKey[hlp.key];
			return hlp.o;
		}
		
		public function splice(startIndex:int, deleteCount:uint):Array
		{
			var tmp:Array = m_array.splice(startIndex, deleteCount);
			for(var i:int = 0; i < tmp.length; ++i)
			{
				var hlp:Helper = tmp[i];
				delete m_mapKey[hlp.key];
				tmp[i] = hlp.o;
			}
			return tmp;
		}
		
		public function remove(key:*):*
		{
			var o:Object = m_mapKey[key];
			if(o == null) return o;
			
			for(var i:int = 0; i < m_array.length; ++i)
			{
				if(m_array[i].o == o)
				{
					m_array.splice(i,1);
					delete m_mapKey[key];
					return o;
				}
			}
			return null;
		}
		
		public function removeAll():void
		{
			for(var i:int = 0; i < m_array.length; ++i)
			{
				var hlp:Helper = m_array[i];
				delete m_mapKey[hlp.key];
			}
			m_array = new Array(m_numElements);
			m_mapKey = new Dictionary(false);
		}
		
		
		public function setElement(index:uint, key:*, o:Object):void
		{
			var hlp:Helper = m_array[index];
			if(hlp != null)
			{
				delete m_mapKey[hlp.key];
			}
			hlp = new Helper(key, o);
			m_array[index] = hlp;
			m_mapKey[key] = o;
		}
		
		public function getElement(id:*):*
		{
			if(id is int)
			{
				var nIndex:int = Number(id);
				if(nIndex < m_array.length)
				{
					return m_array[nIndex].o;
				}		
			}
			else if(id is uint)
			{
				var uIndex:uint = Number(id);
				if(uIndex < m_array.length)
				{
					return m_array[uIndex].o;
				}
			}
			
			return m_mapKey[id];
		}
		
		public function getElementByIndex(index:int):*
		{
			if(index < m_array.length)
			{
				return m_array[index].o;
			}
		}
		
		public function getElementByKey(key:*):*
		{
			return m_mapKey[key];
		}
		
		public function sortOn(fieldName:Object, options:Object = null):void
		{
			m_sortFieldName = new Array;
			if(fieldName is Array)
			{
				m_sortFieldName = m_sortFieldName.concat(fieldName);
			}
			else
			{
				m_sortFieldName.push(fieldName);
			}
			m_array.sort(compare);
		}
		
		private function compare(a:Helper,b:Helper):int
	    { 
	    	for(var i:int = 0; i < m_sortFieldName.length; ++i)
	    	{
	    		var f:String = m_sortFieldName[i];
	    		if(a.o[f]< b.o[f])
		    	{
		    		return -1;
		    	}
		    	else if(a.o[f]> b.o[f])
		    	{
		    		return 1
		    	}
	    	}
	    	
	    	return 0;
	    } 		

	}
}

class Helper
{
	public var key:*;
	public var o:Object;
	
	public function Helper(key:*, o:Object)
	{
		this.key = key;
		this.o = o;
	}
}