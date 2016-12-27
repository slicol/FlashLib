package slicol.starling.sdk.core
{
	import flash.display.MovieClip;
	import flash.media.Sound;
	
	import slicol.starling.sdk.core.i.FlItem;
	
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;

	public class FlMovieClip extends Sprite implements FlItem, IAnimatable
	{
		protected var m_xmlFlDefine:XML;
		protected var m_lib:FlLibrary;
		
		private var m_timeline:Vector.<FlFrame>;
		private var m_sounds:Vector.<Sound>;
		private var m_durations:Vector.<Number>;
		private var m_startTimes:Vector.<Number>;
		
		private var m_defaultFrameDuration:Number;
		private var m_currentTime:Number;
		private var m_currentFrame:int;
		private var m_bLoop:Boolean;
		private var m_bPlaying:Boolean;

		
		private var m_currentFrameElt:FlFrame;

		
		public function FlMovieClip(xmlFlDefine:XML, lib:FlLibrary, fps:Number = 60)
		{
			super();
			
			m_xmlFlDefine = xmlFlDefine;
			m_lib = lib;
			
			var xlFrames:XMLList = m_xmlFlDefine.Timeline..Frame;
			var numFrames:int = xlFrames.length();
			
			//todo
			fps = 24;
			
			m_defaultFrameDuration = 1.0 / fps;
			m_bLoop = true;
			m_bPlaying = true;
			m_currentTime = 0.0;
			m_currentFrame = 0;
	
			m_sounds = new Vector.<Sound>(numFrames);
			m_durations = new Vector.<Number>(numFrames);
			m_startTimes = new Vector.<Number>(numFrames);
			
			m_timeline = new Vector.<FlFrame>;

			for (var i:int=0; i<numFrames; ++i)
			{
				m_durations[i] = m_defaultFrameDuration;
				m_startTimes[i] = i * m_defaultFrameDuration;
	
				var xmlFrame:XML = xlFrames[i];
				var frame:FlFrame = new FlFrame(xmlFrame, lib, this);
				m_timeline.push(frame);
			}
			
			
			updateFrameElement(m_timeline[m_currentFrame]);
			
			
			Starling.juggler.add(this);
		}
		
		override public function dispose():void
		{
			this.removeFromParent();
			
			var i:int = 0;
			
			for(i = 0; i < m_timeline.length; ++i)
			{
				m_timeline[i].dispose();
			}
			m_timeline.length = 0;
			
			Starling.juggler.remove(this);
			super.dispose();
		}
		
		private function updateFrameElement(frame:FlFrame):void
		{
			if(m_currentFrameElt)
			{
				m_currentFrameElt.deactive();
			}
			
			m_currentFrameElt = frame;
			m_currentFrameElt.active();
		}
		

		public function getFrameSound(frameID:int):Sound
		{
			if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
			return m_sounds[frameID];
		}
		
		public function setFrameSound(frameID:int, sound:Sound):void
		{
			if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
			m_sounds[frameID] = sound;
		}
		
		public function getFrameDuration(frameID:int):Number
		{
			if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
			return m_durations[frameID];
		}
		
		public function setFrameDuration(frameID:int, duration:Number):void
		{
			if (frameID < 0 || frameID >= numFrames) throw new ArgumentError("Invalid frame id");
			m_durations[frameID] = duration;
			updateStartTimes();
		}
		
		// playback methods
		public function play(bLoop:Boolean = true):void
		{
			m_bLoop = bLoop;
			m_bPlaying = true;
		}
		
		public function pause():void
		{
			m_bPlaying = false;
		}
		
		public function stop():void
		{
			m_bPlaying = false;
			currentFrame = 0;
		}
		
		// helpers
		
		private function updateStartTimes():void
		{
			var numFrames:int = this.numFrames;
			
			m_startTimes.length = 0;
			m_startTimes[0] = 0;
			
			for (var i:int=1; i<numFrames; ++i)
			{
				m_startTimes[i] = m_startTimes[int(i-1)] + m_durations[int(i-1)];
			}
		}
		
		// IAnimatable
		
		/** @inheritDoc */
		public function advanceTime(passedTime:Number):void
		{
			if (!m_bPlaying || passedTime <= 0.0) return;
			
			var finalFrame:int;
			var previousFrame:int = m_currentFrame;
			var restTime:Number = 0.0;
			var breakAfterFrame:Boolean = false;
			var hasCompleteListener:Boolean = hasEventListener(Event.COMPLETE); 
			var dispatchCompleteEvent:Boolean = false;
			var totalTime:Number = this.totalTime;
			
			if (m_bLoop && m_currentTime >= totalTime)
			{ 
				m_currentTime = 0.0; 
				m_currentFrame = 0; 
			}
			
			if (m_currentTime < totalTime)
			{
				m_currentTime += passedTime;
				finalFrame = m_timeline.length - 1;
				
				while (m_currentTime > m_startTimes[m_currentFrame] + m_durations[m_currentFrame])
				{
					if (m_currentFrame == finalFrame)
					{
						if (m_bLoop && !hasCompleteListener)
						{
							m_currentTime -= totalTime;
							m_currentFrame = 0;
						}
						else
						{
							breakAfterFrame = true;
							restTime = m_currentTime - totalTime;
							dispatchCompleteEvent = hasCompleteListener;
							m_currentFrame = finalFrame;
							m_currentTime = totalTime;
						}
					}
					else
					{
						m_currentFrame++;
					}
					
					var sound:Sound = m_sounds[m_currentFrame];
					if (sound) sound.play();
					if (breakAfterFrame) break;
				}
				
				// special case when we reach *exactly* the total time.
				if (m_currentFrame == finalFrame && m_currentTime == totalTime)
				{
					dispatchCompleteEvent = hasCompleteListener;
				}
			}
			
			if (m_currentFrame != previousFrame)
			{
				updateFrameElement(m_timeline[m_currentFrame]);
			}
			
			if (dispatchCompleteEvent)
			{
				dispatchEventWith(Event.COMPLETE);
			}
			
			if (m_bLoop && restTime > 0.0)
			{
				advanceTime(restTime);
			}
		}
		
		public function get isComplete():Boolean 
		{
			return !m_bLoop && m_currentTime >= totalTime;
		}
		
		// properties  
		
		public function get totalTime():Number 
		{
			var numFrames:int = m_timeline.length;
			return m_startTimes[int(numFrames-1)] + m_durations[int(numFrames-1)];
		}
		
		public function get currentTime():Number { return m_currentTime; }
		public function get numFrames():int { return m_timeline.length; }
		public function get loop():Boolean { return m_bLoop; }
		public function set loop(value:Boolean):void { m_bLoop = value; }
		
		public function get currentFrame():int { return m_currentFrame; }
		public function set currentFrame(value:int):void
		{
			if(m_currentFrame == value)
			{
				return;
			}
			
			m_currentFrame = value;
			m_currentTime = 0.0;
			
			for (var i:int=0; i<value; ++i)
			{
				m_currentTime += getFrameDuration(i);
			}
			
			if(m_currentFrame < m_timeline.length)
			{
				updateFrameElement(m_timeline[m_currentFrame]);
			}
			
			if (m_sounds[m_currentFrame]) 
			{
				m_sounds[m_currentFrame].play();
			}
		}
		

		public function get fps():Number { return 1.0 / m_defaultFrameDuration; }
		public function set fps(value:Number):void
		{
			if (value <= 0) throw new ArgumentError("Invalid fps: " + value);
			
			var newFrameDuration:Number = 1.0 / value;
			var acceleration:Number = newFrameDuration / m_defaultFrameDuration;
			m_currentTime *= acceleration;
			m_defaultFrameDuration = newFrameDuration;
			
			for (var i:int=0; i<numFrames; ++i) 
			{
				var duration:Number = m_durations[i] * acceleration;
				m_durations[i] = duration;
			}
			
			updateStartTimes();
		}
		

		public function get isPlaying():Boolean 
		{
			if (m_bPlaying)
			{
				return m_bLoop || m_currentTime < totalTime;
			}
			else
			{
				return false;
			}
		}
	}
}



