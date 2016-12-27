package com.tencent.fge.engine.ui.keyboard
{
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	
	public final class VirtualKeyboard extends EventDispatcher
	{
		public static const KEY_NUM:int = 255;
		
		private static var ms_instance:VirtualKeyboard;
		private static var ms_evtdisp:EventDispatcher;
		
		private var m_stage:DisplayObjectContainer;
		private var m_hasActivated:Boolean = true;
		
		private var m_queKeyDown:Vector.<uint>;
		
		private var log:Log = new Log(this);

		public static function getInstance():VirtualKeyboard
		{
			if(ms_instance == null) 
			{
				ms_instance = new VirtualKeyboard;
				ms_evtdisp = new EventDispatcher;
			}
			return ms_instance;
			
		}
		
		public static function initialize(stage:DisplayObjectContainer):Boolean
		{
			return getInstance().initialize(stage);
		}
		
		public static function finalize():void
		{
			getInstance().finalize();
		}
		
		public static function reset():void
		{
			getInstance().reset();
		}
		
		
		static public function addEventListener(type:String, listener:Function, smooth:Boolean = true):void
		{
			getInstance();
			if(smooth)
			{
				ms_instance.addEventListener(type,listener);
			}
			else
			{
				ms_evtdisp.addEventListener(type, listener);
			}
		}
		
		static public function removeEventListener(type:String, listener:Function, smooth:Boolean = true):void
		{
			getInstance();
			if(smooth)
			{
				ms_instance.removeEventListener(type,listener);
			}
			else
			{
				ms_evtdisp.removeEventListener(type, listener);
			}
		}
		
		
		
		private function initialize(stage:DisplayObjectContainer):Boolean
		{
			m_queKeyDown = new Vector.<uint>;
			
			m_stage = stage;
			
			m_stage.addEventListener(KeyboardEvent.KEY_DOWN, onSmoothKeyboardEvent);
			m_stage.addEventListener(KeyboardEvent.KEY_UP, onSmoothKeyboardEvent);
			
			m_stage.addEventListener(KeyboardEvent.KEY_DOWN, onBasicKeyboardEvent);
			m_stage.addEventListener(KeyboardEvent.KEY_UP, onBasicKeyboardEvent);
			
			m_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			m_stage.addEventListener(Event.DEACTIVATE, onDeactivated);
			m_stage.addEventListener(Event.ACTIVATE, onActivated);

			return true;
		}
		
		private function finalize():void
		{
			if(m_stage == null) return;
			
			m_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onSmoothKeyboardEvent);
			m_stage.removeEventListener(KeyboardEvent.KEY_UP, onSmoothKeyboardEvent);
			
			m_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onBasicKeyboardEvent);
			m_stage.removeEventListener(KeyboardEvent.KEY_UP, onBasicKeyboardEvent);
			
			m_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			m_stage.removeEventListener(Event.DEACTIVATE, onDeactivated);
			m_stage.removeEventListener(Event.ACTIVATE, onActivated);
		}
		
		
		private function reset():void
		{
			m_queKeyDown.length = 0;
			m_hasActivated = true;
		}
		
		
		private function onBasicKeyboardEvent(e:KeyboardEvent):void
		{
			if(!m_hasActivated)
			{
				return;
			}
			
			ms_evtdisp.dispatchEvent(e.clone());
		}
		
		private function onSmoothKeyboardEvent(e:KeyboardEvent):void
		{
			if(!m_hasActivated)
			{
				return;
			}
			
			var code:uint = e.keyCode;
			var i:int = 0;
			
			i = m_queKeyDown.indexOf(code);
			
			if(e.type == KeyboardEvent.KEY_DOWN)
			{
				if(i < 0)
				{
					m_queKeyDown.push(code);
				}				
			}
			else if(e.type == KeyboardEvent.KEY_UP)
			{
				if(i >= 0)
				{
					m_queKeyDown.splice(i, 1);
					
					//	1. dispatch the last key down event
					var kde:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
					kde.keyCode = code;
					this.dispatchEvent(kde);
					
					//	2. and then, dispatch the key up event
					this.dispatchEvent(e);
				}
			}
		}
		
		
		private function onDeactivated(e:Event):void
		{
			m_queKeyDown.length = 0;
			m_hasActivated = false;
		}
		
		private function onActivated(e:Event):void
		{
			m_hasActivated = true;
		}
		
		 
		private function onEnterFrame(e:Event):void
		{
			var i:int = 0;
			var code:uint = 0;
			
			for(i = 0; i < m_queKeyDown.length; ++i)
			{
				code = m_queKeyDown[i];
				var evt:KeyboardEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN);
				evt.keyCode = code;
				this.dispatchEvent(evt);
			}
		}

	}
}

