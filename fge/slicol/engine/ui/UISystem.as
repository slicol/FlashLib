package slicol.engine.ui
{;
	
	import slicol.engine.slicol_engine_internal;
	import slicol.foundation.singleton.SingletonFactory;
	
	import starling.display.Sprite;
	
	use namespace slicol_engine_internal;
	
	public class UISystem extends Sprite
	{
		public static function get me():UISystem
		{
			return SingletonFactory.getInstance(UISystem);		
		}
		
		//-----------------------------------------------------------------
		
		public function UISystem()
		{
			super();
		}
		
		
		slicol_engine_internal function init(root:Sprite):void
		{
			root.addChild(this);
		}
		
		
		
		//-----------------------------------------------------------------
		//UIPage
		//-----------------------------------------------------------------
		private var m_pageStack:Vector.<UIPage> = new Vector.<UIPage>;
		
		
		public function get page():UIPage
		{
			if(m_pageStack.length > 0)
			{
				return m_pageStack[m_pageStack.length - 1];
			}
			return null;
		}
		
		public function enterPage(id:String, effect:String = ""):void
		{
			var page:UIPage = UIPage.find(id);
			var curPage:UIPage;
			
			if(m_pageStack.length > 0)
			{
				curPage = m_pageStack[m_pageStack.length - 1];
			}
			
			if(curPage == page)
			{
				return;
			}
			
			if(curPage)
			{
				this.removeChild(curPage);
				curPage.hide();
			}
			
			curPage = page;
			
			if(curPage)
			{
				this.addChild(curPage);
				curPage.show();
				m_pageStack.push(curPage);
			}
		}
		
		public function leavePage(id:String):void
		{
			var page:UIPage = UIPage.find(id);
			var curPage:UIPage;
			
			if(m_pageStack.length > 0)
			{
				curPage = m_pageStack[m_pageStack.length - 1];
			}
			
			if(curPage != page)
			{
				return;
			}
			
			if(curPage)
			{
				this.removeChild(curPage);
				curPage.hide();
			}
			
			m_pageStack.pop();
			
			if(m_pageStack.length > 0)
			{
				curPage = m_pageStack[m_pageStack.length - 1];
			}
			
			if(curPage)
			{
				this.addChild(curPage);
				curPage.show();
			}
		}
		
		public function addDynamicUI(ui:UISprite):void
		{
			var curPage:UIPage;
			
			if(m_pageStack.length > 0)
			{
				curPage = m_pageStack[m_pageStack.length - 1];
				curPage.addDynamicUI(ui);
			}
	
		}
		
		public function removeDynamicUI(ui:UISprite):void
		{
			var curPage:UIPage;
			
			if(m_pageStack.length > 0)
			{
				curPage = m_pageStack[m_pageStack.length - 1];
				curPage.removeDynamicUI(ui);
			}
		}
		

		//-----------------------------------------------------------------
		
		public function show():void
		{
			this.visible = true;
		}
		
		public function hide():void
		{
			this.visible = false;
		}
		
		//-----------------------------------------------------------------
		private var m_curPage:UIPage;
		
		slicol_engine_internal function update():void
		{
			if(!m_curPage)
			{
				if(m_pageStack.length > 0)
				{
					m_curPage = m_pageStack[m_pageStack.length - 1];
				}
			}
			
			if(m_curPage)
			{
				m_curPage.update();
			}
		}
	}
}