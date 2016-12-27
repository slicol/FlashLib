package com.tencent.fge.engine.ui.tips
{
	import com.tencent.fge.engine.ui.UILayer;
	import com.tencent.fge.engine.ui.UILayerDefine;
	import com.tencent.fge.engine.ui.UISystem;
	import com.tencent.fge.foundation.log.client.Log;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;

	public class TipsManager
	{

		private static var ms_instance:TipsManager;
		public static function getInstance():TipsManager
		{
			if(ms_instance == null) ms_instance = new TipsManager;
			return ms_instance;
			
		}
		
		//=============================================================================
	
		private var m_stage:DisplayObjectContainer;
		private var m_layer:UILayer;
		private var m_flag_tipsdata:String = "tipsdata";
		private var m_flag_tipstype:String = "tipstype";
		private var m_tips:ITipsSprite;
		private var m_tipsDefaultUI:ITipsSprite;
		private var log:Log = new Log(this);
		
		private var m_mapTipsUI:Dictionary = new Dictionary();
		private var m_mapTipsObjectHelper:Dictionary = new Dictionary(true);
		
		
		//=============================================================================
		
		
		public static function initialize(tipsDefaultUI:ITipsSprite = null,
								   flagTipsData:String = "tipsdata", 
								   flagTipsType:String = "tipstype"):void
		{
			getInstance().initialize(tipsDefaultUI, flagTipsData, flagTipsType);
		}
		public function initialize(tipsDefaultUI:ITipsSprite = null,
								   flagTipsData:String = "tipsdata", 
								   flagTipsType:String = "tipstype"):void
		{
			m_stage = UISystem.getInstance().stage;
			if(m_stage == null)
			{
				UISystem.getInstance().addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			}
			else
			{
				m_stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseEnter);
			}
			
			m_layer = UISystem.getLayer(UILayerDefine.TOOL_TIPS, UILayerDefine.TOOL_TIPS_Z);
			m_tipsDefaultUI = tipsDefaultUI;
			
			
			m_flag_tipsdata = flagTipsData;
			m_flag_tipstype = flagTipsType;
		}
		
		private function onAddToStage(e:Event):void
		{
			m_stage = UISystem.getInstance().stage;
			m_stage.addEventListener(MouseEvent.MOUSE_OVER, onMouseEnter);
		}
		
		public static function finalize():void
		{
			getInstance().finalize();
		}
		public function finalize():void
		{
			if(m_stage)
			{
				m_stage.removeEventListener(MouseEvent.MOUSE_OVER, onMouseEnter);
				m_stage = null;
			}
			
			m_tipsDefaultUI = null;
			m_layer = null;
		}
		
		
		//=============================================================================
	
		public static function setDefaultTipsUI(tips:ITipsSprite):void
		{
			getInstance().setDefaultTipsUI(tips);
		}
		public function setDefaultTipsUI(tips:ITipsSprite):void
		{
			m_tipsDefaultUI = tips;
		}
		
		//=============================================================================
		public static function addTipsUI(type:String, ui:ITipsSprite):ITipsSprite
		{
			return getInstance().addTipsUI(type, ui);
		}
		
		public function addTipsUI(type:String, ui:ITipsSprite):ITipsSprite
		{
			var last:ITipsSprite = m_mapTipsUI[type];
			m_mapTipsUI[type] = ui;
			return last;
		}
		
		
		public static function removeTipsUI(type:String):ITipsSprite
		{
			return getInstance().removeTipsUI(type);
		}
		public function removeTipsUI(type:String):ITipsSprite
		{
			var last:ITipsSprite = m_mapTipsUI[type];
			m_mapTipsUI[type] = null;
			delete m_mapTipsUI[type];
			return last;
		}
		
		//=============================================================================
		/**
		//tipsObject如果为NULL，则从target里去寻找Tips属性。
		//tipsObject如果为String，则直接显示Tips
		//tipsObject如果是ITipsSprite，则将UserData传入ITipsSprite。
		//tipsObject如果是其它的，则从TipsObject里去寻找tips属性，然后以tips属性进一步判断
		**/
		public static function addTipsObject(target:DisplayObject, 
									  tipsdata:*, tipstype:* = null):Boolean
		{
			return getInstance().addTipsObject(target, tipsdata, tipstype);
		}
		public function addTipsObject(target:DisplayObject, 
									  tipsdata:*, tipstype:* = null):Boolean
		{
			if(target == null || tipsdata == null)
			{
				log.error("addTipsObject","传入的target为空");
				return false;
			}
			
			var hlp:TipsObjectHelper = m_mapTipsObjectHelper[target];
			if(hlp == null)
			{
				hlp = new TipsObjectHelper;
				hlp.target = target;
				m_mapTipsObjectHelper[target] = hlp;
			}
			
			hlp.tipsdata = tipsdata;
			hlp.tipstype = tipstype;
			
			target.addEventListener(MouseEvent.MOUSE_OVER, onTipsObjectMouseEnter);
			
			return true;
		}
		
		public static function removeTipsObject(target:DisplayObject):void
		{
			getInstance().removeTipsObject(target);
		}
		public function removeTipsObject(target:DisplayObject):void
		{
			if(target == null)
			{
				return;
			}
			
			m_mapTipsObjectHelper[target] = null;
			delete m_mapTipsObjectHelper[target];
			target.removeEventListener(MouseEvent.MOUSE_OVER, onTipsObjectMouseEnter);
		}
		
		
		private function onTipsObjectMouseEnter(e:MouseEvent):void
		{
			var target:* = e.currentTarget as DisplayObject;
			var hlp:TipsObjectHelper = m_mapTipsObjectHelper[target];
			var pt:Point = new Point(e.stageX, e.stageY);
			
			if(hlp != null)
			{
				if(hlp.tipsdata != null)
				{
					pt = m_stage.globalToLocal(pt);
					popupTips(hlp.tipstype, pt.x, pt.y, hlp.tipsdata);
				}
			}

			e.stopPropagation();
		}
		
		//=============================================================================
		//-----------------------------------------------------------------------------
		
		private function onMouseEnter(e:MouseEvent):void
		{
			if(m_tips)
			{
				m_tips.hide();
			}
			
			var target:Object;
			var tipstype:*;
			var tipsdata:*;
			var pt:Point = new Point(e.stageX, e.stageY);
			var arr:Array = m_stage.getObjectsUnderPoint(pt);
			
			if(arr.length == 0)
			{
				return;
			}
			
			target = arr[arr.length - 1];
			
			//var tmp:String = target["name"];
			
			while(target != null && target != m_stage)
			{
				//trace("onMouseEnter:" + tmp);
				
				if(target.hasOwnProperty(m_flag_tipsdata))
				{
					tipsdata = target[m_flag_tipsdata];
					if(tipsdata != null)
					{
						tipstype = target[m_flag_tipstype];
						pt = m_stage.globalToLocal(pt);
						popupTips(tipstype, pt.x, pt.y, tipsdata);
					}
					break;
				}
				target = target.parent;
				
				//tmp = tmp + ">" +  target["name"];
			}
		}
		
		
		private function popupTips(tipstype:*, x:int, y:int, tipsdata:*):void
		{
			if(tipstype is ITipsSprite)
			{
				attachTips(tipstype);
			}
			else if(tipstype is String)
			{
				attachTipsByType(tipstype);
			}
			else
			{
				attachTips(m_tipsDefaultUI);
			}
			
			if(m_tips)
			{
				if(tipsdata is String)
				{
					m_tips.setTextTips(tipsdata);
				}
				if(tipsdata is DisplayObject)
				{
					m_tips.setRichTips(tipsdata);
				}
				else
				{
					m_tips.setUserTips(tipsdata);
				}
				
				m_tips.popup(x,y, UISystem.width, UISystem.height);				
			}
		}
		

		private function attachTips(tips:ITipsSprite):void
		{
			if(m_tips != tips)
			{
				if(m_tips && m_layer.contains(m_tips as DisplayObject))
				{
					m_layer.removeChild(m_tips as DisplayObject);
				}
				m_tips = tips;
				if(m_tips)
				{
					m_layer.addChild(m_tips as DisplayObject);
				}
			}
		}
		
		private function attachTipsByType(type:String):void
		{
			var tips:ITipsSprite = m_mapTipsUI[type];
			if(tips == null)
			{
				tips = m_tipsDefaultUI;
			}
			
			attachTips(tips);
		}
		
	}
}
import com.tencent.fge.engine.ui.tips.ITipsSprite;

import flash.display.DisplayObject;

class TipsObjectHelper
{
	public var target:DisplayObject;
	public var tipsdata:*;
	public var tipstype:*;
}