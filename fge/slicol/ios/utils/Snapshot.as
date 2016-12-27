package slicol.ios.utils
{
	import com.adobe.images.PNGEncoder;
	import com.tencent.fge.engine.graphic.SnapshotUtil;
	import com.tencent.fge.engine.ui.keyboard.VirtualKeyboard;
	import com.tencent.fge.utils.ClassUtil;
	import com.tencent.fge.utils.DateUtil;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class Snapshot
	{
		private static var ms_target:Sprite;
		
		public function Snapshot()
		{
		}
		
		
		public static function attach(target:Sprite):void
		{
			ms_target = target;
			
			target.addEventListener(MouseEvent.RIGHT_CLICK, onRClick);

		}
		
		private static function onRClick(e:Event):void
		{
			save();
		}
		
		public static function save():void
		{
			if(!ms_target)
			{
				return;
			}
			
			var name:String = DateUtil.formatToString(new Date, ["","","","",""]);
			name = ClassUtil.getName(ms_target) + "_" + name + ".png";
			
			var bmd:BitmapData = SnapshotUtil.snapshot(ms_target);
			var data:ByteArray = PNGEncoder.encode(bmd);
			
			var f:File = File.desktopDirectory;
			f = f.resolvePath(name);
			
			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
	}
}