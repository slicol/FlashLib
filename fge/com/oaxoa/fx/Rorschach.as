/**
 * Rorschach Class
 * AS3 Class to mimic animatable Rorschach inkblots
 * 
 * @author		Pierluigi Pesenti
 * @version		0.1
 *
 */

/*
Licensed under the MIT License

Copyright (c) 2009 Pierluigi Pesenti

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

http://blog.oaxoa.com/
*/

package com.oaxoa.fx {
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.filters.BlurFilter;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.geom.ColorTransform;
	import flash.display.BlendMode;
	
	public class Rorschach extends Sprite {	
		public var bd:BitmapData;
		public var bd2:BitmapData;
		public var bd3:BitmapData;
		public var bmp:Bitmap;
		public var halfRect:Rectangle;
		public var rect:Rectangle;
		public var point:Point;
		public var point2:Point;
		public var circularMask:Sprite;
		public var blur:BlurFilter;
		private var offs:Array;
		private var cw:uint;
		private var cw2:uint;
		private var ch:uint;
		private var doMirror:Boolean;
		private var perlinSeed:uint;
		private var showFaceOval:Boolean;
		private var ovalBgColor:uint;
		private var oval:Sprite;
		private var ovalMask:Sprite;
		private var ovalClassReference:Class=null;
		private var ovalScaleFactor:Number;
		private var ovalYOff:Number;
		private var flipMatrix:Matrix;
		private var ink:Sprite;
		private var ct:ColorTransform;
		
		public function Rorschach(w:uint=400, h:uint=400, mirror:Boolean=true, seed:uint=0, ovalClass:Class=null, ovalScale:Number=1, ovalYOffset:Number=0) 
		{
			cw=w;
			ch=h;
			doMirror=mirror;
			perlinSeed=seed;
			ovalClassReference=ovalClass;
			ovalScaleFactor=ovalScale;
			ovalYOff=ovalYOffset;
			
			cw2 = doMirror ? cw/2 : cw;
			
			flipMatrix=new Matrix();
			flipMatrix.scale(-1,1);
			flipMatrix.translate(cw,0);
			
			bd=new BitmapData(cw2, ch, false, 0);
			halfRect=bd.rect;
			point=new Point(0,0);
			bd2=new BitmapData(cw, ch, true, 0);
			bd3=new BitmapData(cw, ch, true, 0);
			rect=bd2.rect;
			bmp=new Bitmap(bd3);
			
			ink=new Sprite();
			ink.addChild(bmp);
			
			if(ovalClassReference) 
			{
				oval=new ovalClassReference() as Sprite;
				ovalMask=new ovalClassReference() as Sprite;
				ovalMask.blendMode=BlendMode.ALPHA;
				var ovalfx:Number=ch/oval.height;
				oval.height=ovalMask.height=ch*ovalScaleFactor;
				oval.width=ovalMask.width=oval.height*ovalfx;
				oval.x=ovalMask.x=cw2;
				oval.y=ovalMask.y=ch/2+ovalYOff;
				addChild(oval);
				
				ink.addChild(ovalMask);
				ink.blendMode=BlendMode.LAYER;
			}
			
			addChild(ink);
			
			circularMask=new Sprite();
			var matrix:Matrix=new Matrix();
			mirror ? matrix.createGradientBox(cw, ch) : matrix.createGradientBox(cw*2, ch);
			circularMask.graphics.beginGradientFill(GradientType.RADIAL, [0,0], [0,1], [168,250], matrix); 
			circularMask.graphics.drawRect(0,0,cw2,ch);
			circularMask.graphics.endFill();
			
			blur=new BlurFilter(2,2,3);
			
			offs=[new Point(0,0), new Point(0,0)];
			addEventListener(Event.ENTER_FRAME, onframe);
		}
		private function onframe(event:Event):void 
		{
			offs[0].x+=cw2/100;
			offs[0].y+=-ch/420;
			offs[1].x+=-cw2/400;
			offs[1].y+=ch/450;
			bd.lock();
			bd2.lock();
			bd.perlinNoise(cw2/2.5, ch/5, 2, perlinSeed, false, true, 7, true, offs);
			bd.draw(circularMask);
			bd2.fillRect(rect, 0x00000000);
			bd2.threshold(bd, halfRect, point, ">", 0x808080, 0xff000000, 0x00ffffff, false);
			if(doMirror) bd2.draw(bd2, flipMatrix, null, null, null);
			bd2.applyFilter(bd2, rect, point, blur);
			bd3.colorTransform(rect, new ColorTransform(1,1,1,.75));
			bd3.draw(bd2);
			bd.unlock();
			bd2.unlock();
		}		
	}
}