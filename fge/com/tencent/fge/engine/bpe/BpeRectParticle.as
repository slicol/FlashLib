package com.tencent.fge.engine.bpe
{
	public class BpeRectParticle extends BpeAbstractParticle 
	{
		protected var m_extents:Array;
		protected var m_axes:Array;
		protected var m_radian:Number;

		public function BpeRectParticle (
			x:Number, 
			y:Number, 
			width:Number, 
			height:Number, 
			rotation:Number = 0, 
			fixed:Boolean = false,
			mass:Number = 1, 
			elasticity:Number = 0.3,
			friction:Number = 0,
			colliResolver:IBpeCollisionResolver=null) 
		{
			super(x, y, fixed, mass, elasticity, friction, colliResolver);
			
			m_extents = new Array(width/2, height/2);
			m_axes = new Array(new BpeVector(0,0), new BpeVector(0,0));
			radian = rotation;
		}
		
		public function get radian():Number 
		{
			return m_radian;
		}
		
		public function set radian(t:Number):void 
		{
			m_radian = t;
			setAxes(t);
		}
		
		public function get angle():Number 
		{
			return radian * BpeMathUtil.ONE_EIGHTY_OVER_PI;
		}
			
		public function set angle(a:Number):void 
		{
			radian = a * BpeMathUtil.PI_OVER_ONE_EIGHTY;
		}
					
		internal override function initialize():void 
		{
			if(BPEngine.DEBUG)
			{
				var w:Number = extents[0] * 2;
				var h:Number = extents[1] * 2;
				
				sprite.graphics.clear();
				sprite.graphics.lineStyle(lineThickness, lineColor, lineAlpha);
				sprite.graphics.beginFill(fillColor, fillAlpha);
				sprite.graphics.drawRect(0, 0, w, h);
				sprite.graphics.endFill();
			}
			
			/*
			if(displayObject != null)
			{
				initDisplay();
			}
			*/
			
			paint();
		}
		
		
		public override function paint():void 
		{
			sprite.x = curr.x;
			sprite.y = curr.y;
			sprite.rotation = angle;
		}
		
		
		public function set width(w:Number):void
		{
			m_extents[0] = w/2;
		}
		
		
		public function get width():Number
		{
			return m_extents[0] * 2
		}
		
		
		public function set height(h:Number):void
		{
			m_extents[1] = h / 2;
		}
		
		
		public function get height():Number
		{
			return m_extents[1] * 2
		}
		
		
		internal function get axes():Array 
		{
			return m_axes;
		}
		
		internal function get extents():Array 
		{
			return m_extents;
		}
		
		internal function getProjection(axis:BpeVector):BpeInterval 
		{
			
			var radius:Number =
				extents[0] * Math.abs(axis.dot(axes[0]))+
				extents[1] * Math.abs(axis.dot(axes[1]));
			
			var c:Number = samp.dot(axis);
			
			interval.min = c - radius;
			interval.max = c + radius;
			return interval;
		}
		
				
		private function setAxes(t:Number):void 
		{
			var s:Number = Math.sin(t);
			var c:Number = Math.cos(t);
			
			axes[0].x = c;
			axes[0].y = s;
			axes[1].x = -s;
			axes[1].y = c;
		}
	}
}