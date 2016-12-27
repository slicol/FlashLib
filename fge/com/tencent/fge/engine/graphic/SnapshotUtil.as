package com.tencent.fge.engine.graphic
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class SnapshotUtil
	{

		
		public static function snapshot(disp:DisplayObject, trim:Boolean = false):BitmapData
		{
			if(disp == null)
			{
				return null;
			}
			
			var mat:Matrix;
			var rc:Rectangle;
			var bmp:BitmapData;
			var tmp:BitmapData;
			
			mat = new Matrix;
			rc = disp.getBounds(disp);
			mat.tx = -rc.x;
			mat.ty = -rc.y;
			bmp = new BitmapData(rc.width, rc.height, true, 0);
			bmp.draw(disp, mat);
			
			if(trim)
			{
				rc = bmp.getColorBoundsRect(0xFF000000,0xFF000000, true);
				mat.tx = -rc.x;
				mat.ty = -rc.y;
				tmp = bmp;
				bmp = new BitmapData(rc.width, rc.height, true, 0);
				bmp.draw(tmp, mat);
			}
			
			return bmp;
		}
		
		public static function snapshotRect(disp:DisplayObject, rt:Rectangle):BitmapData
		{
			if(disp == null)
			{
				return null;
			}
			
			if(rt == null)
			{
				return snapshot(disp);
			}
			
			var mat:Matrix;
			var bmp:BitmapData;
			var tmp:BitmapData;
			
			mat = new Matrix;
			mat.translate(-rt.x, -rt.y);
			bmp = new BitmapData(rt.width, rt.height, true, 0);
			bmp.draw(disp, mat);

			return bmp;
		}
		
		
		public static function snapshotTo(disp:DisplayObject, rect:Rectangle, output:BitmapData):Boolean
		{
			if(disp == null || output == null)
			{
				return false;
			}
			
			if(rect == null)
			{
				rect = disp.getBounds(disp);
			}
			
			var mat:Matrix;
			
			mat = new Matrix;
			mat.translate(-rect.x, -rect.y);
			mat.scale(output.width/rect.width,output.height/rect.height);
			
			
			
			output.draw(disp, mat, null, null);
			
			return true;
		}
		
		
		public static function snapshotScaleToRect(disp: DisplayObject, rt: Rectangle):BitmapData
		{
			if(disp == null)
			{
				return null;
			}
			
			var mat:Matrix;
			var bmp:BitmapData;
			var tmp:BitmapData;
			
			mat = new Matrix;
			mat.translate(-rt.x, -rt.y);
			mat.scale(0.2, 0.2);
			bmp = new BitmapData(rt.width, rt.height, true, 0);
			bmp.draw(disp, mat);
			
			return bmp;
		}
		
	}
}