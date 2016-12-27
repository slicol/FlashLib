package slicol.starling.sdk.fsm
{
	import com.tencent.fge.foundation.signals.Signal;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class FSMLoader
	{
		public var onComplete:Signal = new Signal(FSMLoader);
		public var onError:Signal = new Signal(String, String);
		
		public var content:XML;
		
		public function FSMLoader()
		{
		}
	
		public function load(url:String):void
		{
			
			var ldr:URLLoader = new URLLoader(new URLRequest(url));
			ldr.addEventListener(Event.COMPLETE, onLdrComplete);
			ldr.addEventListener(IOErrorEvent.IO_ERROR, onLdrError);
			
		}
		
		private function onLdrError(e:Event):void
		{
			this.onError.dispatch(e.type, e.toString());
		}
		
		
		private function onLdrComplete(e:Event):void
		{
			var ldr:URLLoader = e.target as URLLoader;
			var s:String = ldr.data;
			content = new XML(s);
			
			this.onComplete.dispatch(this);
		}
	}
}