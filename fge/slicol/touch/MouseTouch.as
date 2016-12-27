package slicol.touch
{
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	public class MouseTouch
	{
		public static var TAP:String =  MouseEvent.MOUSE_DOWN;
		
		public function MouseTouch()
		{
		}
		
		public static function useMouse():void
		{
			TAP = MouseEvent.MOUSE_DOWN;
			Multitouch.inputMode = MultitouchInputMode.NONE;
		}
		
		public static function useTouch():void
		{
			TAP = TouchEvent.TOUCH_TAP;
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		}
	}
}