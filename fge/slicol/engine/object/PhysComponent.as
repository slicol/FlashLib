package slicol.engine.object
{
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Transform;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FixtureDef;
	
	import slicol.engine.phys.PhysWorld;

	public class PhysComponent extends ComponentObject
	{
		protected var physWorld:PhysWorld;
		
		public var body:b2Body;
		public var define:b2BodyDef = new b2BodyDef;
		
		
		public function PhysComponent(type:String="", id:String="")
		{
			super(type, id);
			physWorld = PhysWorld.me;
			
			body = physWorld.CreateBody(define);
		}
		
		override public function dispose():void
		{
			if(body)
			{
				physWorld.DestroyBody(body);
				body = null;
			}
			
			super.dispose();
		}
		
	
		override internal function _start():void
		{
			gameObject.m_xf = body.GetTransform();
			start();
		}
		
		
		//phys->gameobject
		override public function fixedUpdate():void
		{

		}
		
		override public function lateUpdate():void
		{
			
		}
		
		
		//--------------------------------------------------------------------

		public function addBox(w:Number, h:Number, density:Number):void
		{
			w = w/PhysWorld.PhysScale2Virtual;
			h = h/PhysWorld.PhysScale2Virtual;
			
			var shp:b2PolygonShape = new b2PolygonShape;

			shp.SetAsBox(w/2, h/2);
			
			var defFix:b2FixtureDef = new b2FixtureDef;
			defFix.shape = shp;
			defFix.density = density;
			defFix.friction = 0.5;
			defFix.restitution = 0;
			
			
			body.CreateFixture(defFix);
		}
		
		
		public function addRandomPolygon(size:Number, side:int , density:Number):void
		{
			size = size/PhysWorld.PhysScale2Virtual;
			size = size/2;
			
			var shp:b2PolygonShape = new b2PolygonShape;
			var i:int;
			var tmp:Number = 1/(3*side);
			var lstVec:Array = new Array;
			for(i = 0; i < side; ++i)
			{
				var vec:b2Vec2 = new b2Vec2();
				var angle:Number = (Math.PI*2 * Math.random() * tmp) + i * 3 * tmp * Math.PI *2;
				vec.x = size * Math.cos(angle);
				vec.y = size * Math.sin(angle);
				lstVec.push(vec);
			}
			
			shp.SetAsArray(lstVec, side);
			
			var defFix:b2FixtureDef = new b2FixtureDef;
			defFix.shape = shp;
			defFix.density = density;
			defFix.friction = 0.5;
			defFix.restitution = 0;
			
			body.CreateFixture(defFix);
		}
	}
}