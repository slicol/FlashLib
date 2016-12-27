package com.tencent.fge.engine.ui
{
	public class UIUtil
	{
		public static function moveToCenter(ui:UISprite):void
		{
			ui.x = (UISystem.width - ui.width)/2;
			ui.y = (UISystem.height - ui.height)/2;
		}
	}
}