import slicol.starling.sdk.core.FlLibrary;
import slicol.starling.sdk.core.FlMovieClip;
import slicol.starling.sdk.core.i.FlItem;

import starling.display.DisplayObject;

class FlFrame 
{
	private var m_lib:FlLibrary;
	private var m_target:FlMovieClip;
	private var m_lstElement:Vector.<FlItem>;
	
	public function FlFrame(xmlFlDefine:XML, lib:FlLibrary, target:FlMovieClip)
	{
		m_lib = lib;
		m_target = target;
		m_lstElement = new Vector.<FlItem>;
		
		var xlElt:XMLList = xmlFlDefine.children();
		for(var i:int = 0; i < xlElt.length(); ++i)
		{
			var xmlElt:XML = xlElt[i];
			var elt:FlItem = lib.createElement(xmlElt);
			if(elt)
			{
				m_lstElement.push(elt);
			}
		}
	}
	
	public function dispose():void
	{
		for(var i:int = 0; i < m_lstElement.length; ++i)
		{
			(m_lstElement[i] as  DisplayObject).dispose();
		}
		m_lstElement.length = 0;
	}
	
	public function active():void
	{
		for(var i:int = m_lstElement.length - 1; i >= 0; --i)
		{
			m_target.addChild(m_lstElement[i] as DisplayObject);
		}
	}
	
	public function deactive():void
	{
		for(var i:int = m_lstElement.length - 1; i >= 0; --i)
		{
			m_target.removeChild(m_lstElement[i] as DisplayObject);
		}
	}
}
