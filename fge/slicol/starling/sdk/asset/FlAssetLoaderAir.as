package slicol.starling.sdk.asset
{
	import com.tencent.fge.air.file.utils.FileUtil;
	import com.tencent.fge.codec.PNGDecoder;
	
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.utils.ByteArray;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class FlAssetLoaderAir extends FlAssetBundle
	{
		public var url:String = "";
		protected var m_lstCfgAssetName:Array;
		
		private var m_lastError:Error;
		public function get lastError():Error{return m_lastError;}
		
		public function FlAssetLoaderAir()
		{
			super();
		}
		
		public function load(url:String, listCfgAssetName:Array = null):Boolean
		{
			this.url = url;
			m_lstCfgAssetName = listCfgAssetName;
			
			var ret:Boolean = loadLibrary();
			ret = ret && loadTextureAtlas();
			ret = ret && loadCfgAssets();
			return ret;
		}
		
		private function loadLibrary():Boolean
		{
			var urlLibrary:String = url + "/library.xml";
			
			var xml:XML = FileUtil.openXmlFile(urlLibrary);
			if(!xml)
			{
				m_lastError = FileUtil.lastError;
				return false;
			}
			xmlLibrary = xml;
	
			return true;
		}
		
		private function loadTextureAtlas():Boolean
		{
			listTextureAtlas = new Vector.<TextureAtlas>;
			listTextureImageAtlas = new Vector.<FlTextureImageAtlas>;
			
			var xmlTextureSheet:XML = xmlLibrary.Item.(@name == "TextureSheet")[0];
			var xlFrame:XMLList = xmlTextureSheet..Frame;
			var err:Error;
			
			for(var i:int = 0; i < xlFrame.length(); ++i)
			{
				var sIndex:String = numberToString(i+1, 4);
				var urlXml:String = url + "/texture"+sIndex+".xml";
				var urlImg:String = url + "/texture"+sIndex+".png";
				
				var xml:XML = FileUtil.openXmlFile(urlXml);
				if(!xml)
				{
					m_lastError = FileUtil.lastError;
					return false;
				}
				
				var imgData:ByteArray = FileUtil.openDataFile(urlImg);
				if(!imgData)
				{
					m_lastError = FileUtil.lastError;
					return false;
				}
				
				imgData.position = 0;
				
				var bmd:BitmapData = PNGDecoder.decodeImage(imgData);
				
				this.addTextureAtlas(bmd, xml);
			}
			
			return true;
		}
		

		
		private function loadCfgAssets():Boolean
		{
			if(!m_lstCfgAssetName || m_lstCfgAssetName.length == 0)
			{
				return true;
			}
			
			for(var i:int = 0; i < m_lstCfgAssetName.length; ++i)
			{
				var assetName:String = m_lstCfgAssetName[i];
				var urlAsset:String = url + "/" + assetName;
				
				if(assetName.split(".").length < 2)
				{
					urlAsset = urlAsset + ".xml";
				}
				
				var xml:XML = FileUtil.openXmlFile(urlAsset);
				mapCfgAsset[assetName] = xml;
			}
			
			return true;
		}
		
		
		
		
		
		
		
		
	}
}