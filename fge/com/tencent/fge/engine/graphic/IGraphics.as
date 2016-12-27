package com.tencent.fge.engine.graphic
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.IGraphicsData;
	import flash.display.Shader;
	
	import flash.geom.Matrix;
	
	public interface IGraphics
	{
		function beginBitmapFill(bitmap:BitmapData, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false):void;
		function beginFill(color:uint, alpha:Number = 1.0):void;
		function beginGradientFill(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Number = 0):void;
		function beginShaderFill(shader:Shader, matrix:Matrix = null):void;
		
		function clear(): void;
		function copyFrom(sourceGraphics:Graphics):void;
		
		function curveTo(controlX:Number, controlY:Number, anchorX:Number, anchorY:Number):void;
		function drawCircle(x: Number, y: Number, radius: Number): void;
		function drawEllipse(x:Number, y:Number, width:Number, height:Number):void;
		function drawGraphicsData(graphicsData:Vector.<IGraphicsData>):void;
		function drawPath(commands:Vector.<int>, data:Vector.<Number>, winding:String = "evenOdd"):void;
		function drawRect(x: Number, y: Number, width: Number, height: Number): void;
		function drawRoundRect(x:Number, y:Number, width:Number, height:Number, ellipseWidth:Number, ellipseHeight:Number = NaN):void;
		function drawTriangles(vertices:Vector.<Number>, indices:Vector.<int> = null, uvtData:Vector.<Number> = null, culling:String = "none"):void;
		
		function endFill():void;
		function lineBitmapStyle(bitmap:BitmapData, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false):void;
		function lineGradientStyle(type:String, colors:Array, alphas:Array, ratios:Array, matrix:Matrix = null, spreadMethod:String = "pad", interpolationMethod:String = "rgb", focalPointRatio:Number = 0):void;
		function lineShaderStyle(shader:Shader, matrix:Matrix = null):void; 
		function lineStyle(thickness:Number = NaN, color:uint = 0, alpha:Number = 1.0, pixelHinting:Boolean = false, scaleMode:String = "normal", caps:String = null, joints:String = null, miterLimit:Number = 3):void;
		
		function lineTo(x:Number, y:Number):void; 
		function moveTo(x:Number, y:Number):void; 
	}
}