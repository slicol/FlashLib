package com.tencent.fge.engine.bpe
{
	public class BpeClimberParticle extends BpeCircleParticle 
	{
		protected var m_move:BpeVector;
		protected var m_toward:int;


		public function BpeClimberParticle (
			x:Number, 
			y:Number, 
			radius:Number,
			rotation:Number = 0, 
			fixed:Boolean = false,
			mass:Number = 1, 
			elasticity:Number = 0.3,
			friction:Number = 0,
			colliResolver:IBpeCollisionResolver=null) 
		{
			super(x, y, radius, rotation, fixed, mass, 
				elasticity, friction,colliResolver);
			
			m_move = new BpeVector;
			m_toward = 0;
		}

		public function moveBy(dx:Number,dy:Number):void
		{
			if(dx > 0 )
			{
				toward = 1;
			}
			else if(dx < 0)
			{
				toward = -1;
			}
			
			m_move.setTo(dx,dy);
		}
		
		public function moveTo(x:int, y:int, toward:int = 0):void
		{
			this.x = x;
			this.y = y;
			this.toward = toward;
		}
		
		public function fixTo(x:int, y:int, toward:int = 0):void
		{
			this.x = x;
			this.y = y;
			this.toward = toward;
			this.fixed = true;
			this.collidable = false;
		}

		public function get toward():int{return m_toward;}
		public function set toward(t:int):void
		{
			m_toward = t;
			if(t != 0) sprite.scaleX = t;
		}
		
		
		public function overflowTestPoint(x:Number, y:Number):Boolean
		{
			if(x > BPEngine.width - this.radius || x < this.radius || y > BPEngine.height)
			{
				return true;
			}

			return false;
		}
		
		public override function paint():void
		{
			this.sprite.x = curr.x;
			this.sprite.y = curr.y;
			this.sprite.rotation = m_toward != -1? -angle:angle;
		}
		

		public override function update(dt:Number, dt2:Number):void
		{
			if (fixed) return;
			
			if(overflowTestPoint(x, y))
			{
				fixed = true;
				collidable = false;	
				return;
			}
			
			//只受重力影响，不受环境力影响，因为它是攀爬者
			//addForce(BPEngine.force);
			addMasslessForce(BPEngine.masslessForce);
						
			temp.copy(curr);

			
			//之前速度
			var vel:BpeVector = curr.minus(prev);
			if(vel.y < 0) vel.y = 0;
			if(vel.y < 2)
			{
				curr.plusEquals(new BpeVector(0,20));
				curr.plusEquals(m_move);
			}
			else if(vel.y < 5)
			{
				curr.plusEquals(forces);//体验系统
				curr.plusEquals(m_move);
			}
			else
			{
				var s:BpeVector = vel.plus(forces.multEquals(dt));
				s.x = 0;
				curr.plusEquals(s);
	
				if(vel.y < 1)
				{
					curr.plusEquals(m_move);
				}
			}
			
			prev.copy(temp);
			
			
			
			/*
			temp.copy(curr);
			curr.plusEquals(forces);
			curr.plusEquals(m_move);
			prev.copy(temp);
			*/
			
			forces.setTo(0,0);
			m_move.setTo(0,0);
			
			//速度
			this.velocity = curr.minus(prev).mult(1.0/dt);
		}
		
		
		override public function resolveCollisionTo(
			bpeObject:BpeAbstractParticle,rad:Number, 
			v:BpeVector, hold:Boolean):void
		{
			if(bpeObject is BpeGroundParticle)
			{
				//if(!hold)
				{
					//rad是地形的角度
					if(rad > Math.PI/2)
					{
						//"\"地形
						if(toward == -1)
						{
							radian = Math.PI - rad;
						}
						else
						{
							radian = rad - Math.PI;
						}
					}
					else
					{
						//"/"地形
						if(toward == -1)
						{
							radian = -rad;
						}
						else
						{
							radian = rad;
						}
					}
				}
			}			

			
		}		
	}
}