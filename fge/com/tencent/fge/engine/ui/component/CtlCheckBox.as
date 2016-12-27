package com.tencent.fge.engine.ui.component
{
	/**
	 * 1 selected_mouseout
	 * 2 selected_mouseover
	 * 3 unselected_mouseout
	 * 4 unselected_mouseover
	 */
	
	import com.tencent.fge.engine.ui.UIMovieClipCtlBase;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class CtlCheckBox extends UIMovieClipCtlBase
	{		
		private var m_selected:Boolean = false;
		private var m_state:String = MouseEvent.MOUSE_OUT;
		
		public function CtlCheckBox(ui:MovieClip):void
		{
			super(ui);
			
			m_ui.addEventListener(MouseEvent.MOUSE_OVER, onMouseEvent);
			m_ui.addEventListener(MouseEvent.MOUSE_OUT, onMouseEvent);
			m_ui.addEventListener(MouseEvent.CLICK, onClick);
			
			m_ui.useHandCursor = true;
			m_ui.buttonMode = true;
			
			if(m_ui.totalFrames < 4)
			{
				throw new ArgumentError("UI资源格式错误：应该有4帧，当前只有"+m_ui.totalFrames+"帧");
			}
			
			updateView();
		}
		
		
		private function onMouseEvent(e:MouseEvent):void
		{
			var change:Boolean = m_state != e.type;
			m_state = e.type;
			
			if(change)
			{
				updateView();
			}
		}
		
		public function get selected():Boolean
		{
			return m_selected;
		}
		
		public function set selected(value:Boolean):void
		{
			var change:Boolean = m_selected != value;
			m_selected = value;
			
			if(change)
			{
				updateView();
			}
		}
		
		
		private function onClick(e:MouseEvent):void
		{
			selected = !selected;
			this.dispatchEvent(e);
		}
		
		
		private function updateView():void
		{
			switch(m_state)
			{
				case MouseEvent.MOUSE_OVER:
					m_ui.gotoAndStop(m_selected ? 2 : 4);
					break;
				
				case MouseEvent.MOUSE_OUT:
					m_ui.gotoAndStop(m_selected ? 1 : 3);
					break;
			}			
		}
	}
}