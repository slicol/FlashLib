package com.tencent.fge.engine.bpe
{
	import flash.utils.getQualifiedClassName;
	
	public class BpeAbstractCollection 
	{
		private var m_particles:Array;
		private var m_constraints:Array;
		private var m_isParented:Boolean;
		
		
		public function BpeAbstractCollection() 
		{
			if (getQualifiedClassName(this) == "com.tencent.fge.bpe::BpeAbstractCollection") 
			{
				throw new ArgumentError("BpeAbstractCollection can't be instantiated directly");
			}
			m_isParented = false;
			m_particles = new Array();
			m_constraints = new Array();
		}
		
		public function get particles():Array
		{
			return m_particles;
		}
		
		
		public function get constraints():Array 
		{
			return m_constraints;	
		}
		
		

		public function addParticle(p:BpeAbstractParticle):void 
		{
			particles.push(p);
			if (isParented) p.initialize();
		}
		
		

		public function removeParticle(p:BpeAbstractParticle):void 
		{
			var ppos:int = particles.indexOf(p);
			if (ppos == -1) return;
			particles.splice(ppos, 1);
			p.cleanup();
		}
		
		public function removeAllParticle():void
		{
			for(var i:int = 0; i < particles.length; ++i)
			{
				var p:BpeAbstractParticle = particles[i];
				if(p)
				{
					p.cleanup();
				}
			}
			particles.length = 0;
		}


		public function initialize():void 
		{
			var p:BpeAbstractObject;
			for (var i:int = 0; i < particles.length; i++) 
			{
				p = particles[i];
				p.initialize();	
			}
			for (i = 0; i < constraints.length; i++) 
			{
				p = constraints[i];
				p.initialize();
			}
		}
		
		public function cleanup():void 
		{
			for (var i:int = 0; i < particles.length; i++) 
			{
				particles[i].cleanup();	
			}
			for (i = 0; i < constraints.length; i++) 
			{
				constraints[i].cleanup();
			}
		}		

		public function paint():void 
		{
			var p:BpeAbstractParticle;
			var len:int = m_particles.length;
			for (var i:int = 0; i < len; i++) 
			{
				p = m_particles[i];
				if ((! p.fixed) || p.alwaysRepaint)
				{
					p.paint();
				}	
			}
		}


		public function getAllChildren():Array 
		{
			return particles.concat(constraints);
		}	
		
		
		internal function get isParented():Boolean 
		{
			return m_isParented;
		}	
		
		
		internal function set isParented(b:Boolean):void 
		{
			m_isParented = b;
		}	
		
		
		internal function integrate(dt:Number, dt2:Number):void 
		{
			var len:int = m_particles.length;
			for (var i:int = 0; i < m_particles.length; i++) 
			{
				var p:BpeAbstractParticle = m_particles[i];
				p.update(dt, dt2);	
			}
		}		
		

		internal function checkInternalCollisions():void 
		{
			var plen:int = m_particles.length;
			for (var j:int = 0; j < plen; j++) 
			{
				var pa:BpeAbstractParticle = m_particles[j];
				if (! pa.collidable) continue;
				
				for (var i:int = j + 1; i < plen; i++) 
				{
					var pb:BpeAbstractParticle = m_particles[i];
					if (pb.collidable) BpeCollisionDetector.test(pa, pb);
				}
			}
		}
		
		internal function checkCollisionsVsCollection(ac:BpeAbstractCollection):void 
		{
			var plen:int = m_particles.length;
			for (var j:int = 0; j < plen; j++) 
			{
				var pga:BpeAbstractParticle = m_particles[j];
				if (pga == null || ! pga.collidable) continue;
				
				var acplen:int = ac.particles.length;
				for (var x:int = 0; x < acplen; x++) 
				{
					var pgb:BpeAbstractParticle = ac.particles[x];
					if (pgb.collidable) BpeCollisionDetector.test(pga, pgb);
				}
				
			}

		}			
	}
}


