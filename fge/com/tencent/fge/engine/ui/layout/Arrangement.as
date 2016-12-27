package com.tencent.fge.engine.ui.layout
{
	import com.tencent.fge.utils.KeyArray;
	
	public class Arrangement
	{
		private var m_lstObject:Array = new Array;
		private var m_maxRow:int = 1
		private var m_maxCol:int = 1
		private var m_gapRow:int = 0
		private var m_gapCol:int = 0
		private var m_beginX:Number = 0;
		private var m_beginY:Number = 0;
		
		private var m_lastBeginIndex:int = 0;
		private var m_beginIndex:int = 0;
		private var m_needUpdateLayout:Boolean = false;
		
		private var m_width:Number = 20;
		private var m_height:Number = 20;
		
		public function Arrangement()
		{
			
		}
		
		public function get x():Number{return m_beginX;}
		public function set x(value:Number):void
		{
			if(m_beginX == value) return;
			m_beginX = value;
			updateLayout();
		}
		
		public function get y():Number{return m_beginY;}
		public function set y(value:Number):void
		{
			if(m_beginY == value) return;
			m_beginY = value;
			updateLayout();
		}
		
		public function get width():Number{return m_width;}
		public function get height():Number{return m_height;}
		
		
		
		public function setArrangePos(x:int, y:int):void
		{
			m_beginX = x;
			m_beginY = y;
			updateLayout();
		}
		
		public function setArrangeGap(row:int,col:int):void
		{
			m_gapRow = row;
			m_gapCol = col;
			updateLayout();
		}
		
		public function setArrangeMat(row:int,col:int):void
		{
			m_maxRow = row;
			m_maxCol = col;
			updateLayout();
		}
		
		public function get pageSize():int
		{return m_maxRow*m_maxCol;}
		
		public function get realSize():int
		{return m_lstObject.length;}
		
		public function scrollLeft():void
		{
			m_beginIndex -= m_maxRow;
			updateLayout(m_maxRow);
		}
		
		public function scrollRight():void
		{
			m_beginIndex += m_maxRow;
			updateLayout(m_maxRow);
		}
		
		public function scrollDown():void
		{
			m_beginIndex += m_maxCol;
			updateLayout(m_maxCol);
		}
		
		public function scrollUp():void
		{
			m_beginIndex -= m_maxCol;
			updateLayout(m_maxCol);
		}
		
		public function pageHome():void
		{
			m_beginIndex = 0;
			updateLayout(0);
		}
		
		public function pageDown():void
		{
			m_beginIndex += pageSize;
			updateLayout(pageSize);
		}
		
		public function pageUp():void
		{
			m_beginIndex -= pageSize;
			updateLayout(pageSize);
		}
		
		
		public function hasLayoutObject(o:ILayoutObject):Boolean
		{
			return m_lstObject.indexOf(o) >= 0;
		}
			
		
		public function addLayoutObject(o:ILayoutObject, priority:int = 0):Boolean
		{
			var i:int = m_lstObject.indexOf(o);
			
			if(i >= 0)
			{
				if(priority != 0 && o.priority != priority)
				{
					o.priority = priority;
					m_lstObject.sortOn("priority");
					updateLayout();
				}
				return false;			
			}
			else
			{
				if(priority != 0) o.priority = priority;
				m_lstObject.push(o);
				m_lstObject.sortOn("priority");
				updateLayout();
				return true;
			}
			
		}
		
		public function removeLayoutObject(o:ILayoutObject):void
		{
			var i:int = m_lstObject.indexOf(o);
			if(i >= 0)
			{
				m_lstObject.splice(i,1);
				updateLayout();
			}		
		}

		
		private function updateLayout(rollback:int = 0):void
		{
			m_needUpdateLayout = true;
			if(m_beginIndex <= 0)
			{
				m_beginIndex = 0;
			}
			if(m_beginIndex >= m_lstObject.length)
			{
				m_beginIndex -= rollback;
			}
			
			if(m_beginIndex == m_lastBeginIndex)
			{
				return;
			}
			m_lastBeginIndex = m_beginIndex;
		}
		
		
		public function update():void
		{
			if(m_needUpdateLayout)
			{
				m_needUpdateLayout = false;
				updateLayoutWorker();
			}
		}
		
		private function updateLayoutWorker():void
		{	
			var endIndex:int = m_beginIndex + pageSize - 1;
			if(endIndex >= m_lstObject.length)
			{
				endIndex = m_lstObject.length - 1;
			}

			
			var i:int = 0;
			var o:ILayoutObject;
			for(; i < m_beginIndex; ++i)
			{
				o = m_lstObject[i];
				o.visible = false;
			}
			
			var tmpW:Number = 0;
			var tmpH:Number = 0;
			
			var xNext:int = m_beginX + m_gapCol;
			var yNext:int = m_beginY + m_gapRow;
			var maxRowHeight:int = 0;
			
			m_width = m_gapCol;
			m_height = m_gapRow;
			
			for(var j:int = 1; i <= endIndex; ++i,++j)
			{
				var row:int = j / m_maxCol;
				var col:int = j % m_maxCol;
				o = m_lstObject[i];
				o.x = xNext;
				o.y = yNext;
				
				if(o.height > maxRowHeight)
				{
					maxRowHeight = o.height;
				}
				
				if(j % m_maxCol == 0)
				{
					tmpW = xNext - m_beginX + o.width + m_gapCol;
					xNext = m_beginX + m_gapCol;
					
					yNext = yNext + maxRowHeight + m_gapRow;
					tmpH = yNext - m_beginY;
					
					maxRowHeight = 0;
				}
				else
				{
					xNext = xNext + o.width + m_gapCol;
					
					
					tmpW = xNext - m_beginX;
					tmpH = yNext - m_beginY + maxRowHeight + m_gapRow;
				}
				
				if(m_width < tmpW) m_width = tmpW;
				if(m_height < tmpH) m_height = tmpH;
			}
			
			for(; i < m_lstObject.length; ++i)
			{
				o = m_lstObject[i];
				o.visible = false;
			}
			
			
			if(endIndex == -1)
			{
				m_width = m_gapCol;
				m_height = m_gapRow;
			}
			
			

		}
	}
}