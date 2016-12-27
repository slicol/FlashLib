package slicol.starling.sdk.asset
{
	import com.tencent.fge.foundation.signals.Signal;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.events.Request;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class FlAssetLoader extends FlAssetBundle
	{
		public var onComplete:Signal = new Signal(FlAssetLoader);
		public var onError:Signal = new Signal(String, String);
		
		public var url:String = "";

		protected var m_queWork:Array = [];
		protected var m_lstCfgAssetName:Array;
		
		
		
		public function FlAssetLoader()
		{
		}
		
		

		public function load(url:String, listCfgAssetName:Array = null):Boolean
		{
			this.url = url;
			m_lstCfgAssetName = listCfgAssetName;
			
			loadLibrary();
			return true;
		}
		
		
		private function loadLibrary():void
		{
			var urlLibrary:String = url + "/library.xml";
			var ldr:URLLoader = new URLLoader(new URLRequest(urlLibrary));
			ldr.addEventListener(Event.COMPLETE, onLibraryComplete);
			ldr.addEventListener(IOErrorEvent.IO_ERROR, onLdrError);
			
			
			m_queWork = [];
			listTextureAtlas = new Vector.<TextureAtlas>;
			listTextureImageAtlas = new Vector.<FlTextureImageAtlas>;
		}
		
		
		private function onLdrError(e:Event):void
		{
			this.onError.dispatch(e.type, e.toString());
		}
		
		
		private function onLibraryComplete(e:Event):void
		{
			var ldr:URLLoader = e.target as URLLoader;
			var s:String = ldr.data;
			xmlLibrary = new XML(s);
			
			var xmlTextureSheet:XML = xmlLibrary.Item.(@name == "TextureSheet")[0];

			var xlFrame:XMLList = xmlTextureSheet..Frame;
			
			for(var i:int = 0; i < xlFrame.length(); ++i)
			{
				var sIndex:String = numberToString(i+1, 4);
				var urlXml:String = url + "/texture"+sIndex+".xml";
				var urlImg:String = url + "/texture"+sIndex+".png";
				
				var ldrTex:FlTextureLoader = new FlTextureLoader();
				ldrTex.load(urlXml, urlImg);
				ldrTex.onComplete.add(onTextrueComplete);
				ldrTex.onError.add(onTexError);
				
				m_queWork.push(ldrTex);
			}
		}
		
		private function onTexError(type:String, info:String):void
		{
			this.onError.dispatch(type, info);
		}
		
		private function onTextrueComplete(ldr:FlTextureLoader):void
		{
			var i:int = m_queWork.indexOf(ldr);
			m_queWork.splice(i,1);
			
			this.addTextureAtlas(ldr.bitmapData, ldr.xml);
			
			if(m_queWork.length == 0)
			{
				loadCfgAssets();
			}
		}
		
		
		private function loadCfgAssets():void
		{
			if(!m_lstCfgAssetName || m_lstCfgAssetName.length == 0)
			{
				this.onComplete.dispatch(this);
				return;
			}
			
			for(var i:int = 0; i < m_lstCfgAssetName.length; ++i)
			{
				var assetName:String = m_lstCfgAssetName[i];
				var urlAsset:String = url + "/" + assetName;
				
				if(assetName.split(".").length < 2)
				{
					urlAsset = urlAsset + ".xml";
				}

				var ldr:URLLoader = new URLLoader(new URLRequest(urlAsset));
				ldr.addEventListener(Event.COMPLETE, onCfgAssetComplete);
				ldr.addEventListener(IOErrorEvent.IO_ERROR, onCfgAssetError);
				
				mapCfgAsset[assetName] = ldr;
				m_queWork.push(ldr);
			}
		}
		
		
		private function onCfgAssetError(e:Event):void
		{
			var ldr:URLLoader = e.target as URLLoader;
			
			for(var assetName:* in mapCfgAsset)
			{
				if(mapCfgAsset[assetName] == ldr)
				{
					mapCfgAsset[assetName] = null;
					break;
				}
			}
			
			var i:int = m_queWork.indexOf(ldr);
			if(i >= 0)
			{
				m_queWork.splice(i,1);
			}
			
			if(m_queWork.length == 0)
			{
				this.onComplete.dispatch(this);
			}
		}
		
		
		private function onCfgAssetComplete(e:Event):void
		{
			var ldr:URLLoader = e.target as URLLoader;
			var s:String = ldr.data;
			var cfg:XML = new XML(s);
			
			for(var assetName:* in mapCfgAsset)
			{
				if(mapCfgAsset[assetName] == ldr)
				{
					mapCfgAsset[assetName] = cfg;
					break;
				}
			}
			
			var i:int = m_queWork.indexOf(ldr);
			if(i >= 0)
			{
				m_queWork.splice(i,1);
			}
			
			if(m_queWork.length == 0)
			{
				this.onComplete.dispatch(this);
			}
		}
		
		

		


		
		private function deleteItemByNameFromXml(xml:XML, name:String):void
		{
			var xlItem:XMLList = xml..Item;
			var lstIndex:Array = [];
			var i:int = 0;
			
			for(i = 0; i < xlItem.length(); ++i)
			{
				var xmlItem:XML = xlItem[i];
				if(xmlItem.@name == name)
				{
					lstIndex.push(i);
				}
			}
			
			for(i = lstIndex.length - 1; i >= 0; --i)
			{
				delete xlItem[lstIndex[i]];
			}
		}
		
	}
}

