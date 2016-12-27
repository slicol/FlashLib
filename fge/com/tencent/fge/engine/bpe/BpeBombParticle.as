package com.tencent.fge.engine.bpe
{
	public class BpeBombParticle extends BpeCircleParticle 
	{
		private var m_vel0:BpeVector = new BpeVector();
		private var m_pos0:BpeVector = new BpeVector();
		private var m_time:Number = 0;
		
		//物理参数（不变量）
		public var coefAirResist:Number = 1;
		public var coefGravity:Number = 1;
		public var coefWindForce:Number = 1;
		
		
		
		//调试参数
		

		//弹道调优：mass，质量
		public function BpeBombParticle (
			x:Number, 
			y:Number, 
			radius:Number,
			mass:Number, 
			coefAirResist:Number,
			coefGravity:Number,
			coefWindForce:Number,
			colliResolver:IBpeCollisionResolver=null) 
		{
			super(x, y, radius, 0, false, mass, 0, 0,colliResolver);
			this.coefAirResist = coefAirResist;
			this.coefGravity = coefGravity;
			this.coefWindForce = coefWindForce;
		}
		
		//弹道调优：
		//dt0,力度作用时间
		//kv, 风阻系统，根据不同的公式，取不同的值。
		public function fireWorker(s0:BpeVector, f0:BpeVector, dt0:Number=1):void
		{
			this.position = s0;
			m_pos0 = s0;
			m_vel0 = f0.mult(dt0).mult(invMass);
			m_time = 0;
			this.velocity.copy(m_vel0);
		}

		public override function update(dt:Number, dt2:Number):void
		{
			if (fixed) return;
			
			
			
			//受重力影响
			this.addMasslessForce(BPEngine.masslessForce.mult(coefGravity));
			
			//受环境力影响,为什么每次都计算，因为环境可能会变
			this.addForce(BPEngine.force.mult(coefWindForce));
			
			//空气阻力
			this.addForce(this.velocity.mult(-this.coefAirResist*BPEngine.coefAirResist));
			
			//速度
			this.velocity.plusEquals(this.forces.mult(dt));

			//位移			
			temp.copy(curr);
			curr.plusEquals(this.velocity.mult(dt));
			prev.copy(temp);
			
			//角度
			this.radian = Math.atan2(velocity.y, velocity.x);

			//清除作用力
			forces.setTo(0,0);
			
		}
		
		
			
	}
}


/*
public override function update(dt:Number, dt2:Number):void
{
	if (fixed) return;
	
	//受重力影响
	this.addMasslessForce(BPEngine.masslessForce);
	
	//受环境力影响,为什么每次都计算，因为环境可能会变
	this.addForce(BPEngine.force);
	
	//公式
	//Sx = Vx0*t + 0.5*a*(t*t)
	//Sy = Vy0*t + 0.5*a*(t*t)
	
	m_timex += dt;
	temp.copy(curr);
	curr.setTo(0,0);
	curr.plusEquals(m_vel0.mult(m_timex));
	curr.plusEquals(forces.multEquals(0.5 * m_timex * m_timex));
	curr.multEquals(10);//这是一个体验系统。
	curr.plusEquals(m_pos0);
	prev.copy(temp);
	
	//速度
	this.velocity = curr.minus(prev).mult(1.0/dt);
	this.radian = Math.atan2(velocity.y, velocity.x);

	//清除作用力
	forces.setTo(0,0);
}
*/


/*
		public function update_bak0506(dt:Number, dt2:Number):void
		{
			if (fixed) return;
			
			//受重力影响
			this.addMasslessForce(BPEngine.masslessForce);
			
			//受环境力影响,为什么每次都计算，因为环境可能会变
			this.addForce(BPEngine.force);
			
			//公式
			m_time += dt;//当前时刻
			temp.copy(curr);//保存当前位置
			
			//计算新的位置
			curr.copy(getBombPoint(m_pos0, m_vel0, forces, m_Kvel, m_time, 1));
			prev.copy(temp);
			
			//速度
			this.velocity = curr.minus(prev).mult(1.0/dt);
			this.radian = Math.atan2(velocity.y, velocity.x);

			//清除作用力
			forces.setTo(0,0);
		}
		
		
		//公式0，kv默认取0.9,step默认取1
		public function getBombPoint(
			s0:BpeVector, v0:BpeVector, a:BpeVector, kv:Number,
			t:Number, step:Number):BpeVector
		{
			var v:BpeVector = v0.clone();
			var s:BpeVector = s0.clone();
			var ds:BpeVector;
			var ti:Number;
			var dt:Number = step;
			var dt2:Number = step*step;
			
			for(ti = dt; ti < t; ti += dt)
			{
				ds = v.mult(dt).plus(a.mult(0.5*dt2));
				s.plusEquals(ds);
				v.plusEquals(a.mult(dt));
				v.multEquals(kv);
			}
			
			dt = dt - (ti - t);
			dt2 = dt*dt;
			ds = v.mult(dt).plus(a.mult(0.5*dt2));
			s.plusEquals(ds);
			return s;		
		}	


		//公式1，kv默认取0.9,step默认取35
		public function getBombPoint1(
			s0:BpeVector, v0:BpeVector, a:BpeVector, kv:Number,
			t:Number, step:Number):BpeVector
		{
			var s:BpeVector = s0.clone();

			s.y = s.y + v0.y*t + 0.5*a.y*t*t;
			s.x = s.x + v0.x*t*kv*(1-t/step) + 0.5*a.x*t*t;
			
			return s;
		}
			
					
		//公式3，kv默认取0.1，step无效
		public function getBombPoint2(
			s0:BpeVector, v0:BpeVector, a:BpeVector, kv:Number,
			t:Number, step:Number):BpeVector
		{
			var s:BpeVector = s0.clone();
			var T:Number = -v0.y/a.y;
			
			s.y = s.y + v0.y*t + 0.5*a.y*t*t;
			
			if(t < T)
			{
				s.x = s.x + v0.x*t + 0.5*a.x*t*t;
			}
			else
			{
				t = t - T;
				s.x = s.x + v0.x*T + 0.5*a.x*T*T;
				s.x = s.x + (v0.x + a.x*t)*t + 0.5*(a.x-v0.x*kv)*t*t;
			}
			
			return s;
		}
 */