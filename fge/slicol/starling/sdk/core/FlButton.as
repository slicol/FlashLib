package slicol.starling.sdk.core
{
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import slicol.starling.sdk.core.i.FlItem;
	
	import starling.display.Button;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	public class FlButton extends FlMovieClip
	{
		private static const MAX_DRAG_DIST:Number = 50;
		
		private var mEnabled:Boolean = true;
		private var mIsDown:Boolean = false;
		private var mUseHandCursor:Boolean = true;
		
		
		public function FlButton(xmlFlDefine:XML, lib:FlLibrary)
		{
			super(xmlFlDefine, lib, 1);
			
			this.currentFrame = 0;
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		override public function dispose():void
		{
			this.removeFromParent();
			this.removeEventListener(TouchEvent.TOUCH, onTouch);
			super.dispose();
		}
		
		private function onTouch(event:TouchEvent):void
		{
			Mouse.cursor = (mUseHandCursor && mEnabled && event.interactsWith(this)) ? 
				MouseCursor.BUTTON : MouseCursor.AUTO;
			
			var touch:Touch = event.getTouch(this);
			if (!mEnabled || touch == null) return;
			
			if (touch.phase == TouchPhase.BEGAN && !mIsDown)
			{
				this.currentFrame = 2;
				mIsDown = true;
			}
			else if (touch.phase == TouchPhase.MOVED && mIsDown)
			{
				// reset button when user dragged too far away after pushing
				var buttonRect:Rectangle = getBounds(stage);
				if (touch.globalX < buttonRect.x - MAX_DRAG_DIST ||
					touch.globalY < buttonRect.y - MAX_DRAG_DIST ||
					touch.globalX > buttonRect.x + buttonRect.width + MAX_DRAG_DIST ||
					touch.globalY > buttonRect.y + buttonRect.height + MAX_DRAG_DIST)
				{
					resetContents();
				}
			}
			else if (touch.phase == TouchPhase.ENDED && mIsDown)
			{
				resetContents();
				dispatchEventWith(Event.TRIGGERED, true);
			}
		}
		
		
		private function resetContents():void
		{
			mIsDown = false;
			this.currentFrame = 0;
		}
		
		/** Indicates if the button can be triggered. */
		public function get enabled():Boolean { return mEnabled; }
		public function set enabled(value:Boolean):void
		{
			if (mEnabled != value)
			{
				mEnabled = value;
				resetContents();
			}
		}
		
		
		
		/** Indicates if the mouse cursor should transform into a hand while it's over the button. 
		 *  @default true */
		public override function get useHandCursor():Boolean { return mUseHandCursor; }
		public override function set useHandCursor(value:Boolean):void { mUseHandCursor = value; }

	}
}