package slicol.engine.object
{
	import Box2D.Common.Math.b2Transform;
	
	import slicol.engine.phys.PhysWorld;
	import slicol.engine.scene.SceneSystem;
	import slicol.engine.slicol_engine_internal;
	
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	
	public class RenderComponent extends ComponentObject
	{
		public var sprite:GameSprite;
		
		public function RenderComponent(type:String="", id:String="")
		{
			super(type, id);
		}
		
		override public function dispose():void
		{
			if(sprite)
			{
				sprite.dispose();
				sprite = null;
			}
			
			super.dispose();
		}
		
		override internal function _start():void
		{
			if(sprite)
			{
				SceneSystem.me.currentScene.addGameSprite(sprite);
			}
			
			start();
		}
		
		override public function lateUpdate():void
		{
			var xf:b2Transform = gameObject.m_xf;
			sprite.x = xf.position.x * PhysWorld.PhysScale2Virtual;
			sprite.y = xf.position.y * PhysWorld.PhysScale2Virtual;
			sprite.rotation = xf.GetAngle() * (180/Math.PI);
			
		}
		
		public function customRender(support:RenderSupport, parentAlpha:Number):void
		{
			
		}
		
		
		
		
	}
}