package com.tencent.fge.engine.sound
{
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	[Event(name="soundComplete", type="flash.events.Event")]
	[Event(name="ioErrorEvent", type="flash.events.IOErrorEvent")]
	public class SoundPlayer extends EventDispatcher
	{
		public static const FADE_IN_TIME:uint = 2000;
		public static const FADE_OUT_TIME:uint = 1000;

		private var m_snd:Sound;
		private var m_chn:SoundChannel;
		//private var m_stfFadeIn:SoundTransform = new SoundTransform();
		//private var m_stfFadeOut:SoundTransform = new SoundTransform();
		//private var m_stfVolume:SoundTransform = new SoundTransform();
		private var m_url:String = "";
		private var m_loop:int = 1;
		private var m_fadeTime:uint = 0;
		private var m_timFadeIn:Timer;
		private var m_timFadeOut:Timer;
		private const mc_iVolStep:int = 10;
		private var m_nVolSpeedFadeIn:Number;
		private var m_nVolSpeedFadeOut:Number;
		private var m_state:String = SoundPlayerState.NULL;
		private var m_startTime:Number = 0;
		
		private var m_realVolume:Number = 1;
		private var m_scaleVolume:Number = 1;
		private var m_volume:Number = 1;
		
		private var log:Log = new Log(this);
		
		
		public function SoundPlayer()
		{
			m_timFadeIn = new Timer(0, 0);
			m_timFadeOut = new Timer(0, 0);
		}
		
		public function get state():String{return m_state;}

		
		public function get scaleVolume():Number{return m_scaleVolume;}
		public function set scaleVolume(value:Number):void
		{
			m_scaleVolume = value;
			m_realVolume = m_volume * m_scaleVolume;
			if(m_chn)
			{
				var stf:SoundTransform = m_chn.soundTransform;
				stf.volume = m_realVolume;
				m_chn.soundTransform = stf;
			}
		}
		
		
		public function get volume():Number{return m_volume;}
		public function set volume(value:Number):void
		{
			m_volume = value;
			m_realVolume = m_volume * m_scaleVolume;
			if(m_chn)
			{
				var stf:SoundTransform = m_chn.soundTransform;
				stf.volume = m_realVolume;
				m_chn.soundTransform = stf;
			}
		}
		
		
		
		/*---------------------------------------------------------
		*	Setter and Getter: url
		*--------------------------------------------------------*/
		public function set url(value:String):void { m_url = value; }
		public function get url():String { return m_url; }
		
		/*---------------------------------------------------------
		*	Getter: sound
		*--------------------------------------------------------*/
		public function get sound():Sound { return m_snd; }
		 
		public function load():void
		{
			if(!m_url)
			{
				return;
			}
			
			
			var urlReal:String = SoundVersion.getRealUrl(m_url);
			
			
			if(m_snd != null && m_snd.url == urlReal)
			{
				return;
			}
			
			
			if(m_snd != null)
			{
				m_snd.removeEventListener(IOErrorEvent.IO_ERROR, onSoundLoadEvent);
				m_snd.removeEventListener(Event.COMPLETE, onSoundLoadEvent);
			}

			m_snd = new Sound();
			m_snd.load(new URLRequest(urlReal));
			m_snd.addEventListener(IOErrorEvent.IO_ERROR, onSoundLoadEvent);
			m_snd.addEventListener(Event.COMPLETE, onSoundLoadEvent);
			
			m_state = SoundPlayerState.BUSY;
		}
		
		public function attach(snd:Sound):void
		{
			if(m_snd == snd)
			{
				return;
			}
			
			detach();
			
			m_snd = snd;
			if(m_snd != null)
			{
				m_state = SoundPlayerState.STOP;
			}
			else
			{
				m_state = SoundPlayerState.NULL;
			}
		}
		
		public function detach():void
		{
			stop();
			m_url = "";
			m_snd = null;
			m_state = SoundPlayerState.NULL;
		}
		
		public function unload():void
		{
			stop();
			m_url = "";
			
			if(m_snd != null)
			{
				try
				{
					m_snd.close();
				}
				catch(e:Error)
				{
					log.error("unload", e.toString());
				}
				m_snd = null;
			}
		}
				

		public function play(fadeTime:uint = 0, loop:int = 1, overlap:Boolean = false):void
		{
			if(m_state == SoundPlayerState.NULL)
			{
				return;
			}
						
			m_loop = loop;
			m_fadeTime = fadeTime;
			
			if(overlap || m_state == SoundPlayerState.STOP ||
				m_state == SoundPlayerState.PAUSE)
			{
				m_state = SoundPlayerState.PLAY;
				
				if(!playWithState())
				{
					stop();
					log.error("play", "播放失败,URL:" + this.url);
					//var evt:IOErrorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR);
					//this.dispatchEvent(evt);
				}
			}
			else
			{
				m_state = SoundPlayerState.PLAY;
			}
		}
		
		public function resume():void
		{
			if(m_state == SoundPlayerState.NULL)
			{
				return;
			}
			
			if( m_state == SoundPlayerState.PAUSE ||
				m_state == SoundPlayerState.STOP)
			{
				m_state = SoundPlayerState.PLAY;
				if(!playWithState())
				{
					stop();
					log.error("resume", "播放失败,URL:" + this.url);
					//var evt:IOErrorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR);
					//this.dispatchEvent(evt);
				}
			}
			else
			{
				m_state = SoundPlayerState.PLAY;
			}
		}
		
				
		public function pause():void
		{
			if(m_state == SoundPlayerState.NULL)
			{
				return;
			}
			
			m_state = SoundPlayerState.PAUSE;
			m_startTime = 0;
			if(m_chn != null)
			{
				m_startTime = m_chn.position;
				m_chn.removeEventListener(Event.SOUND_COMPLETE, onSoundPlayEvent);			
				m_chn.stop();
				m_chn = null;
			}
		}
		
		public function stop(fadeTime:uint = 0):void
		{
			if(m_state == SoundPlayerState.NULL)
			{
				return;
			}
			
			m_state = SoundPlayerState.STOP;
			m_startTime = 0;
			if(m_chn != null)
			{
				m_chn.removeEventListener(Event.SOUND_COMPLETE, onSoundPlayEvent);
				if(fadeTime > 0)
				{
					//m_stfFadeOut.volume = m_volume;
					m_timFadeIn.removeEventListener(TimerEvent.TIMER, onTimerFadeIn);
					
					m_timFadeOut.reset();
					m_timFadeOut.delay = fadeTime / mc_iVolStep;
					m_nVolSpeedFadeOut = m_chn.soundTransform.volume / mc_iVolStep;
					m_timFadeOut.addEventListener(TimerEvent.TIMER, onTimerFadeOut);
					m_timFadeOut.start();
				}
				else
				{		
					m_chn.stop();
					m_chn = null;
				}
			}
		}
		
		
		private function playWithState():Boolean
		{
			if(m_chn != null)
			{
				m_chn.stop();
				m_chn.removeEventListener(Event.SOUND_COMPLETE, onSoundPlayEvent);
				m_chn = null;
			}
			
			
			try
			{
				if(m_loop == 0)
				{
					//log.trace("playWithState", "永远循环");
					m_chn = m_snd.play(m_startTime, int.MAX_VALUE);
				}
				else
				{
					//log.trace("playWithState", "循环次数:" + m_loop);
					m_chn = m_snd.play(m_startTime, m_loop);
				}
			}
			catch(e:Error)
			{
				log.error("playWithState", e.errorID, e.name, e.message);
			}

			if(m_chn != null)
			{
				var stf:SoundTransform;
				
				m_chn.addEventListener(Event.SOUND_COMPLETE, onSoundPlayEvent);
				
				if(m_state == SoundPlayerState.PAUSE)
				{
					pause();
				}
				else if(m_state == SoundPlayerState.STOP)
				{
					stop();
				}
				else if(m_state == SoundPlayerState.PLAY)
				{
					if(m_fadeTime > 0)
					{
						//m_stfFadeIn.volume = 0;
						//m_chn.soundTransform = m_stfFadeIn;
						stf = m_chn.soundTransform;
						stf.volume = 0;
						m_chn.soundTransform = stf;
						
						m_timFadeOut.removeEventListener(TimerEvent.TIMER, onTimerFadeOut);
						
						m_timFadeIn.reset();
						m_timFadeIn.delay = m_fadeTime / mc_iVolStep;
						m_nVolSpeedFadeIn = (1.0 - m_chn.soundTransform.volume) / mc_iVolStep;
						m_timFadeIn.addEventListener(TimerEvent.TIMER, onTimerFadeIn);
						m_timFadeIn.start();
					}
					else
					{
						stf = m_chn.soundTransform;
						stf.volume = m_realVolume;
						m_chn.soundTransform = stf;
					}
				}
				else
				{
					stop();
				}
			}
			
			return m_chn != null;
		}
		


		private function onTimerFadeIn(e:Event):void
		{
			var tim:Timer = e.target as Timer;
			//m_stfFadeIn.volume = m_stfFadeIn.volume + 0.1;
			if(null != m_chn)
			{
				var stf:SoundTransform = m_chn.soundTransform;
				stf.volume = stf.volume + m_nVolSpeedFadeIn;
				m_chn.soundTransform = stf;
				if(m_chn.soundTransform.volume >= m_realVolume)
				{
					stf.volume = m_realVolume;
					m_chn.soundTransform = stf;
					tim.stop();
					tim.removeEventListener(TimerEvent.TIMER, onTimerFadeIn);
				}
			}
			
			//m_chn.soundTransform = m_stfFadeIn;
		}
		
		private function onTimerFadeOut(e:Event):void
		{
			//m_chn.soundTransform = m_stfFadeOut;
			
			var tim:Timer = e.target as Timer;
			//m_stfFadeOut.volume = m_stfFadeOut.volume - 0.1;
			
			if(m_chn == null)
			{
				tim.stop();
				tim.removeEventListener(TimerEvent.TIMER, onTimerFadeOut);
				return;
			}
			
			var stf:SoundTransform = m_chn.soundTransform;
			stf.volume = stf.volume - m_nVolSpeedFadeOut;
			m_chn.soundTransform = stf;
			if(m_chn.soundTransform.volume <= 0)
			{
				stf.volume = 0;
				m_chn.soundTransform = stf;
				tim.stop();
				tim.removeEventListener(TimerEvent.TIMER, onTimerFadeOut);
				stop(0);
			}
			
		}
		
		private function onSoundLoadEvent(e:Event):void
		{
			var snd:Sound = e.target as Sound;
			snd.removeEventListener(IOErrorEvent.IO_ERROR, onSoundLoadEvent);
			snd.removeEventListener(Event.COMPLETE, onSoundLoadEvent);
			
			if(m_snd != snd)
			{
				snd.close();
				return;
			}
			
			if(e.type == Event.COMPLETE)
			{
				if(!playWithState())
				{
					stop();
					//var evt:IOErrorEvent = new IOErrorEvent(IOErrorEvent.IO_ERROR);
					//this.dispatchEvent(evt);
				}
			}
			else
			{
				log.error("onSoundLoadEvent", "加载失败,URL:" + this.url);
				//this.dispatchEvent(e);
			}
		}
		
		
		private function onSoundPlayEvent(e:Event):void
		{
			if(e.type == Event.SOUND_COMPLETE)
			{
				stop();
				this.dispatchEvent(e);
			}			
		}


	}
}