package com.tencent.fge.engine.graphic.fx
{
	import flash.display.Graphics;

	public class GraphicsNode
	{
		public var graphics:*;
		public var parent:GraphicsNode;
		public var alpha:Number = 1.0;
		public var filters:Array = [];
		public var visible:Boolean = true;
		public var blendMode:String = "";
		
		private var m_lstChild:Array = [];
		
		public function GraphicsNode(graphics:*)
		{
			this.graphics = graphics;
		}
		
		public function addChild(node:GraphicsNode):void
		{
			if(!node)
			{
				return;
			}
			
			if(m_lstChild.indexOf(node) < 0)
			{
				m_lstChild.push(node);
				node.graphics = this.graphics;
				node.parent = this;
			}
		}
		
		public function removeChild(node:GraphicsNode):void
		{
			if(!node)
			{
				return;
			}
			
			var i:int = m_lstChild.indexOf(node);
			if(i >= 0)
			{
				m_lstChild.splice(i, 1);
				node.graphics = null;
				node.parent = null;
			}
		}
		
	}
}