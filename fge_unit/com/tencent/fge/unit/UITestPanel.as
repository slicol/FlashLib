package com.tencent.fge.unit
{
	import com.tencent.fge.foundation.signals.Signal;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.aswing.ASColor;
	import org.aswing.ASFont;
	import org.aswing.JButton;
	import org.aswing.JPanel;
	import org.aswing.JTabbedPane;
	import org.aswing.event.InteractiveEvent;
	
	internal class UITestPanel extends Sprite
	{
		private var m_ui:JTabbedPane;
		
		
		public function UITestPanel()
		{
			super();	
			
			m_ui = new JTabbedPane;
			m_ui.setTabPlacement(JTabbedPane.LEFT);
			m_ui.setForeground(ASColor.RED);
			m_ui.setFont(new ASFont("Arial", 12));
			this.addChild(m_ui);
			
		}
		
		public function setSizeWH(w:int, h:int):void
		{
			m_ui.setSizeWH(w, h);
		}
		
		public function addCase(c:UITestCase):void
		{
			var listItem:Vector.<UITestItem> = c.getTestItemList();
			
			var view:JPanel = new JPanel;
			view.setOpaque(true);
			view.setConstraints(c);
			for(var i:int = 0; i < listItem.length; ++i)
			{
				var item:UITestItem = listItem[i];
				
				var btn:JButton = new JButton(item.id);
				btn.setRollOverEnabled(true);
				btn.setSize(btn.getPreferredSize());
				btn.setToolTipText(item.id);
				btn.setConstraints(item);
				btn.addEventListener(MouseEvent.CLICK, onBtnClick);
				view.append(btn);
			}
			
			m_ui.appendTab(view, c.id);
			m_ui.addEventListener(InteractiveEvent.STATE_CHANGED, onTabSelected);
		}
		

		private function onTabSelected(e:InteractiveEvent):void
		{
			var index:Number = m_ui.getSelectedIndex();
			var c:UITestCase = m_ui.getSelectedComponent().getConstraints() as UITestCase;
			
			onTestCaseSelected.dispatch(c);
		}
		
		
		private function onBtnClick(e:MouseEvent):void
		{
			var btn:JButton = e.target as JButton;
			var item:UITestItem = btn.getConstraints() as UITestItem;

			onTestItemClick.dispatch(item);
		}
		
		public var onTestItemClick:Signal = new Signal(UITestItem);
		public var onTestCaseSelected:Signal = new Signal(UITestCase);
	}
}