package slicol.engine.phys
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2World;
	
	import flash.utils.getTimer;
	
	import slicol.foundation.singleton.SingletonFactory;
	
	import starling.display.Shape;
	import starling.display.Sprite;
	
	
	/**
	 * Box2D使用MKS(m/kg/s，米/千克/秒)作为单位，角度使用弧度。
	 **/
	public class PhysWorld extends b2World
	{
		public static function get me():PhysWorld
		{
			return SingletonFactory.getInstance(PhysWorld);		
		}
		
		//-----------------------------------------------------------------
		/**
		 * 这是真实世界->屏幕世界的度量转换系数 = 屏幕世界(虚拟世界) / 物理世界（真实世界）
		 **/
		public static var PhysScale2Virtual:Number = 1024/0.1;
		
		/**
		 * 重力系数，一般取9.8
		 **/
		public static var PhysGravity:Number = 0.1;
		
		/**
		 * 单位是秒,和FPS有关系，这里默认是60FPS
		 **/
		public static var PhysTimeStep:Number = 1/60;
		
		
		public static var PhysVelocityIterations:int = 30;
		public static var PhysPositionIterations:int = 30;

		//-----------------------------------------------------------------
		

		public function PhysWorld()
		{
			super(new b2Vec2(0, PhysGravity), true);
		}
		
		public function init(root:Sprite):void
		{
			SetWarmStarting(true);
			
			var dbgDraw:DebugDraw = new DebugDraw();
			this.SetDebugDraw(dbgDraw);
		
		}
		
		public function update():void
		{
			// Update physics
			Step(PhysTimeStep, PhysVelocityIterations,	PhysPositionIterations);
			ClearForces();
			
			//Render-Debug
			DrawDebugData();
		}
	}
}