package com.tencent.fge.mxml.utils
{
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;

	public class DragUtils
	{
		public function DragUtils()
		{
		}
		
		public static function handleMouseEvent(e:MouseEvent):void
		{
			var ui:UIComponent = e.currentTarget as UIComponent;
			
			if(e.type == MouseEvent.MOUSE_DOWN)
			{
				var tmp:Object = ui;
				if(tmp.hasOwnProperty("uiDragZone"))
				{
					var rt:Rectangle = tmp["uiDragZone"];
					if(rt.contains(ui.mouseX, ui.mouseY))
					{
						ui.startDrag();
					}
				}
				else
				{
					ui.startDrag();
				}
				
			}
			else if(e.type == MouseEvent.MOUSE_UP)
			{
				ui.stopDrag();
			}
		}
	}
}