package com.tencent.fge.engine.ui.component
{
	import com.tencent.fge.engine.ui.UIMovieClipCtlBase;
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	public class CtlProgressBar extends UIMovieClipCtlBase
	{		
		private var m_txtValue:TextField;
		private var m_mskValue:MovieClip;
		
		public function CtlProgressBar(ui:MovieClip):void
		{
			super(ui);
			
			m_txtValue = m_ui["txtValue"];
			m_mskValue = m_ui["mskValue"];
			
			if(m_mskValue == null)
			{
				throw new ArgumentError("UI格式错误：缺少mskValue实例。");
			}
		}
		
		
		public function setProgress(value:Number, htmlText:String = ""):void
		{
			if(m_txtValue)
			{
				if(!htmlText)
				{
					m_txtValue.text = (int(value * 100)).toString() + "%";
				}
				else
				{
					m_txtValue.htmlText = htmlText;
				}
			}
			
			if(value <= 0)
			{
				m_mskValue.scaleX = 0;
			}
			else if(value >= 0.99)
			{
				m_mskValue.scaleX = 1;
			}
			else
			{
				m_mskValue.scaleX = value;
			}
		}
		

	}
}