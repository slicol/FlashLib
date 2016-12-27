package com.tencent.fge.engine.graphic
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	

	
	public class DrawUtil
	{

		public static function drawSector(
			target:Graphics, x:Number=0,y:Number=0,r:Number=100,
			startFrom:Number = 0, angle:Number=30,
			fillColor:Number=0xff0000, fillAlpha:Number = 0.5,
			lineThickness:Number = 1, lineColor:Number=0xff0000, lineAlpha:Number = 0.5):void
		{
			target.beginFill(fillColor, fillAlpha);
			target.lineStyle(lineThickness, lineColor, lineAlpha);   
			
			target.moveTo(x,y);
			
			angle=(Math.abs(angle)>360)?360:angle;
			
			var n:Number=Math.ceil(Math.abs(angle)/45);
			
			var angleA:Number=angle/n;
			
			angleA=angleA*Math.PI/180;
			
			startFrom=startFrom*Math.PI/180;
			
			target.lineTo(x+r*Math.cos(startFrom),y+r*Math.sin(startFrom));
			
			for(var i:int=1;i<=n;i++)
			{
				startFrom += angleA;
				
				var angleMid:Number=startFrom-angleA/2;
				
				var bx:Number=x+r/Math.cos(angleA/2)*Math.cos(angleMid);
				
				var by:Number=y+r/Math.cos(angleA/2)*Math.sin(angleMid);
				
				var cx:Number=x+r*Math.cos(startFrom);
				
				var cy:Number=y+r*Math.sin(startFrom);
				
				target.curveTo(bx,by,cx,cy);
				
			}
			
			if(angle!=360)
			{
				target.lineTo(x,y);
			}
			
			target.endFill(); 
		}
	}
}