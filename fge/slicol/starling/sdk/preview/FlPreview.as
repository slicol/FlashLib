package slicol.starling.sdk.preview
{
	import slicol.starling.sdk.anim.FlAnimator;
	import slicol.starling.sdk.asset.FlAssetLoader;
	import slicol.starling.sdk.core.FlLibrary;
	import slicol.starling.sdk.core.FlStage;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	
	public class FlPreview extends Sprite
	{
		public function FlPreview()
		{
			super();
		}
		
		private var m_url:String = "";
		
		public function load(url:String):void
		{
			this.removeChildren(0,-1,true);
			
			m_url = url;
			var ldr:FlAssetLoader = new FlAssetLoader;
			ldr.load(m_url);
			ldr.onComplete.add(onLoadComplete);
			ldr.onError.addOnce(onError);
		}
		
		private function onError(type:String, info:String):void
		{
			var tf:TextField;
			
			tf = new TextField(this.stage.stageWidth, 30, type);
			tf.y = 0;
			this.addChild(tf);
			
			tf = new TextField(this.stage.stageWidth, 100, info);
			tf.y = 40;
			this.addChild(tf);
		}
		
		
		private function onLoadComplete(ldr:FlAssetLoader):void
		{
			var lib:FlLibrary = new FlLibrary(ldr.xmlLibrary, ldr.listTextureAtlas, ldr.mapCfgAsset);
			
			var stage:FlStage = lib.createItem("Stage") as FlStage;
			this.addChild(stage);
			
			var anim:FlAnimator = lib.createAnimator("Player");
			this.addChild(anim);
		}
	}
}