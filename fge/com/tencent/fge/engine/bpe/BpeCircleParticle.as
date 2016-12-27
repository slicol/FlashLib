package com.tencent.fge.engine.bpe
{
	public class BpeCircleParticle extends BpeAbstractParticle
	{
		protected var m_radius:Number;
		protected var m_radian:Number;
		
		public function BpeCircleParticle(
			x:Number, y:Number, radius:Number, rotation:Number, isFixed:Boolean, 
			mass:Number, elasticity:Number, friction:Number, 
			colliResolver:IBpeCollisionResolver=null)
		{
			super(x, y, isFixed, mass, elasticity, friction, colliResolver);
			m_radius = radius;
			radian = rotation;
		}

		
		internal override function initialize():void
		{			
			if(BPEngine.DEBUG)
			{
				sprite.graphics.clear();
				sprite.graphics.lineStyle(lineThickness, lineColor, lineAlpha);
				sprite.graphics.beginFill(fillColor, fillAlpha);
				sprite.graphics.drawCircle(0, 0, radius);
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
				
		override public function paint():void 
		{
			sprite.x = curr.x;
			sprite.y = curr.y;	
			sprite.rotation = angle;
		}
		
		
		internal function getProjection(axis:BpeVector):BpeInterval 
		{
			var c:Number = samp.dot(axis);
			interval.min = c - m_radius;
			interval.max = c + m_radius;
			
			return interval;
		}
		

		internal function getIntervalX():BpeInterval
		{
			interval.min = curr.x - m_radius;
			interval.max = curr.x + m_radius;
			return interval;
		}
		
			
		internal function getIntervalY():BpeInterval 
		{
			interval.min = curr.y - m_radius;
			interval.max = curr.y + m_radius;
			return interval;
		}	


		public function get radius():Number 
		{
			return m_radius;
		}		
		
		public function set radius(r:Number):void 
		{
			m_radius = r;
		}
		
		public function get radian():Number 
		{
			return m_radian;
		}
		
		public function set radian(t:Number):void 
		{
			m_radian = t;
		}		
		
		public function get width():Number
		{
			return m_radius * 2
		}
		
		public function get height():Number
		{
			return m_radius * 2
		}		
		
		public function get angle():Number 
		{
			return radian * BpeMathUtil.ONE_EIGHTY_OVER_PI;
		}
			
		public function set angle(a:Number):void 
		{
			radian = a * BpeMathUtil.PI_OVER_ONE_EIGHTY;
		}		
		
	}
}