package com.tencent.fge.engine.animation
{
	import com.tencent.fge.engine.animation.AnimationEvent;
	import com.tencent.fge.engine.graphic.BitmapSplitter;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;


	[Event(name="playEnd", type="com.tencent.fge.engine.animation.AnimationEvent")]
	public class FrameAnimation extends Bitmap
	{	
		private var m_bitmapData:BitmapData;
		private var m_frameList:Array;
		private var m_frameIndex:Number = 0;
		private var m_frameW:int;
		private var m_frameH:int;
		private var m_frameRow:int;
		private var m_frameCol:int;
		private var m_cleanList:Boolean = true;
		private var m_loop:Boolean = true;
		private var m_trim:Boolean = false;
		
		private var m_speed:Number = 1;
		private var m_smoothing:Boolean = false;
		
		public function FrameAnimation(fraW:int, fraH:int, 
			bitmapData:BitmapData=null, smoothing:Boolean=false, trim:Boolean = false)
		{
			super(null);
			this.m_trim = trim;
			this.smoothing = smoothing;
			this.bitmapData = bitmapData;
			this.width = fraW;
			this.height = fraH;
			m_smoothing = smoothing;
			
		}
		
		public function setBitmapRowCol(r:int,c:int):void
		{
			if(r == 0 || c == 0) return;
			m_frameRow = r;
			m_frameCol = c;			
			cleanFrameList();
			splitTo();
		}
		
		override public function set bitmapData(value:BitmapData):void
		{
			if(m_bitmapData == value) return;
			cleanFrameList();
			m_cleanList = true;
			m_bitmapData = value;
			splitBy();
		}
		
		public function set speed(value:Number):void
		{
			m_speed = value;
		}
		
		public function get speed():Number
		{
			return m_speed;
		}
		
		
		
		override public function get bitmapData():BitmapData
		{
			return m_bitmapData;
		}
		
		public function get frameBitmapData():BitmapData
		{
			return super.bitmapData;
		}
		
		public function setFrameList(frameList:Array, cleanList:Boolean = false):void
		{
			clean();
			m_cleanList = cleanList;
			m_frameList = frameList;
		}
		
		public function getFrameList():Array
		{
			return m_frameList;
		}
		
		public function clean():void
		{
			cleanFrameList();
			m_bitmapData = null;
			stop();
		}

		
		public function play(loop:Boolean = true):void
		{
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			m_loop = loop;
		}
		
		public function stop():void
		{
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public function gotoAndStop(frame:Object):void
		{
			stop();
			if(m_frameList == null) return;
			m_frameIndex = frame as int;
			if(m_frameIndex >= m_frameList.length) 
			{
				m_frameIndex = m_frameList.length - 1;
			}
			super.bitmapData = m_frameList[m_frameIndex];
		}
		
		public function gotoAndPlay(frame:Object):void
		{
			if(m_frameList == null) return;
			m_frameIndex = frame as int;
			if(m_frameIndex >= m_frameList.length) 
			{
				m_frameIndex = m_frameList.length - 1;
			}
			play();
		}
		
		public function framesLoaded():int
		{
			if(m_frameList == null) return 0;
			return m_frameList.length;
		}
		
		override public function set width(value:Number):void
		{
			if(m_frameW == value || value == 0) return;
			//super.width = value;
			m_frameW = value;
			cleanFrameList();
			splitBy();
		}
		
		override public function set height(value:Number):void
		{
			if(m_frameH == value || value == 0) return;
			//super.height = value;
			m_frameH = value;
			cleanFrameList();
			splitBy();
		}
		
		override public function get width():Number{return m_frameW;}
		override public function get height():Number{return m_frameH;}
		
		private function splitBy():Boolean
		{
			if(m_bitmapData != null && m_frameW >= 1 && m_frameH >= 1)
			{
				m_frameList = BitmapSplitter.splitBy(m_bitmapData, 
					0,0,m_frameW,m_frameH,
					null, null,BitmapSplitter.OUT_1DARRAY);
				m_frameCol = m_bitmapData.width / m_frameW;
				m_frameRow = m_bitmapData.height / m_frameH;
				
				if(m_trim)
				{
					trimFrame();
				}
				
				return true;
			}
			return false;
		}
		
		private function splitTo():Boolean
		{
			if(m_bitmapData != null && m_frameRow >= 1 && m_frameCol >= 1)
			{
				m_frameList = BitmapSplitter.splitTo(m_bitmapData, 
					0,0,m_frameRow,m_frameCol,
					null, null,BitmapSplitter.OUT_1DARRAY);
				m_frameW = m_bitmapData.width / m_frameCol;
				m_frameH = m_bitmapData.height / m_frameRow;
				
				if(m_trim)
				{
					trimFrame();
				}
				
				return true;
			}
			return false;
		}
		
		private function trimFrame():void
		{
			var max:Rectangle = new Rectangle;
			var bmp:BitmapData;
			var i:int = 0;
			for(i = 0; i < m_frameList.length; ++i)
			{
				bmp = m_frameList[i];
				var rc:Rectangle;
				rc = bmp.getColorBoundsRect(0xFF000000,0xFF000000, true);
				max = max.union(rc);
			}
			
			for(i = 0; i < m_frameList.length; ++i)
			{
				bmp = m_frameList[i];
				var mat:Matrix = new Matrix;
				var tmp:BitmapData;
				mat.tx = -max.x;
				mat.ty = -max.y;
				tmp = bmp;
				bmp = new BitmapData(max.width, max.height, true, 0);
				bmp.draw(tmp, mat);
				m_frameList[i] = bmp;
			}
			
			this.m_frameH = max.height;
			this.m_frameW = max.width;
		}
		
		private function cleanFrameList():void
		{
			if(m_cleanList && m_frameList != null)
			{
				for(var i:int = 0; i < m_frameList.length; ++i)
				{
					var bmp:BitmapData = m_frameList[i];
					if(bmp) bmp.dispose();
				}
			}
			m_frameList = [];
		}
		
		private function processLastFrame():void
		{
			if(!m_loop)
			{
				stop();
			}
			m_frameIndex = 0;
			var e:AnimationEvent = 
				new AnimationEvent(AnimationEvent.PLAY_END);
			this.dispatchEvent(e);
		}
		
		/*---------------------------------------------------------
		*	Getter: currentFrame
		*--------------------------------------------------------*/
		public function get currentFrame():int { return m_frameIndex; }
		 
		private function onEnterFrame(e:Event):void
		{
			if(m_frameList == null)
			{
				stop();
				return;
			}
			
			super.bitmapData = m_frameList[int(m_frameIndex)];
			this.smoothing = m_smoothing;
			m_frameIndex += m_speed;
			if(m_frameIndex >= m_frameList.length)
			{
				processLastFrame();
			}			
		}
		
		
	}
}