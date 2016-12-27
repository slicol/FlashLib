package com.tencent.fge.engine.bpe
{
		import flash.display.BitmapData;
		import flash.geom.Point;
	
	public class BpeBitmapUtil
	{
	internal static function findBitmapCrossCircle(
		bmp:BitmapData, x:Number, y:Number, r:Number, radBegin:Number,
		toward:int):CircelCrossPoint
	{
		var rad:Number = radBegin;
		var ptCC:CircelCrossPoint = new CircelCrossPoint;
		var clr:uint;
		var PIx2:Number = Math.PI * 2;
		var radEnd:Number;
		var rx:Number = 0;
		var ry:Number = 0;
			
		if(toward == -1)//左
		{
			radEnd = PIx2 + radBegin;
			for(; rad < radEnd; rad += 0.01)
			{
				rx = r * Math.cos(rad) + x;
				ry = -r * Math.sin(rad) + y;
				clr = bmp.getPixel32(rx, ry);
				if(clr != 0)
				{
					ptCC.pt = new Point(rx,ry);
					ptCC.rad = new Number(rad);
					break;
				}
			}
		}
		else if(toward == 1)//右
		{
			radEnd = radBegin - PIx2;
			for(; rad > radEnd; rad -= 0.01)
			{
				rx = r * Math.cos(rad) + x;
				ry = -r * Math.sin(rad) + y;
				clr = bmp.getPixel32(rx, ry);
				if(clr != 0)
				{
					ptCC.pt = new Point(rx,ry);
					ptCC.rad = new Number(rad);
					break;
				}
			}
		}
		
		/*
		for(;rad < PIx2; rad += 0.01)
		{
			var rx:Number = r * Math.cos(rad + beginRad);
			var ry:Number = -r * Math.sin(rad + beginRad);
			clr = bmp.getPixel32(r + rx, r + ry);
			if(clr != 0)
			{
				if(ptDbl.pt1 == null)
				{
					ptDbl.pt1 = new Point(r + rx, r + ry);
					if(rad + beginRad > PIx2)
					{
						ptDbl.rad1 = new Number(rad + beginRad - PIx2);
					}
					else
					{
						ptDbl.rad1 = new Number(rad + beginRad);
					}
				}
			}
			else
			{
				if(ptDbl.pt1 != null)
				{
					ptDbl.pt2 = new Point(r + rx, r + ry);
					if(rad + beginRad > PIx2)
					{
						ptDbl.rad2 = new Number(rad + beginRad - PIx2);
					}
					else
					{
						ptDbl.rad2 = new Number(rad + beginRad);
					}
					break;
				}
			}
			
		}*/
		
		return ptCC;		
	}
	
	
	internal static function findBitmapCrossAxis(bmp:BitmapData, x:int, y:int, angle:Number, checkCallback:Function):Point
	{
		var tx:Number = x;
		var ty:Number = y;
		var d:Number;
		var clr:uint;
		var pt:Point = null;
		if(angle == 0)
		{
			d = bmp.width;
			for(; tx < d; tx += 1)
			{
				clr = bmp.getPixel32(tx,ty);
				if(checkCallback(clr))
				{
					pt = new Point(tx, ty);
					break;
				}
			}
		}
		else if(angle == 90)
		{
			for(; ty > 0; ty -= 1)
			{
				clr = bmp.getPixel32(tx,ty);
				if(checkCallback(clr))
				{
					pt = new Point(tx, ty);
					break;
				}
			}			
		}
		else if(angle == 180)
		{
			for(; tx > 0; tx -= 1)
			{
				clr = bmp.getPixel32(tx,ty);
				if(checkCallback(clr))
				{
					pt = new Point(tx, ty);
					break;
				}
			}
		}
		else if(angle == 270)
		{
			d = bmp.height;
			for(; ty < d; ty += 1)
			{
				clr = bmp.getPixel32(tx,ty);
				if(checkCallback(clr))
				{
					pt = new Point(tx, ty);
					break;
				}
			}	
		}		
		
		if(pt == null)
		{
			var a:int = 0;
		}
		
		return pt;
	}
	
	
    public static function getAngle(bmp:BitmapData, x:Number, y:Number, xBounds:Number, yBounds:Number) : Number
    {
        var lstPt1:Array = null;
        var lstPt2:Array = null;
        var pt1:Point = null;
        var pt2:Point = null;
        var xi:Number = NaN;
        var k:Number = NaN;
        var p:Number = NaN;
        var i:int = 0;
        var j:int = 0;
        var xb:int = xBounds/2;
        var yb:int = yBounds/2;
        if (bmp)
        {
            lstPt1 = new Array();
            lstPt2 = new Array();
            pt1 = new Point();
            pt2 = new Point();
            xi = 1;
            while (xi <= xb)
            {
                
                i = -yb;
                while (i <= yb)
                {
                    if (bmp.getPixel32(x + xi, y + i) != 0)
                    {
                        lstPt1.push(new Point(x + xi, y + i));
                        break;
                    }
                    i = i + 1;
                }
                j = -yb;
                while (j <= yb)
                {
                    
                    if (bmp.getPixel32(x - xi, y + j) != 0)
                    {
                        lstPt2.push(new Point(x - xi, y + j));
                        break;
                    }
                    j = j + 1;
                }
                xi = xi + 1;
            }
            pt1 = new Point(x, y);
            pt2 = new Point(x, y);
            k = 0;
            while (k < lstPt1.length)
            {
                
                pt1 = pt1.add(lstPt1[k]);
                k = k + 1;
            }
            p = 0;
            while (p < lstPt2.length)
            {
                
                pt2 = pt2.add(lstPt2[p]);
                p = p + 1;
            }
            pt1.x = pt1.x / (lstPt1.length + 1);
            pt1.y = pt1.y / (lstPt1.length + 1);
            pt2.x = pt2.x / (lstPt2.length + 1);
            pt2.y = pt2.y / (lstPt2.length + 1);
            
            var angle:Number = Math.atan2(pt1.y - pt2.y, pt1.x - pt2.x);
            angle = -angle;
            
            if(angle < 0) angle = Math.PI + angle;

            return angle;
        }
        else
        {
            return 0;
        }
    }	
    
 
	}
}
	import flash.geom.Point;
	



class CircelCrossPoint
{
	public var pt:Point;
	public var rad:Number;
}

