package com.tencent.fge.engine.bpe.debug
{
	import com.tencent.fge.engine.ui.UISprite;
	import com.tencent.fge.engine.ui.UISystem;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public class CollisionZoneView extends UISprite
	{
		private static var ms_instance:CollisionZoneView;
		private var m_bmp:Bitmap = new Bitmap;
		
		public function CollisionZoneView()
		{
			super();
			this.addChild(m_bmp);
			UISystem.addUI("bpe", this);
			this.x = 200;
			this.y = 200;
		}
		
		public static function getInstance():CollisionZoneView
		{
			if(ms_instance == null)
			{
				ms_instance = new CollisionZoneView;
			}
			return ms_instance;
		}
		
		public function set bitmapData(value:BitmapData):void
		{
			m_bmp.bitmapData = value;
		}
		
	}
}