package slicol.engine.phys
{
	import Box2D.Common.Math.b2Transform;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Common.b2Color;
	import Box2D.Dynamics.b2DebugDraw;
	
	import flash.display.Sprite;
	
	import starling.core.Starling;
	import starling.display.Shape;
	
	public class DebugDraw extends b2DebugDraw
	{
		private var m_sprite:Shape;
		
		public function DebugDraw()
		{
			super();
			
			SetDrawScale(PhysWorld.PhysScale2Virtual);
			SetFillAlpha(0.3);
			SetLineThickness(1.0);
			SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			
			var sprite:Sprite = new Sprite;
			Starling.current.nativeStage.addChild(sprite);
			
			SetSprite(sprite);
		}
		
		

		
	}
}