/*
 * Copyright 2007 (c) Tim Knip, ascollada.org.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 
package com.tencent.fge.utils
{
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	/**
	 * 
	 */
	public class FPS extends Sprite {
		
		public var time :Number;
		public var frameTime :Number;
		public var prevFrameTime :Number = getTimer();
		public var secondTime :Number;
		public var prevSecondTime :Number = getTimer();
		public var frames :Number = 0;
		public var fps :String = "...";
	
		public var tf:TextField;
		public var anim:String = "";
		public var bar:Shape;
		
		public var value:int = 0;
		
		/**
		 * 
		 * @return
		 */
		public function FPS():void 
		{
			tf = new TextField();
			addChild(tf);
			tf.x = 0;
			tf.y = 0;
			tf.width = 40;
			tf.height = 20;
			tf.defaultTextFormat = new TextFormat("Arial", 9, 0xffffff);
			tf.alpha = 0.6;
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function enterFrameHandler( event:Event ):void 
		{
			time = getTimer();

			frameTime = time - prevFrameTime;
			secondTime = time - prevSecondTime;
			
			if(secondTime >= 1000) 
			{
				value = frames;
				fps = frames.toString();
				frames = 0;
				prevSecondTime = time;
			}
			else
			{
				frames++;
			}
			
 		 
			prevFrameTime = time;
			tf.text = fps + " FPS ";
		}
	}
	
}
