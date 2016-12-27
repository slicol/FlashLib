package slicol.engine.object
{
	import slicol.engine.slicol_engine_internal;
	
	import starling.display.Sprite;
	
	use namespace slicol_engine_internal;
	
	public class GameSprite extends Sprite
	{
		public var z:Number = 0;
		
		public function GameSprite()
		{
			super();
		}
		
		override public function dispose():void
		{
			this.removeFromParent();
			super.dispose();
		}
		
		
		//更新层叠关系
		slicol_engine_internal static function updateHierarchy(lst:*):void
		{
			lst.sort(_compareZ);
			
			for(var i:int = lst.length - 1; i >= 0; --i)
			{
				var sprite:GameSprite = lst[i];
				sprite.parent.setChildIndex(sprite, i); 
			}
		}
		
		private static function _compareZ(a:GameSprite, b:GameSprite):Number
		{
			return a.z - b.z;
		}
		
	}
}