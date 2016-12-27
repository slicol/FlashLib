package com.tencent.fge.engine.graphic
{
	import flash.geom.Point;

	public class GeometryUtil
	{
		/*---------------------------------------------------------
		*	Func:	getLine
		*	Desc:	using the Bresenham's line algorithm,
		*			(see http://www.cs.helsinki.fi/group/goa/mallinnus/lines/bresenh.html),
		*
		*	Remark:	the simplest expression of this algorithm is:
		*				slope = (y1 - y0)/(x1 - x0);
		*				error = 0; y = y0;
		*				for(x = x0; x <= x1; ++x)
		*				{
		*					visit(x, y);
		*					error += slope;
		*					if(error >= 0.5)
		*					{
		*						y += 1;
		*						error -= 1;
		*					}
		*				}
		*--------------------------------------------------------*/
		public static function getLine(x0:int, y0:int, x1:int, y1:int, skipRate:int = 0):Vector.<Point>
		{
			var x0Orig:int = x0;
			var y0Orig:int = y0;
			var x1Orig:int = x1;
			var y1Orig:int = y1;
			
			var lstTrack:Vector.<Point> = new Vector.<Point>;
			
			//	during each iteration, x always increases or decrease.
			//	in order to increase the prcise,
			//	the line algorithm is always performed on a gentle line but not a steep line
			var steep:Boolean = Math.abs(y1 - y0) > Math.abs(x1 - x0);
			
			var tmp:int;
			if(steep == true)
			{
				//	swap(x0, y0);
				tmp = x0;
				x0 = y0;
				y0 = tmp;
				
				//	swap(x1, y1)
				tmp = x1;
				x1 = y1;
				y1 = tmp;
			}
			
			
			var deltax:int = Math.abs(x1 - x0);
			var deltay:int = Math.abs(y1 - y0);
			
			//	the initial error is 0, because the input start point is exactly on a pixel of the screen.
			//	during each iteration, the error of mathmatical y between the current pixel y increases.
			//	use this variable to indicate this error
			var error:int = 0;
			//	if the error's greater than this error threshold
			//	the pixel y should change (increase or decrease) to the next pixel y
			var errorThreshold:int = deltax / 2;
			
			var y:int = y0;
			
			var ystep:int;
			if(y0 < y1)
			{
				ystep = 1;
			}
			else
			{
				ystep = -1;
			}
			
			var xstep:int;
			if(x0 < x1)
			{
				xstep = 1;
			}
			else
			{
				xstep = -1;
			}
			
			
			
			var visitx:int;
			var visity:int;
			
			lstTrack.push(new Point(x0Orig, y0Orig));
			
			var stepRemaining:int = Math.max(0, deltax + 1);
			var skip:int = skipRate;
			for(var x:int = x0; stepRemaining > 0; x += xstep, --stepRemaining)
			{
				if(steep)
				{
					visitx = y;
					visity = x;
				}
				else
				{
					visitx = x;
					visity = y;
				}
				
				--skip;
				if(0 >= skip)
				{
					skip = skipRate;
					lstTrack.push(new Point(visitx, visity));
				}
				
				
				//	during each iteration,
				//	the error of mathmatical y between the current pixel y increases by delta y
				error = error + deltay;
				
				//	if the error's greater than this error threshold
				if(error > errorThreshold)
				{
					//	the pixel y should change (increase or decrease) to the next pixel y
					y += ystep;
					
					//	and calculate the current error value
					error -= deltax;
				}
			}
			
			lstTrack.push(new Point(x1Orig, y1Orig));
			
			return lstTrack;
		}
	}
}