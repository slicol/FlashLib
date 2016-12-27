package com.tencent.fge.engine.bpe
{
	import flash.geom.Point;
	
	
	public class BpeVector 
	{
		
		public var x:Number;
		public var y:Number;
		
		public function clone():BpeVector
		{
			return new BpeVector(x,y);
		}
		
		public function copyPoint(pt:Point):void
		{
			x = pt.x;
			y = pt.y;
		}
		
		public function copyAngle(angle:Number):void
		{
			var rad:Number = (angle/180.0) * Math.PI;
			x = Math.cos(rad);
			y = -Math.sin(rad);
		}
		
		public function copyRadian(rad:Number):void
		{
			x = Math.cos(rad);
			y = -Math.sin(rad);
		}

		
		public function BpeVector(px:Number = 0, py:Number = 0) 
		{
			x = px;
			y = py;
		}
		
		
		public function setTo(px:Number, py:Number):void 
		{
			x = px;
			y = py;
		}
		
		
		public function copy(v:BpeVector):void 
		{
			x = v.x;
			y = v.y;
		}
		
		
		public function dot(v:BpeVector):Number 
		{
			return x * v.x + y * v.y;
		}
		
		
		public function cross(v:BpeVector):Number 
		{
			return x * v.y - y * v.x;
		}
		
		
		public function plus(v:BpeVector):BpeVector 
		{
			return new BpeVector(x + v.x, y + v.y); 
		}
		
		
		public function plusEquals(v:BpeVector):BpeVector 
		{
			x += v.x;
			y += v.y;
			return this;
		}
		
		
		public function minus(v:BpeVector):BpeVector 
		{
			return new BpeVector(x - v.x, y - v.y);    
		}
		
		
		public function minusEquals(v:BpeVector):BpeVector 
		{
			x -= v.x;
			y -= v.y;
			return this;
		}
		
		
		public function mult(s:Number):BpeVector 
		{
			return new BpeVector(x * s, y * s);
		}
		
		
		public function multEquals(s:Number):BpeVector 
		{
			x *= s;
			y *= s;
			return this;
		}
		
		
		public function times(v:BpeVector):BpeVector 
		{
			return new BpeVector(x * v.x, y * v.y);
		}
		
		
		public function divEquals(s:Number):BpeVector 
		{
			if (s == 0) s = 0.0001;
			x /= s;
			y /= s;
			return this;
		}
		
		
		public function magnitude():Number 
		{
			return Math.sqrt(x * x + y * y);
		}
		
		
		public function distance(v:BpeVector):Number 
		{
			var delta:BpeVector = this.minus(v);
			return delta.magnitude();
		}
		
		
		public function normalize():BpeVector 
		{
			var m:Number = magnitude();
			if (m == 0) m = 0.0001;
			return mult(1 / m);
		}
		
		public function equalZero():Boolean
		{
			return x == 0 && y == 0;
		}
		
		public function toString():String 
		{
			return (x + " : " + y);
		}
	}
}