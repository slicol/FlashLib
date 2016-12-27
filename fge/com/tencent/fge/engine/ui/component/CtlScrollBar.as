package com.tencent.fge.engine.ui.component
{
	import com.tencent.fge.engine.ui.UIMovieClipCtlBase;
	import com.tencent.fge.engine.ui.event.ScrollEvent;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	[Event(name="scroll",type="com.tencent.fge.engine.ui.event.ScrollEvent")]
	
	public class CtlScrollBar extends UIMovieClipCtlBase
	{
		public static const Horizontal:String = "Horizontal";
		public static const Vertical:String = "Vertical";
		
		private var m_btnPrev:SimpleButton;
		private var m_btnNext:SimpleButton;
		private var m_btnThumb:SimpleButton;
		private var m_imgBackground:MovieClip;
		private var m_direction:String = Horizontal;	

		
		private var m_oldValue:Number;
		private var m_curValue:Number;

		private var m_minValue:Number;
		private var m_maxValue:Number;
		
		private var m_baseStepValue:Number = 10;
		private var m_currStepValue:Number = 10;
		
		private var m_state:String = "";
		
		private var m_mouseDownPoint:Point = new Point;
		private var m_autoRepeatTimer:Timer;
		
		
		
		
		public function CtlScrollBar(ui:MovieClip, direction:String = Horizontal)
		{
			super(ui);

			m_direction = direction;
			
			m_btnPrev = m_ui["btnPrev"];
			m_btnNext = m_ui["btnNext"]
			m_btnThumb = m_ui["btnThumb"];
			m_imgBackground = m_ui["imgBackground"];

			m_autoRepeatTimer = new Timer(1000);
			m_autoRepeatTimer.addEventListener(TimerEvent.TIMER, onAutoRepeatTimer);
			
			m_btnPrev.addEventListener(MouseEvent.CLICK,onBtnPrevClick);
			m_btnPrev.addEventListener(MouseEvent.MOUSE_DOWN, onBtnPrevDown);
			m_btnPrev.addEventListener(MouseEvent.MOUSE_UP, onBtnPrevUp);
			m_btnNext.addEventListener(MouseEvent.CLICK,onBtnNextClick);
			m_btnNext.addEventListener(MouseEvent.MOUSE_DOWN, onBtnNextDown);
			m_btnNext.addEventListener(MouseEvent.MOUSE_UP, onBtnNextUp);
			m_btnThumb.addEventListener(MouseEvent.MOUSE_DOWN,onBtnThumbDown);
			
		}
		
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			
			if(enabled)
			{
				m_btnPrev.addEventListener(MouseEvent.CLICK,onBtnPrevClick);
				m_btnPrev.addEventListener(MouseEvent.MOUSE_DOWN, onBtnPrevDown);
				m_btnPrev.addEventListener(MouseEvent.MOUSE_UP, onBtnPrevUp);
				m_btnNext.addEventListener(MouseEvent.CLICK,onBtnNextClick);
				m_btnNext.addEventListener(MouseEvent.MOUSE_DOWN, onBtnNextDown);
				m_btnNext.addEventListener(MouseEvent.MOUSE_UP, onBtnNextUp);
				m_btnThumb.addEventListener(MouseEvent.MOUSE_DOWN,onBtnThumbDown);
			}
			else
			{
				m_btnPrev.removeEventListener(MouseEvent.CLICK,onBtnPrevClick);
				m_btnPrev.removeEventListener(MouseEvent.MOUSE_DOWN, onBtnPrevDown);
				m_btnPrev.removeEventListener(MouseEvent.MOUSE_UP, onBtnPrevUp);
				m_btnNext.removeEventListener(MouseEvent.CLICK,onBtnNextClick);
				m_btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, onBtnNextDown);
				m_btnNext.removeEventListener(MouseEvent.MOUSE_UP, onBtnNextUp);
				m_btnThumb.removeEventListener(MouseEvent.MOUSE_DOWN,onBtnThumbDown);
			}
		}

		public function setScaleValue(min:Number, max:Number):void
		{
			m_minValue = min;
			m_maxValue = max;
			updateLayout();
		}
		
		public function getMaxValue():Number
		{
			return m_maxValue;
		}
		
		public function setStepValue(value:Number):void
		{
			m_baseStepValue = value;
			m_currStepValue = value;
		}
		
		
		public function get value():Number
		{
			return m_curValue;
		}
		
		public function set value(curValue:Number):void
		{
			if(m_state == "draging")
			{
				return;
			}
			
			m_curValue = curValue;
			
			updateLayout();
			handleEevent();
		}
		

		public function previous():void
		{
			if(m_curValue > m_minValue)
			{
				m_curValue -= m_baseStepValue;
				if(m_curValue < m_minValue)
				{
					m_curValue = m_minValue;
				}
			}
			updateLayout();	
			handleEevent();
		}
		
		public function next():void
		{
			if(m_curValue < m_maxValue)
			{
				m_curValue += m_baseStepValue;
				if(m_curValue > m_maxValue)
				{
					m_curValue = m_maxValue;
				}
			}
			updateLayout();	
			handleEevent();
		}
		

		private function updateLayout():void
		{			
			//if(m_state != "draging")
			{
				var rate:Number = (m_curValue - m_minValue) / (m_maxValue - m_minValue);
				//水平
				if(m_direction == Horizontal)
				{
					m_btnThumb.x = m_imgBackground.x + (m_imgBackground.width - m_btnThumb.width) * rate;
					m_btnThumb.x = Math.max(m_btnThumb.x, m_imgBackground.x);
				}
				else
				{
					m_btnThumb.y = m_imgBackground.y + (m_imgBackground.height - m_btnThumb.height) * rate;
					m_btnThumb.y = Math.max(m_btnThumb.y, m_imgBackground.y);
				}
			}
			
			
		}
		
		private function handleEevent():void
		{
			if(m_oldValue != m_curValue)
			{
				m_oldValue = m_curValue;
				var e:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
				e.maxValue = m_maxValue;
				e.minValue = m_minValue;
				e.curValue = m_curValue;
				this.dispatchEvent(e);
			}
		}
		
		//------------------------------------------------------------------
		
		private function onBtnPrevClick(evt:MouseEvent):void
		{
			previous();
		}
		
		private function onBtnPrevDown(evt:MouseEvent):void
		{
			var target:DisplayObject;
			
			target = evt.target as DisplayObject;
			m_currStepValue = -m_baseStepValue;
			m_autoRepeatTimer.start();
			
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}
		
		private function onBtnPrevUp(evt:MouseEvent):void
		{
			m_autoRepeatTimer.delay = 1000;
			m_autoRepeatTimer.stop();
		}
		
		
		//------------------------------------------------------------------
		
		private function onBtnNextClick(evt:MouseEvent):void
		{
			next();
		}
		

		private function onBtnNextDown(evt:MouseEvent):void
		{
			var target:DisplayObject;
			
			target = evt.target as DisplayObject;
			m_currStepValue = m_baseStepValue;
			m_autoRepeatTimer.start();
			
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}

		
		private function onBtnNextUp(evt:MouseEvent):void
		{
			m_autoRepeatTimer.delay = 1000;
			m_autoRepeatTimer.stop();
		}

		
		//------------------------------------------------------------------
		

		private function onStageMouseUp(evt:Event):void
		{
			var target:DisplayObject;
			
			target = evt.target as DisplayObject;
			m_autoRepeatTimer.delay = 1000;
			m_autoRepeatTimer.stop();
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
		}		

		//------------------------------------------------------------------
		
		private function onBtnThumbDown(evt:MouseEvent):void
		{
			m_btnThumb.removeEventListener(MouseEvent.MOUSE_DOWN,onBtnThumbDown);
			
			m_mouseDownPoint = m_btnThumb.globalToLocal(new Point(evt.stageX,evt.stageY));
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onBtnThumbMove);
			stage.addEventListener(MouseEvent.MOUSE_UP,onBtnThumbUp);
			
			m_state = "draging";
		}
		
		private function onBtnThumbMove(evt:MouseEvent):void
		{
			var localPoint:Point;
			var theX:Number;
			var theY:Number;
						
			//水平
			if(m_direction == Horizontal)
			{
				localPoint = m_ui.globalToLocal(new Point(evt.stageX - m_mouseDownPoint.x ,evt.stageY));
				
				if(localPoint.x >= m_imgBackground.x &&
					localPoint.x <= m_imgBackground.x + m_imgBackground.width - m_btnThumb.width)
				{
					m_btnThumb.x = localPoint.x;
				}
				else if(localPoint.x <= m_imgBackground.x)
				{
					m_btnThumb.x = m_imgBackground.x;
				}
				else
				{
					m_btnThumb.x = m_imgBackground.x + m_imgBackground.width - m_btnThumb.width;
				}
				
				
				m_curValue = m_minValue + (m_maxValue - m_minValue) * ((m_btnThumb.x - m_imgBackground.x) / (m_imgBackground.width - m_btnThumb.width));	
			}
			else
			{
				localPoint = m_ui.globalToLocal(new Point(evt.stageX,evt.stageY - m_mouseDownPoint.y));
				
				if(localPoint.y >= m_imgBackground.y &&
					localPoint.y <= m_imgBackground.y + m_imgBackground.height - m_btnThumb.height)
				{
					m_btnThumb.y = localPoint.y;
				}
				else if(localPoint.y <= m_imgBackground.y)
				{
					m_btnThumb.y = m_imgBackground.y;
				}
				else
				{
					m_btnThumb.y = m_imgBackground.y + m_imgBackground.height - m_btnThumb.height;
				}
				
				
				m_curValue = m_minValue + (m_maxValue - m_minValue) * ((m_btnThumb.y - m_imgBackground.y) / (m_imgBackground.height - m_btnThumb.height));	
			}
			
			
			//对m_curValue进行规则化
			var d:Number = m_curValue - m_minValue;
			d = int(d / m_baseStepValue) * m_baseStepValue;
			m_curValue = m_minValue + d;
			

			
			updateLayout();	
			handleEevent();
			
		}
		
		private function onBtnThumbUp(evt:MouseEvent):void
		{
			if(stage)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,onBtnThumbMove);
				stage.removeEventListener(MouseEvent.MOUSE_UP,onBtnThumbUp);
			}
			
			m_btnThumb.addEventListener(MouseEvent.MOUSE_DOWN,onBtnThumbDown);
			m_state = "normal";
		}
		
		
		//------------------------------------------------------------------
		
		private function onAutoRepeatTimer(evt:TimerEvent):void
		{
			m_autoRepeatTimer.delay = 50;
			
			m_curValue += m_baseStepValue;
			
			if(m_curValue < 0)
			{
				m_curValue = 1;
			}
			else if(m_curValue > this.m_maxValue)
			{
				m_curValue = m_maxValue;
			}
			
			updateLayout();
			handleEevent();
		}
	}
}