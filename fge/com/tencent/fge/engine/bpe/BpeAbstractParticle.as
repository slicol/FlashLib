package com.tencent.fge.engine.bpe
{
	
	import flash.display.DisplayObject;
	import flash.utils.getQualifiedClassName;
	
	
	public class BpeAbstractParticle extends BpeAbstractObject
	{
		//物理参数（变量）
		internal var curr:BpeVector;//当前坐标
		internal var prev:BpeVector;//之前坐标
		internal var samp:BpeVector;//采样坐标
		internal var temp:BpeVector;//临时坐标
		internal var interval:BpeInterval;
		private var m_velocity:BpeVector;//速度
		private var m_multisample:int;//采样点数
		
		
		//物理参数(不变量)
		private var m_elasticity:Number;//弹性系数
		private var m_mass:Number;//质量
		private var m_invMass:Number;//质量的倒数，便于计算
		private var m_friction:Number;//摩擦系数
		protected var forces:BpeVector;	//加速度
		
		
		//碰撞参数
		internal var collisionResolver:IBpeCollisionResolver;//碰撞处理接口
		private var m_fixed:Boolean;//位置是否固定，即不受力的作用
		private var m_collidable:Boolean;//是否参与碰撞
		private var collision:BpeCollision;//碰撞数据，未用
		private var m_center:BpeVector;//位置
		

		
		public function BpeAbstractParticle (
			x:Number, 
			y:Number, 
			fixed:Boolean, 
			mass:Number, 
			elasticity:Number,
			friction:Number,
			colliResolver:IBpeCollisionResolver = null) 
		{
			if (getQualifiedClassName(this) == "com.tencent.fge.bpe::BpeAbstractParticle") 
			{
				throw new ArgumentError("BpeAbstractParticle can't be instantiated directly");
			}
			
			collisionResolver = colliResolver;
			interval = new BpeInterval(0,0);
			
			curr = new BpeVector(x, y);
			prev = new BpeVector(x, y);
			samp = new BpeVector();
			temp = new BpeVector();
			m_velocity = new BpeVector;
			
			this.fixed = fixed;
			
			forces = new BpeVector();
			collision = new BpeCollision(new BpeVector(), new BpeVector());
			collidable = true;
			
			this.mass = mass;
			this.elasticity = elasticity;
			this.friction = friction;

			m_center = new BpeVector();
			m_multisample = 0;
			
			setStyle();
		}
		
		public function setCollisionResolver(r:IBpeCollisionResolver):void
		{
			collisionResolver = r;
		}
		
		public function setCollisionObject(co:DisplayObject):void
		{
			collisionObject = co;
		}

		/*
		public function setDisplay(d:DisplayObject, 
			offsetX:Number=0, offsetY:Number=0, rotation:Number=0):void 
		{
			displayObject = d;
			displayObjectRotation = rotation;
			displayObjectOffset = new BpeVector(offsetX, offsetY);
			if(!BPEngine.DEBUG)
			{
				sprite.graphics.clear();
			}
		}
		*/
		
		/*
		internal function initDisplay():void 
		{
			displayObject.x = displayObjectOffset.x;
			displayObject.y = displayObjectOffset.y;
			displayObject.rotation = displayObjectRotation;
			sprite.addChild(displayObject);
		}
		*/
		
		internal override function cleanup():void
		{
			super.cleanup();
			this.collisionResolver = null;
		}
				
		
		public function setUserData(d:*):void
		{
			this.userData = d;
		}
		
		public function getUserData():*
		{
			return userData;
		}
		

		public function addForce(f:BpeVector):void 
		{
			forces.plusEquals(f.mult(invMass));
		}
			
		public function addMasslessForce(f:BpeVector):void 
		{
			forces.plusEquals(f);
		}
		
		public function update(dt:Number, dt2:Number):void 
		{
			if (fixed) return;
			
			addForce(BPEngine.force);
			addMasslessForce(BPEngine.masslessForce);
			
			temp.copy(curr);
			var nv:BpeVector = velocity.plus(forces.multEquals(dt2));
			curr.plusEquals(nv.multEquals(BPEngine.damping));
			prev.copy(temp);
			
			forces.setTo(0,0);
		}


		internal function getComponents(collisionNormal:BpeVector):BpeCollision 
		{
			var vel:BpeVector = velocity;
			var vdotn:Number = collisionNormal.dot(vel);
			collision.vn = collisionNormal.mult(vdotn);
			collision.vt = vel.minus(collision.vn);	
			return collision;
		}

		internal function resolveCollision(
			mtd:BpeVector, vel:BpeVector, n:BpeVector, d:Number, o:int, p:BpeAbstractParticle):void 
		{
			curr.plusEquals(mtd);
			velocity = vel;
		}
		
		
		public function resolveCollisionBy(bpeObject:BpeAbstractParticle, rad:Number, vel:BpeVector, hold:Boolean):void
		{
			if(collisionResolver != null)
			{
				//表示该对象被别人碰撞了
				collisionResolver.resolveCollisionBy(bpeObject, rad, vel, hold);
			}			
		}
		
		public function resolveCollisionTo(bpeObject:BpeAbstractParticle, rad:Number, v:BpeVector, hold:Boolean):void
		{
			if(collisionResolver != null)
			{
				//表示该对象被别人碰撞了
				collisionResolver.resolveCollisionTo(bpeObject, rad, v, hold);
			}				
		}


		public function get mass():Number 
		{
			return m_mass; 
		}
		
		public function set mass(m:Number):void 
		{
			if (m <= 0) throw new ArgumentError("mass may not be set <= 0"); 
			m_mass = m;
			m_invMass = 1 / m_mass;
		}	
		
		public function get invMass():Number 
		{
			return (fixed) ? 0 : m_invMass; 
		}		
		
		public function get multisample():int 
		{
			return m_multisample; 
		}
		
		public function set multisample(m:int):void 
		{
			m_multisample = m;
		}
		
		
		public function get center():BpeVector 
		{
			m_center.setTo(x, y)
			return m_center;
		}
		

		internal function get elasticity():Number 
		{
			return m_elasticity; 
		}
		
		internal function set elasticity(k:Number):void 
		{
			m_elasticity = k;
		}
		
		internal function get friction():Number 
		{
			return m_friction; 
		}
		
		internal function set friction(f:Number):void 
		{
			if (f < 0 || f > 1) throw new ArgumentError("Legal friction must be >= 0 and <=1");
			m_friction = f;
		}
		
		public function get fixed():Boolean 
		{
			return m_fixed;
		}
		
		
		public function set fixed(f:Boolean):void 
		{
			m_fixed = f;
		}
		
		public function get position():BpeVector 
		{
			return new BpeVector(curr.x,curr.y);
		}
		
		public function set position(p:BpeVector):void 
		{
			curr.copy(p);
			prev.copy(p);
		}
		
		public function get x():Number {return curr.x;}
		public function get lastX():Number{return prev.x;}
		
		public function set x(value:Number):void 
		{
			curr.x = value;
			prev.x = value;	
		}

		public function get y():Number{return curr.y;}
		public function get lastY():Number{return prev.y;}
		
		public function set y(value:Number):void 
		{
			curr.y = value;
			prev.y = value;	
		}
		
		public function get velocity():BpeVector 
		{
			return m_velocity;
		}
		
		public function set velocity(v:BpeVector):void 
		{
			m_velocity.copy(v);	
		}
		
		public function get collidable():Boolean 
		{
			return m_collidable;
		}
		
		public function set collidable(b:Boolean):void 
		{
			m_collidable = b;
		}
		
		public function isPosChanged():Boolean
		{
			if(int(curr.x) != int(prev.x) || int(curr.y) != int(prev.y))
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		

	}	
}