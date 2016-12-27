package slicol.starling.sdk.asset
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class FlTextureImageAtlas
	{
		public var bitmapData:BitmapData;
		public var xml:XML;
		
		public function FlTextureImageAtlas(data:BitmapData, xml:XML)
		{
			this.xml = xml;
			this.bitmapData = data;
		}
		
		public function get name():String
		{
			return xml.@imagePath;
		}
		
		public function get width():Number{return bitmapData.width;}
		public function get height():Number{return bitmapData.height;}
		
		
		public function getBitmapData(name:String):BitmapData
		{
			if(name == this.name)
			{
				return bitmapData.clone();
			}
			
			var rect:Rectangle = getRectData(name);
			if(rect)
			{
				var mat:Matrix = new Matrix();
				mat.translate(-rect.x, -rect.y);
				
				var bmd:BitmapData = new BitmapData(rect.width, rect.height, true, 0);
				bmd.draw(bitmapData, mat, null, null);
				return bmd;
			}
			
			return null;
		}
		
		public function getRectData(name:String):Rectangle
		{
			var xlRect:XMLList = xml.children();
			for each(var xmlRect:XML in xlRect)
			{
				if(String(xmlRect.@name) == name)
				{
					var rect:Rectangle = new Rectangle();
					rect.x = Number(xmlRect.@x);
					rect.y = Number(xmlRect.@y);
					rect.width = Number(xmlRect.@width);
					rect.height = Number(xmlRect.@height);
					return rect;
				}
			}
			return null;
		}
	}
}