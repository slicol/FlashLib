package slicol.starling.sdk.asset
{
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class FlAssetBundle 
	{	
		public var xmlLibrary:XML;
		public var listTextureAtlas:Vector.<TextureAtlas> = new Vector.<TextureAtlas>;
		public var listTextureImageAtlas:Vector.<FlTextureImageAtlas> = new Vector.<FlTextureImageAtlas>;
		public var mapCfgAsset:Dictionary = new Dictionary;

		public function FlAssetBundle()
		{
			
		}
		
		public function addTextureAtlas(bitmapData:BitmapData, xml:XML):void
		{
			var tex:Texture = Texture.fromBitmapData(bitmapData,true, true);
			var atlas:TextureAtlas = new TextureAtlas(tex, xml);
			listTextureAtlas.push(atlas);
			
			var image:FlTextureImageAtlas = new FlTextureImageAtlas(bitmapData, xml);
			listTextureImageAtlas.push(image);
		}
	
		

		protected static function numberToString(num:int, len:int):String
		{
			var n:String = num.toString();
			while(n.length < len)
			{
				n = "0" + n;
			}
			return n;
		}
	}
}