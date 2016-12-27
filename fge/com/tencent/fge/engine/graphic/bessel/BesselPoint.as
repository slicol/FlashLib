package com.tencent.fge.engine.graphic.bessel
{
	import flash.geom.Point; 
	public class BesselPoint
	{
		public var c:Point; 
		public var l:Point; 
		public var r:Point; 
		
		public function BesselPoint(x:Number, y:Number) 
		{ 
			init(x, y); 
		} 
		
		private function init(x:Number, y:Number):void 
		{ 
			var point:Point = new Point(x, y); 
			c = point.clone(); 
			l = point.clone(); 
			r = point.clone(); 
		} 
		
		public function clone():BesselPoint
		{
			var bp:BesselPoint = new BesselPoint(c.x,c.y);
			bp.l.x = l.x;
			bp.l.y = l.y;
			bp.r.x = r.x;
			bp.r.y = r.y;
			return bp;
		}
		
		public function toString():String
		{ 
			return ("c:" + c.toString() + "l:" + l.toString() + "r:" + r.toString()); 
		} 
	}

} 

