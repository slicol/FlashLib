package com.tencent.fge.engine.graphic.bezier
{
	import flash.geom.Point;

	public class BezierPoint
	{
		public var c:Point; //锚点，中心点
		public var l:Point; //左控制点
		public var r:Point; //右控制点
		
		public function BezierPoint(x:Number, y:Number) 
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
		
		public function clone():BezierPoint
		{
			var bp:BezierPoint = new BezierPoint(c.x,c.y);
			bp.l.x = l.x;
			bp.l.y = l.y;
			bp.r.x = r.x;
			bp.r.y = r.y;
			return bp;
		}
		
		public function offset(dx:Number, dy:Number):void
		{
			c.offset(dx, dy);
			l.offset(dx, dy);
			r.offset(dx, dy);
		}
		
		public static function mirror(dst:Point, c:Point, src:Point, f:Number = -1):void
		{
			if(f == -1)
			{
				if(Math.abs(c.x - src.x) < 1)
				{
					if(Math.abs(c.y - src.y) < 1)
					{
						return;
					}
					else
					{
						f = (dst.y - src.y)/(c.y - src.y);
					}
				}
				else
				{
					f = (dst.x - src.x)/(c.x - src.x);
				}
			}

			
			var pt:Point = Point.interpolate(c, src, f);
			dst.x = pt.x;
			dst.y = pt.y;
		}
		
		public function mirrorL2R(f:Number = -1):void
		{
			mirror(r,c,l,f);
		}
		
		public function mirrorR2L(f:Number = -1):void
		{
			mirror(l,c,r,f);
		}
		
		public function toString():String
		{ 
			return ("[c:" + c.toString() + "l:" + l.toString() + "r:" + r.toString() + "]"); 
		} 
	}
}