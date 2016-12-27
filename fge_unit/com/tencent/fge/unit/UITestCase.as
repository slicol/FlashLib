package com.tencent.fge.unit
{	
	import com.tencent.fge.utils.ClassUtil;
	
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import org.aswing.JLabel;

	public class UITestCase extends Sprite
	{
		private var m_id:String = "";
		private var m_listItem:Vector.<UITestItem> = new Vector.<UITestItem>;
		private var m_mapItem:Dictionary = new Dictionary;
		
		private var m_lblLog:JLabel;
		
		public function UITestCase()
		{
			m_id = ClassUtil.getName(this);
			
			m_lblLog = new JLabel();
			
		}
		
		internal function get id():String
		{
			return m_id;
		}
		
		public function addTestItem(name:String, func:Function, ...argsValues):void
		{
			var item:UITestItem = new UITestItem;
			item.name = name;
			item.func = func;
			item.argsValues = argsValues;
			item.owner = this;
			m_listItem.push(item);
			
			m_mapItem[item.id] = item;
		}
		
		public function log(s:String):void
		{
			m_lblLog.setText(m_lblLog.getText() + s + "\n");
			m_lblLog.setSize(m_lblLog.getPreferredSize());
			this.addChild(m_lblLog);
		}
		
		internal function getTestItemList():Vector.<UITestItem>
		{
			return m_listItem;
		}
		
		
		internal function beginItem(item:UITestItem):void
		{
			try
			{
				m_lblLog.setText("");
				log("正在启动: " + this.id);
				
				begin();
				
				log("开始测试: " + this.id + "::" + item.id);
			}
			catch(e:Error)
			{
				log("无法启劝: " + this.id);
			}
		}
		
		internal function endItem():void
		{
			if(this.contains(m_lblLog))
			{
				this.removeChild(m_lblLog);
			}
			
			try
			{
				end();
			}
			catch(e:Error)
			{
				
			}
			
		}
		
		
		protected function begin():void
		{
			
		}
		
		protected function end():void
		{
			
		}
	}
}



	