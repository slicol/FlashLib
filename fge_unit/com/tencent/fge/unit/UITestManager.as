package com.tencent.fge.unit
{
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	public class UITestManager
	{
		private static var m_me:UITestManager;
		
		
		public static function get me():UITestManager
		{
			if(!m_me)
			{
				m_me = new UITestManager;
			}
			return m_me;
		}
		
		public function UITestManager()
		{
		}
		
		
		private var m_stage:Sprite;
		private var m_container:Sprite;
		private var m_panel:UITestPanel;
		private var m_mapCase:Vector.<UITestCase> = new Vector.<UITestCase>;
		private var m_lastTestItem:UITestItem;
		private var m_lastTestCase:UITestCase;
		
		public static function initialize(stage:Sprite, width:int, height:int):void
		{
			me.initialize(stage, width, height);
		}
		
		public function initialize(stage:Sprite, width:int, height:int):void
		{
			m_stage = stage;
			
			m_container = new Sprite;
			m_container.x = m_stage.stage.stageWidth - width;
			
			m_container.graphics.beginFill(0,0);
			m_container.graphics.lineStyle(2,0xff0000);
			m_container.graphics.drawRect(0,0,width,height);
			m_container.graphics.endFill();
			
			m_stage.addChild(m_container);
			
			m_panel = new UITestPanel;
			m_panel.setSizeWH(m_stage.stage.stageWidth - width, m_stage.stage.stageHeight);
			m_panel.onTestItemClick.add(onTestItemClick);
			m_panel.onTestCaseSelected.add(onTestCaseSelected);
			m_stage.addChild(m_panel);
		}
		
		
		public static function addCase(caseClass:Class):void
		{
			me.addCase(caseClass);
		}
		
		
		public function addCase(caseClass:Class):void
		{
			var c:UITestCase = new caseClass();			
			m_mapCase.push(c);
			m_panel.addCase(c);

			selectTestCase(c);
		}
		
		private function onTestItemClick(item:UITestItem):void
		{
			if(m_lastTestItem)
			{
				m_lastTestItem.end();
			}
			
			if(item)
			{
				item.begin();
				item.execute();
			}
			
			m_lastTestItem = item;
		}
		
		
		private function onTestCaseSelected(c:UITestCase):void
		{
			selectTestCase(c);
		}
		
		
		private function selectTestCase(c:UITestCase):void
		{
			if(m_lastTestCase && m_container.contains(m_lastTestCase))
			{
				m_container.removeChild(m_lastTestCase);
			}
			
			if(c)
			{
				m_container.addChild(c);
			}
			
			m_lastTestCase = c;
		}

	}
}