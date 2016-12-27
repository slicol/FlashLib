package com.tencent.fge.engine.sound
{
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class SoundManager extends EventDispatcher
	{
		private static var ms_lstManager:Dictionary = new Dictionary;
		private var log:Log = new Log(this);
		private var m_name:String = "";
		
		public function SoundManager(name:String)
		{
			super();
			m_name = name;
		}
		
		public static function initialize():Boolean
		{
			return true;
		}
		
		public static function finalize():void
		{
		}
		
		
		public static function getSoundManager(
			name:String, type:String="default"):SoundManager
		{
			var sm:SoundManager = ms_lstManager[name];
			if(sm == null)
			{
				sm = new SoundManager(name);
				ms_lstManager[name] = sm;
			}
			return sm;		
		}

		//-----------------------------------------------------------
		//-----------------------------------------------------------
		
		private var m_lstSound:Array = new Array();
		private var m_globalVolume:Number = 1;
		
		//-----------------------------------------------------
		
		public function createSound():SoundPlayer
		{
			var snd:SoundPlayer = new SoundPlayer();
			m_lstSound.push(snd);
			snd.scaleVolume = m_globalVolume;
			return snd;
		}
		
		public function playSound(path:String, fadeTime:uint = 0, loop:int = 1):SoundPlayer
		{
			var snd:SoundPlayer = new SoundPlayer();
			m_lstSound.push(snd);
			snd.scaleVolume = m_globalVolume;
			snd.url = path;
			snd.load();
			snd.play(fadeTime, loop);
			return snd;
		}
		
		public function stopSound(snd:SoundPlayer,fadeTime:uint = 0):void
		{
			if(m_lstSound.indexOf(snd) >= 0)
			{
				snd.stop(fadeTime);
			}
		}

		public function cleanSound(snd:SoundPlayer):void
		{
			var i:int = m_lstSound.indexOf(snd);
			if(i >= 0)
			{
				snd.unload();
				m_lstSound.splice(i,1);
			}
		}
		
		public function cleanAll():void
		{
			for(var i:int = 0; i < m_lstSound.length; ++i)
			{
				var snd:SoundPlayer = m_lstSound[i];
				snd.unload();
			}
			m_lstSound = new Array;
		}
		
		public function get volume():Number{return m_globalVolume;}
		public function set volume(value:Number):void
		{
			m_globalVolume = value;
			for(var i:int = 0; i < m_lstSound.length; ++i)
			{
				var snd:SoundPlayer = m_lstSound[i];
				snd.scaleVolume = m_globalVolume;
			}
		}
		
		
		
		
		public static function createSound(managerName:String):SoundPlayer
		{
			return getSoundManager(managerName).createSound();
		}
		
		public static function playSound(managerName:String, 
										 path:String, fadeTime:uint = 0, loop:int = 1):SoundPlayer
		{
			return getSoundManager(managerName).playSound(path, fadeTime, loop);
		}
		
		
		public static function stopSound(managerName:String, 
										 snd:SoundPlayer,fadeTime:uint = 0):void
		{
			getSoundManager(managerName).stopSound(snd, fadeTime);
		}
		
		public static function cleanSound(managerName:String, 
										  snd:SoundPlayer):void
		{
			getSoundManager(managerName).cleanSound(snd);
		}
		
		public static function cleanAll(managerName:String):void
		{
			getSoundManager(managerName).cleanAll();
		}
		
		public static function setVolume(managerName:String, value:Number):void
		{
			getSoundManager(managerName).volume = value;
		}
		
		public static function getVolume(managerName:String):Number
		{
			return getSoundManager(managerName).volume;
		}
	}
}