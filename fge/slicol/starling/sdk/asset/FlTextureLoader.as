package slicol.starling.sdk.asset
{
	import com.tencent.fge.foundation.signals.Signal;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class FlTextureLoader
	{
		public var onComplete:Signal = new Signal(FlTextureLoader);
		public var onError:Signal = new Signal(String,String);
		
		public var xml:XML;
		public var bitmapData:BitmapData;
		
		//public var atlas:TextureAtlas;
		//public var image:FlTextureImageAtlas;
		
		private var m_urlXml:String = "";
		private var m_urlImg:String = "";
		
		
		public function FlTextureLoader()
		{
		}
		
		public function load(urlXml:String, urlImg:String):void
		{
			m_urlXml = urlXml;
			m_urlImg = urlImg;
			
			var ldrXML:URLLoader = new URLLoader(new URLRequest(urlXml));
			ldrXML.addEventListener(Event.COMPLETE, onTexXMLComplete);
			ldrXML.addEventListener(IOErrorEvent.IO_ERROR, onLdrError);

			var ldrImg:Loader = new Loader();
			ldrImg.load(new URLRequest(urlImg));
			ldrImg.contentLoaderInfo.addEventListener(Event.COMPLETE, onTexImgComplete);
			ldrImg.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLdrError);
		}
		
		private function onLdrError(e:Event):void
		{
			this.onError.dispatch(e.type, e.toString());
		}
		
		
		private function onTexXMLComplete(e:Event):void
		{
			var ldrXML:URLLoader = e.target as URLLoader;
			var s:String = ldrXML.data;
			xml = new XML(s);
			
			handleComplete();
		}
		

		private function onTexImgComplete(e:Event):void
		{
			var ldrImg:LoaderInfo = e.target as LoaderInfo;
			var bmp:Bitmap = ldrImg.content as Bitmap;
			bitmapData = bmp.bitmapData;
			
			
			handleComplete();
		}
		
		
		private function handleComplete():void
		{
			if(xml && bitmapData)
			{
				this.onComplete.dispatch(this);
			}
		}
		
		
	}
}