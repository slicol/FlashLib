package com.tencent.fge.engine.ui
{
	import com.tencent.fge.engine.ui.keyboard.KeyCode;
	import com.tencent.fge.engine.ui.keyboard.VirtualKeyboard;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;

	public class UIKeyboardCtlBase extends Sprite
	{
		private var m_enabled:Boolean = true;
		
		private var m_mapKeySmooth:Dictionary = new Dictionary;
		private var m_mapKeyBasic:Dictionary = new Dictionary;
		
		public function UIKeyboardCtlBase(key:* = null, smooth:Boolean = false, listener:Function = null)
		{
			addKey(key, smooth, listener);
		}
		
		/**
		 * key: 可以是键名，也可以是键值，也可以是键的数组
		 **/
		public function addKey(key:*, smooth:Boolean, listener:Function = null):void
		{	
			if(key is String)
			{
				key = KeyCode.keyName2Code(String(key).charAt(0).toLowerCase());
				addKey(key, smooth, listener);
			}
			else if(key is Array)
			{
				var lstKey:Array = key as Array;
				for(var i:int = 0; i < lstKey.length; ++i)
				{
					addKey(lstKey[i], smooth, listener);
				}
			}
			else if(key)
			{
				var data:KeyData = new KeyData;
				data.code = uint(Number(key));
				data.listener = listener;
				
				if(smooth)
				{
					m_mapKeySmooth[data.code] = data;
				}
				else
				{
					m_mapKeyBasic[data.code] = data;
				}
			}
		}
		
		public function removeKey(key:*, smooth:Boolean):void
		{
			if(key is String)
			{
				key = KeyCode.keyName2Code(String(key).charAt(0).toLowerCase());
				removeKey(key, smooth);
			}
			else if(key is Array)
			{
				var lstKey:Array = key as Array;
				for(var i:int = 0; i < lstKey.length; ++i)
				{
					removeKey(lstKey[i], smooth);
				}
			}
			else if(key)
			{
				key = uint(Number(key));

				if(smooth)
				{
					if(m_mapKeySmooth[key])
					{
						delete m_mapKeySmooth[key];
					}
				}
				else
				{
					if(m_mapKeyBasic[key])
					{
						delete m_mapKeyBasic[key];
					}
				}
			}
		}
		
		public function removeAll():void
		{
			m_mapKeyBasic = new Dictionary;
			m_mapKeySmooth = new Dictionary;
		}
		
		
		public function active():void
		{
			VirtualKeyboard.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventSmooth, true);
			VirtualKeyboard.addEventListener(KeyboardEvent.KEY_UP, onKeyEventSmooth, true);
			
			VirtualKeyboard.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventBasic, false);
			VirtualKeyboard.addEventListener(KeyboardEvent.KEY_UP, onKeyEventBasic, false);
		}
		
		public function deactive():void
		{
			VirtualKeyboard.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyEventSmooth, true);
			VirtualKeyboard.removeEventListener(KeyboardEvent.KEY_UP, onKeyEventSmooth, true);
			
			VirtualKeyboard.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyEventBasic, false);
			VirtualKeyboard.removeEventListener(KeyboardEvent.KEY_UP, onKeyEventBasic, false);
		}
		
		private function onKeyEventSmooth(e:KeyboardEvent):void
		{
			var data:KeyData = m_mapKeySmooth[e.keyCode];
			if(data && m_enabled)
			{
				this.dispatchEvent(e);
				if(data.listener != null)
				{
					data.listener(e.clone());
				}
			}
		}
		
		
		private function onKeyEventBasic(e:KeyboardEvent):void
		{
			var data:KeyData = m_mapKeyBasic[e.keyCode];
			if(data && m_enabled)
			{
				this.dispatchEvent(e);
				if(data.listener != null)
				{
					data.listener(e.clone());
				}
			}
		}
		
		
		public function get enabled():Boolean
		{
			return m_enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			m_enabled = value;
		}
		
		
	}
}


class KeyData
{
	public var code:uint;
	public var listener:Function;
}