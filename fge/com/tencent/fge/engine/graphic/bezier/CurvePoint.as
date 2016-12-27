package com.tencent.fge.engine.graphic.bezier
{
	import flash.geom.Point;
	
	public class CurvePoint extends Point
	{
		public var degrees:Number = 0;
		
		public function CurvePoint(x:Number=0, y:Number=0)
		{
			super(x, y);
		}
	}
}