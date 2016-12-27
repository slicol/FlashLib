package com.tencent.fge.engine.ui.keyboard
{
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	

	public final class VirtualKeyboard2 extends EventDispatcher
	{
		public static const KEY_NUM:int = 255;
		
		private static var ms_instance:VirtualKeyboard2;
		private var m_stage:DisplayObjectContainer;
		
		private var m_mapVirKeyCode:Dictionary = new Dictionary();
		private var m_tblVirKeyName:Dictionary = new Dictionary();
		
		private var m_queKeyDown:Vector.<VirKeyHelper>;
		
		private var m_evtKeyDown:KeyboardEvent;
		private var m_evtKeyUp:KeyboardEvent;	
		
		private var m_topKey:VirKeyHelper;
		
		private var log:Log = new Log(this);
		
		public static function getInstance():VirtualKeyboard2
		{
			if(ms_instance == null) ms_instance = new VirtualKeyboard2;
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
		
		
		static public function addEventListener(type:String, 
												listener:Function, useCapture:Boolean=false, 
												priority:int=0, useWeakReference:Boolean=false):void
		{
			getInstance().addEventListener(type,listener,
				useCapture,priority,useWeakReference);
		}
		
		static public function removeEventListener(type:String, 
												   listener:Function, useCapture:Boolean=false):void
		{
			getInstance().removeEventListener(type,listener,useCapture);
		}
		
		
		
		private function initialize(stage:DisplayObjectContainer):Boolean
		{
			m_queKeyDown = new Vector.<VirKeyHelper>;
			
			m_stage = stage;
			m_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent);
			m_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyboardEvent);
			m_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			m_stage.addEventListener(Event.DEACTIVATE, onDeactivated);
			
			
			m_evtKeyDown= new KeyboardEvent(KeyboardEvent.KEY_DOWN);
			m_evtKeyUp= new KeyboardEvent(KeyboardEvent.KEY_UP);
			
			return true;
		}
		
		private function finalize():void
		{
			if(m_stage == null) return;
			m_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent);
			m_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyboardEvent);
			m_stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			m_stage.removeEventListener(Event.DEACTIVATE, onDeactivated);
		}
		
		private function onKeyboardEvent(e:KeyboardEvent):void
		{
			//trace("onKeyboardEvent()", e.type, e.keyCode);
			var hlp:VirKeyHelper = null;
			var i:int = 0;
			
			//	logic for multiple key stroke
			var nRealCode:uint = e.keyCode;
			
			if(e.type == KeyboardEvent.KEY_DOWN)
			{
				//按下键
				if(m_topKey != null)
				{
					if(m_topKey.realKeyCode == nRealCode)
					{
						//Log.trace("onKeyboardEvent", 1);
						//更新当前的键
						//m_topKey.isDown = true;
						m_topKey.smoothCount = 3;
						
						if(!m_topKey.needSmooth)
						{
							m_evtKeyDown.keyCode = m_topKey.virKeyCode;
							this.dispatchEvent(m_evtKeyDown);
						}
					}
					else
					{
						//Log.trace("onKeyboardEvent", 2);
						//按下了新键，当前键存入列队，新键变成当前键
						i = m_queKeyDown.indexOf(m_topKey);
						if(i >= 0)
						{
							m_queKeyDown.splice(i, 1);
						}
						m_queKeyDown.push(m_topKey);
						
						m_topKey = m_mapVirKeyCode[nRealCode];
						if(m_topKey)
						{
							//m_topKey.isDown = true;
							m_topKey.smoothCount = 24;
							
							
							if(!m_topKey.needSmooth)
							{
								m_evtKeyDown.keyCode = m_topKey.virKeyCode;
								this.dispatchEvent(m_evtKeyDown);
							}
						}
					}
				}
				else
				{
					//Log.trace("onKeyboardEvent", 3);
					
					m_topKey = m_mapVirKeyCode[nRealCode];
					if(m_topKey)
					{
						//m_topKey.isDown = true;
						m_topKey.smoothCount = 24;
						
						if(!m_topKey.needSmooth)
						{
							m_evtKeyDown.keyCode = m_topKey.virKeyCode;
							this.dispatchEvent(m_evtKeyDown);
						}
					}
				}
				
			}
			else
			{
				//放开键
				if(m_topKey != null && m_topKey.realKeyCode == nRealCode)
				{
					//更新当前的键
					//m_topKey.isDown = false;
					m_evtKeyUp.keyCode = m_topKey.virKeyCode;
					m_topKey = null;
					
					this.dispatchEvent(m_evtKeyUp);
				}
				else
				{
					//放开之前按下的键，将该键从队列移出
					for(i = 0; i < m_queKeyDown.length; ++i)
					{
						if(m_queKeyDown[i].realKeyCode == nRealCode)
						{
							break;
						}
					}
					
					if(i < m_queKeyDown.length)
					{
						hlp = m_queKeyDown[i];
						//hlp.isDown = false;
						m_evtKeyUp.keyCode = hlp.virKeyCode;
						m_queKeyDown.splice(i,1);
						
						this.dispatchEvent(m_evtKeyUp);
					}
				}
				
			}
		}
		
		
		private function onDeactivated(e:Event):void
		{
			var hlp:VirKeyHelper;
			
			for(var i:int = 0; i < m_queKeyDown.length; ++i)
			{
				hlp = m_queKeyDown[i];
				//hlp.isDown = false;
				m_evtKeyUp.keyCode = hlp.virKeyCode;
				this.dispatchEvent(m_evtKeyUp);
			}
			
			m_queKeyDown.length = 0;
			
			if(m_topKey)
			{
				//m_topKey.isDown = false;
				m_evtKeyUp.keyCode = m_topKey.virKeyCode;
				m_topKey = null;
				
				this.dispatchEvent(m_evtKeyUp);
			}
		}
		
		
		private function onEnterFrame(e:Event):void
		{
			var ke:KeyboardEvent;
			var i:int = 0;
			var hlp:VirKeyHelper;
			
			if(m_topKey && m_topKey.needSmooth)
			{
				//Log.trace("onEnterFrame", 1);
				
				//if(m_topKey.isDown)
				{
					//Log.trace("onEnterFrame", 2);
					
					m_evtKeyDown.keyCode = m_topKey.virKeyCode;
					
					m_topKey.smoothCount --;
					if(m_topKey.smoothCount <= 0)
					{
						//Log.trace("onEnterFrame", 3);
						//m_topKey.isDown = false;
						m_topKey = null;
					}
					
					this.dispatchEvent(m_evtKeyDown);
				}
			}
			
			
			for(i = 0; i < m_queKeyDown.length; ++i)
			{
				hlp = m_queKeyDown[i];
				m_evtKeyDown.keyCode = hlp.virKeyCode;
				this.dispatchEvent(m_evtKeyDown);
			}
		}
		
		
		/*---------------------------------------------------------
		*	Func:	regVirKey
		*	Desc:	As function's name suggests.
		*			This function may worth notice.
		*	Param:	keyName, a name for one virtual key
		*			virKeyCode, the key code that want to be listened
		*			smooth, whether make the KeyboardEvent dispatched smoothly
		*			multiStroke, whether this virtual key needs support for multiple stroke is down
		*
		*	Return:	
		*	Remark:	
		*--------------------------------------------------------*/
		public static function regVirKey(keyName:String, virKeyCode:uint, smooth:Boolean = false, multiStroke:Boolean = false):Boolean
		{
			return getInstance().regVirKey(keyName,virKeyCode, smooth, multiStroke);
		}
		
		public function regVirKey(keyName:String, virKeyCode:uint, smooth:Boolean = false, multiStroke:Boolean = false):Boolean
		{
			if(virKeyCode > 255)
			{
				//键值超过最大值
				log.error("regVirKey", "键值超过最大值！");
				return false;
			}
			
			var hlp:VirKeyHelper = null;
			hlp = m_tblVirKeyName[keyName];
			
			if(hlp != null)
			{
				//键名已经被注册
				log.error("regVirKey", "键名已经被注册！");
				return false;
			}
			
			hlp = new VirKeyHelper();
			hlp.keyName = keyName;
			hlp.virKeyCode = virKeyCode;
			hlp.realKeyCode = virKeyCode;
			hlp.needSmooth = smooth;
			m_tblVirKeyName[keyName] = hlp;
			
			var old:VirKeyHelper = m_mapVirKeyCode[hlp.realKeyCode];
			m_mapVirKeyCode[hlp.realKeyCode] = hlp;
			
			if(old)
			{
				var i:int = m_queKeyDown.indexOf(old);
				if(i >= 0)
				{
					m_queKeyDown.splice(i, 1);
					
					m_evtKeyUp.keyCode = old.virKeyCode;
					this.dispatchEvent(m_evtKeyUp);
				}
				old.realKeyCode = -1;
				
			}
			
			return true;
		}
		
		
		public static function unregVirKey(keyName:String, virKeyCode:uint):void
		{
			getInstance().unregVirKey(keyName,virKeyCode);
		}
		
		public function unregVirKey(keyName:String, virKeyCode:uint):void
		{
			if(virKeyCode > 255)
			{
				//键值超过最大值
				log.error("unregVirKey", "键值超过最大值");
				return;
			}
			
			var hlp:VirKeyHelper = null;
			hlp = m_tblVirKeyName[keyName];
			if(hlp == null)
			{
				return;
			}
			
			if(hlp.virKeyCode !=  virKeyCode)
			{
				//键值匹配失败！
				log.error("unregVirKey", "键值匹配失败！");
				return;
			}
			else
			{
				//键值匹配成功
				delete m_tblVirKeyName[keyName];
				m_mapVirKeyCode[hlp.realKeyCode] = null;
			}	
		}
		
		
		static public function bindKeyCode(keyName:String, 
										   realKeyCode:int, enforce:Boolean = true):Boolean
		{
			return getInstance().bindKeyCode(keyName, realKeyCode, enforce);
		}
		
		/*---------------------------------------------------------
		*	Func:	bindKeyCode
		*	Desc:	bind a virtual key with a real key code
		*	Param:	
		*	Return:	
		*	Remark:	
		*--------------------------------------------------------*/
		public function bindKeyCode(keyName:String, 
									realKeyCode:int, enforce:Boolean = true):Boolean
		{
			var hlp:VirKeyHelper = m_tblVirKeyName[keyName];
			if(hlp == null)
			{
				return false;
			}
			
			if(hlp.realKeyCode == realKeyCode)
			{
				return true;
			}
			
			var tmp:VirKeyHelper = m_mapVirKeyCode[realKeyCode];
			if(tmp != null && (!enforce))
			{
				return false;
			}
			
			m_mapVirKeyCode[hlp.realKeyCode] = null;
			hlp.realKeyCode = realKeyCode;
			m_mapVirKeyCode[hlp.realKeyCode] = hlp;
			
			return true;
		}
	}
}

class VirKeyHelper
{
	public var keyName:String = "";
	public var virKeyCode:int = 0;
	public var realKeyCode:int = 0;
	//public var smoothValue:int = 10;
	public var smoothCount:int = 0;
	//public var isDown:Boolean = false;
	public var needSmooth:Boolean = true;
}