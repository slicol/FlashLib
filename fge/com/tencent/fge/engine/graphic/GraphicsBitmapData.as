package com.tencent.fge.engine.graphic
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.IGraphicsData;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.geom.Matrix;

	public class GraphicsBitmapData extends BitmapData implements IGraphics
	{
		private var m_gfxImpl: Shape;
		private var m_isFilling: Boolean = false;
		
		public function GraphicsBitmapData(width:int, height:int, transparent:Boolean = true, fillColor:uint = 0xFFFFFFFF)
		{
			super(width, height, transparent, fillColor);
			m_gfxImpl = new Shape();
		}
		
		private function get graphics(): Graphics
		{
			return m_gfxImpl.graphics;
		}
		
		public function beginBitmapFill(bitmap:BitmapData, matrix:Matrix=null, repeat:Boolean=true, smooth:Boolean=false):void
		{
			graphics.beginBitmapFill(bitmap, matrix, repeat, smooth);
			m_isFilling = true;
		}
		
		public function beginFill(color:uint, alpha:Number=1.0):void
		{
			m_isFilling = true;
			graphics.beginFill(color, alpha);
		}
		
		public function beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix=null, spreadMethod:String="pad", interpolationMethod:String="rgb", focalPointRatio:Number=0):void
		{
			m_isFilling = true;
			graphics.beginGradientFill(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
		}
		
		public function beginShaderFill(shader:Shader, matrix:Matrix=null):void
		{
			m_isFilling = true;
			graphics.beginShaderFill(shader, matrix);
		}
		
		public function clear():void
		{
			m_isFilling = false;
			BitmapDataUtil.clear(this);
		}
		
		public function copyFrom(sourceGraphics:Graphics):void
		{
			m_isFilling = false;
			graphics.clear();
			graphics.copyFrom(sourceGraphics);
			captureBitmap();
		}
		
		public function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void
		{
			graphics.curveTo(controlX, controlY, anchorX, anchorY);
			captureBitmap();
		}
		
		public function drawCircle(x: Number, y: Number, radius: Number): void
		{
			graphics.drawCircle(x, y, radius);
			captureBitmap();
		}
		
		public function drawEllipse(x:Number, y:Number, width:Number, height:Number):void
		{
			graphics.drawEllipse(x, y, width, height);
			captureBitmap();
		}
		
		public function drawGraphicsData(graphicsData:Vector.<IGraphicsData>):void
		{
			graphics.drawGraphicsData(graphicsData);
			captureBitmap();
		}
		
		public function drawPath(commands:Vector.<int>, data:Vector.<Number>, winding:String = "evenOdd"):void
		{
			graphics.drawPath(commands, data, winding);
			captureBitmap();
		}
		
		public function drawRect(x: Number, y: Number, width: Number, height: Number): void
		{
			graphics.drawRect(x, y, width, height);
			captureBitmap();
		}
		
		public function drawRoundRect(x:Number, y:Number, width:Number, height:Number, ellipseWidth:Number, ellipseHeight:Number = NaN):void
		{
			graphics.drawRoundRect(x, y, width, height, ellipseWidth, ellipseHeight);
			captureBitmap();
		}
		
		public function drawTriangles(vertices:Vector.<Number>, indices:Vector.<int> = null, uvtData:Vector.<Number> = null, culling:String = "none"):void
		{
			graphics.drawTriangles(vertices, indices, uvtData, culling);
			captureBitmap();
		}
		
		public function endFill():void
		{
			m_isFilling = false;
			graphics.endFill();
			captureBitmap();
		}
		
		public function lineBitmapStyle(bitmap:BitmapData, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false):void
		{
			graphics.lineBitmapStyle(bitmap, matrix, repeat, smooth);
		}
		
		public function lineGradientStyle(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Number = 0):void
		{
			graphics.lineGradientStyle(type, colors, alphas, ratios, matrix, spreadMethod, interpolationMethod, focalPointRatio);
		}
		
		public function lineShaderStyle(shader:Shader, matrix:Matrix = null):void
		{
			graphics.lineShaderStyle(shader, matrix);
		}
		 
		public function lineStyle(thickness:Number = NaN, color:uint = 0, alpha:Number = 1.0, pixelHinting:Boolean = false, scaleMode:String = "normal", caps:String = null, joints:String = null, miterLimit:Number = 3):void
		{
			graphics.lineStyle(thickness, color, alpha, pixelHinting, scaleMode, caps, joints, miterLimit);
		}
		
		public function lineTo(x:Number, y:Number):void
		{
			graphics.lineTo(x, y);
			captureBitmap();
			graphics.moveTo(x, y);
		}
		 
		public function moveTo(x:Number, y:Number):void
		{
			graphics.moveTo(x, y);
		}
		
		private function captureBitmap(): void
		{
			if (!m_isFilling)
			{
				this.draw(m_gfxImpl);
				graphics.clear();
			}
		}
	}
}