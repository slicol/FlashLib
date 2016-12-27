package com.tencent.fge.engine.graphic
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class BitmapDataUtil
	{
		public static const SCALETO_RIGHTTOP: String = "RT";
		public static const SCALETO_RIGHTBOTTOM: String = "RB";
		public static const SCALETO_LEFTTOP: String = "LT";
		public static const SCALETO_LEFTBOTTOM: String = "LB";
		public static const SCALETO_CENTER: String = "C";
		
		public static function slide(bmpData: BitmapData, dx: int, dy: int): void
		{
			bmpData.scroll(dx, dy);
			
			var rcErase: Rectangle = new Rectangle();
			
			//for dx
			if (dx < 0)
			{
				rcErase.x = bmpData.width + dx;
				rcErase.y = 0;
				rcErase.width = -dx;
				rcErase.height = bmpData.height;
			}
			else if (dx > 0)
			{
				rcErase.x = 0;
				rcErase.y = 0;
				rcErase.width = dx;
				rcErase.height = bmpData.height;
			}
			bmpData.fillRect(rcErase, 0xffffff);
			
			//for dy
			if (dy < 0)
			{
				rcErase.x = 0;
				rcErase.y = bmpData.height + dy;
				rcErase.width = bmpData.width;
				rcErase.height = -dy;
			}
			else if (dx > 0)
			{
				rcErase.x = 0;
				rcErase.y = 0;
				rcErase.width = bmpData.width;
				rcErase.height = dy;
			}
			bmpData.fillRect(rcErase, 0xffffff);
		}
		
		public static function scale(bmpData: BitmapData, sx: Number, sy: Number, scaleTo: String): void
		{
			//区分拉伸到哪个角落
			var matrix: Matrix = new Matrix();
			switch (scaleTo)
			{
				case SCALETO_LEFTTOP:
					matrix.scale(sx, sy);
					break;
				case SCALETO_LEFTBOTTOM:
					matrix.translate(0, -bmpData.height);
					matrix.scale(sx, sy);
					matrix.translate(0, bmpData.height);
					break;
				case SCALETO_RIGHTTOP:
					matrix.translate(-bmpData.width, 0);
					matrix.scale(sx, sy);
					matrix.translate(bmpData.width, 0);
					break;
				case SCALETO_RIGHTBOTTOM:
					matrix.translate(-bmpData.width, -bmpData.height);
					matrix.scale(sx, sy);
					matrix.translate(bmpData.width, bmpData.height);
					break;
				case SCALETO_CENTER:
					matrix.translate(-bmpData.width / 2, -bmpData.height / 2);
					matrix.scale(sx, sy);
					matrix.translate(bmpData.width / 2, bmpData.height / 2);
					break;
			}
			
			//截图
			var temp: BitmapData = bmpData.clone();
			clear(bmpData);
			bmpData.draw(temp, matrix);
			temp.dispose();
		}
		
		public static function clear(bmpData: BitmapData): void
		{
			bmpData.fillRect(bmpData.rect, 0x00ffffff);
		}
		
		public static function isValidSize(w:int, h:int):Boolean
		{
			if(0 < w && 0 < h && 8191 >= w && 8191 >= h && 16777215 >= w * h)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
	}
}