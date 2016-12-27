package com.tencent.fge.utils
{
	public class ListArray
	{
		private var m_arr:Array;
		
		public function ListArray(numElements:int=0)
		{
			if(numElements != 0)
			{
				m_arr = new Array(numElements);
			}
			else
			{
				m_arr = new Array;
			}
		}
		
		public function add(o:Object):uint
		{
			return m_arr.push(o);
		}
		
		public function remove(o:Object):uint
		{
			var i:int = m_arr.indexOf(o);
			if(i >= 0 && i < m_arr.length)
			{
				m_arr.splice(i, 1);
				return i;
			}
			return uint.MAX_VALUE;
		}
		
		public function removeAll():void
		{
			while(m_arr.length > 0)
			{
				m_arr.pop();	
			}
		}
		
		public function isEmpty():Boolean
		{
			return m_arr.length == 0;
		}
		
	}
}