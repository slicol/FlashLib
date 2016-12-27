package com.tencent.fge.engine.ui.tips
{
	import flash.display.DisplayObject;

	public interface ITipsSprite
	{
		function popup(x:int,y:int,wScreen:int, hScreen:int):void;
		function show():void;
		function hide():void;
		function setTextTips(tipsdata:String):void;
		function setRichTips(tipsdata:DisplayObject):void;
		function setUserTips(tipsdata:*):void;
	}
}