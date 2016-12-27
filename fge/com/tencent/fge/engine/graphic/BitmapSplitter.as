package com.tencent.fge.engine.graphic
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public class BitmapSplitter
	{
		public static const OUT_2DARRAY:int = 2;
		public static const OUT_1DARRAY:int = 1;
		
		public function BitmapSplitter()
		{
		}
		
		public static function splitTo(src:BitmapData, startX:int, startY:int, row:int, col:int, 
			mat:Matrix = null, ctf:ColorTransform = null, outFlag:int = OUT_2DARRAY, trim:Boolean = false):Array
		{
			var lstBmp:Array = new Array;
			var srcW:int = src.width - startX;
			var srcH:int = src.height - startY;
			var w:int = srcW;
			var h:int = srcH;
			var bmp:BitmapData;
			var rcTrim:Rectangle = new Rectangle;
			var rcBound:Rectangle;
			var _mat:Matrix = (mat != null ? mat.clone() : new Matrix());
			
			if(row == 0 || col == 0)
			{
				_mat.tx = startX;
				_mat.ty = startY;
				bmp = new BitmapData(w,h,true,0);
				bmp.draw(src,_mat,ctf);
				lstBmp.push(bmp);
				
				if(trim)
				{
					rcBound = bmp.getColorBoundsRect(0xFF000000,0xFF000000, true);
					rcTrim = rcTrim.union(rcBound);
				}
			} 
			else
			{
				w = srcW / col;
				h = srcH / row;
				var x:int;
				var y:int;
				if(outFlag == OUT_2DARRAY)
				{
					for(y = startY; y < src.height; y += h)
					{
						var lstRow:Array = new Array();
						for(x = startX; x < src.width; x += w)
						{
							_mat.tx = -x;
							_mat.ty = -y;
							bmp = new BitmapData(w,h,true,0);
							bmp.draw(src,_mat,ctf);
							lstRow.push(bmp);
								
							if(trim)
							{
								rcBound = bmp.getColorBoundsRect(0xFF000000,0xFF000000, true);
								rcTrim = rcTrim.union(rcBound);
							}
						}
						lstBmp.push(lstRow);
					}
				}
				else
				{
					for(y = startY; y < src.height; y += h)
					{
						for(x = startX; x < src.width; x += w)
						{
							_mat.tx = -x;
							_mat.ty = -y;
							bmp = new BitmapData(w,h,true,0);
							bmp.draw(src,_mat,ctf);
							lstBmp.push(bmp);
							
							if(trim)
							{
								rcBound = bmp.getColorBoundsRect(0xFF000000,0xFF000000, true);
								rcTrim = rcTrim.union(rcBound);
							}
						}
						
					}
				}
			}
			
			
			if(trim)
			{
				var i:int;
				var j:int;
				var matTrim:Matrix;
				var bmpTrim:BitmapData;
				
				if(outFlag == OUT_2DARRAY)
				{
					var r:int = lstBmp.length;
					for(i = 0; i < r; ++i)
					{
						lstRow = lstBmp[i];
						var c:int = lstRow.length;
						for(j = 0; j < c; ++j)
						{
							bmp = lstRow[j];
							matTrim = new Matrix;
							matTrim.tx = -rcTrim.x;
							matTrim.ty = -rcTrim.y;
							bmpTrim = bmp;
							bmp = new BitmapData(rcTrim.width, rcTrim.height, true, 0);
							bmp.draw(bmpTrim, matTrim);
							lstRow[j] = bmp;					
						}
						
					}
				}
				else
				{
					for(i = 0; i < lstBmp.length; ++i)
					{
						bmp = lstBmp[i];
						matTrim = new Matrix;
						matTrim.tx = -rcTrim.x;
						matTrim.ty = -rcTrim.y;
						bmpTrim = bmp;
						bmp = new BitmapData(rcTrim.width, rcTrim.height, true, 0);
						bmp.draw(bmpTrim, matTrim);
						lstBmp[i] = bmp;
					}
				}
			}
			
			
			return lstBmp;
		}
		
		public static function splitBy(src:BitmapData, startX:int, startY:int, w:int, h:int, 
			mat:Matrix = null, ctf:ColorTransform = null, outFlag:int = OUT_2DARRAY, trim:Boolean = false):Array
		{
			var lstBmp:Array = new Array;
			
			if(null == src)
			{
				return lstBmp;
			}
			
			var srcW:int = src.width - startX;
			var srcH:int = src.height - startY;
			var bmp:BitmapData;
			var rcTrim:Rectangle = new Rectangle;
			var rcBound:Rectangle;
			var _mat:Matrix = (mat != null ? mat.clone() : new Matrix());
			
			var lstRow:Array;
			
			if(w == 0 || h == 0)
			{
				w = srcW;
				h = srcH;
				_mat.tx = startX;
				_mat.ty = startY;
				bmp = new BitmapData(w,h,true,0);
				bmp.draw(src,_mat,ctf);
				lstBmp.push(bmp);
				
				
				if(trim)
				{
					rcBound = bmp.getColorBoundsRect(0xFFFFFFFF, 0x00000000, false);
					rcTrim = rcTrim.union(rcBound);
				}
			} 
			else
			{
				var x:int;
				var y:int;
				if(outFlag == OUT_2DARRAY)
				{
					for(y = startY; y < src.height; y += h)
					{
						lstRow = new Array();
						for(x = startX; x < src.width; x += w)
						{
							_mat.tx = -x;
							_mat.ty = -y;
							bmp = new BitmapData(w,h,true,0);
							bmp.draw(src,_mat,ctf);
							lstRow.push(bmp);
								
							if(trim)
							{
								rcBound = bmp.getColorBoundsRect(0xFFFFFFFF, 0x00000000, false);
								rcTrim = rcTrim.union(rcBound);
							}
						}
						lstBmp.push(lstRow);
					}
				}
				else
				{
					for(y = startY; y < src.height; y += h)
					{
						for(x = startX; x < src.width; x += w)
						{
							_mat.tx = -x;
							_mat.ty = -y;
							bmp = new BitmapData(w,h,true,0);
							bmp.draw(src,_mat,ctf);
							lstBmp.push(bmp);
							
							if(trim)
							{
								rcBound = bmp.getColorBoundsRect(0xFFFFFFFF, 0x00000000, false);
								rcTrim = rcTrim.union(rcBound);
							}
						}
						
					}
				}
			}
			
			
			if(trim)
			{
				var i:int;
				var j:int;
				var matTrim:Matrix;
				var bmpTrim:BitmapData;
				
				if(outFlag == OUT_2DARRAY)
				{
					var r:int = lstBmp.length;
					for(i = 0; i < r; ++i)
					{
						lstRow = lstBmp[i];
						var c:int = lstRow.length;
						for(j = 0; j < c; ++j)
						{
							bmp = lstRow[j];
							matTrim = new Matrix;
							matTrim.tx = -rcTrim.x;
							matTrim.ty = -rcTrim.y;
							bmpTrim = bmp;
							bmp = new BitmapData(rcTrim.width, rcTrim.height, true, 0);
							bmp.draw(bmpTrim, matTrim);
							lstRow[j] = bmp;					
						}
						
					}
				}
				else
				{
					for(i = 0; i < lstBmp.length; ++i)
					{
						bmp = lstBmp[i];
						matTrim = new Matrix;
						matTrim.tx = -rcTrim.x;
						matTrim.ty = -rcTrim.y;
						bmpTrim = bmp;
						bmp = new BitmapData(rcTrim.width, rcTrim.height, true, 0);
						bmp.draw(bmpTrim, matTrim);
						lstBmp[i] = bmp;
					}
				}
			}
			
			
			return lstBmp;			
		}

	}
}