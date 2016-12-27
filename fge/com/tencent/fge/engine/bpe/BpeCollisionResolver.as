package com.tencent.fge.engine.bpe
{
	internal final class BpeCollisionResolver 
	{
		
		internal static function resolveParticleParticle(
			pa:BpeAbstractParticle, 
			pb:BpeAbstractParticle, 
			normal:BpeVector, 
			depth:Number):void 
		{
			
			// a collision has occured. set the current positions to sample locations
			pa.curr.copy(pa.samp);
			pb.curr.copy(pb.samp);
			
			var mtd:BpeVector = normal.mult(depth);           
			var te:Number = pa.elasticity + pb.elasticity;
			var sumInvMass:Number = pa.invMass + pb.invMass;
			
			// the total friction in a collision is combined but clamped to [0,1]
			var tf:Number = clamp(1 - (pa.friction + pb.friction), 0, 1);
			
			// get the collision components, vn and vt
			var ca:BpeCollision = pa.getComponents(normal);
			var cb:BpeCollision = pb.getComponents(normal);
			
			// calculate the coefficient of restitution based on the mass, as the normal component
			var vnA:BpeVector = (cb.vn.mult((te + 1) * pa.invMass).plus(
				ca.vn.mult(pb.invMass - te * pa.invMass))).divEquals(sumInvMass);
			var vnB:BpeVector = (ca.vn.mult((te + 1) * pb.invMass).plus(
				cb.vn.mult(pa.invMass - te * pb.invMass))).divEquals(sumInvMass);
			
			// apply friction to the tangental component
			ca.vt.multEquals(tf);
			cb.vt.multEquals(tf);
			
			// scale the mtd by the ratio of the masses. heavier particles move less 
			var mtdA:BpeVector = mtd.mult( pa.invMass / sumInvMass);     
			var mtdB:BpeVector = mtd.mult(-pb.invMass / sumInvMass);
			
			// add the tangental component to the normal component for the new velocity 
			vnA.plusEquals(ca.vt);
			vnB.plusEquals(cb.vt);
			
			if (! pa.fixed) pa.resolveCollision(mtdA, vnA, normal, depth, -1, pb);
			if (! pb.fixed) pb.resolveCollision(mtdB, vnB, normal, depth,  1, pa);
		}
		
		
		internal static function clamp(input:Number, min:Number, max:Number):Number 
		{
			if (input > max) return max;	
			if (input < min) return min;
			return input;
		} 
	}
}

