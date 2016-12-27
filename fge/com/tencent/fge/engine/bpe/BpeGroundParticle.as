package com.tencent.fge.engine.bpe
{
	public class BpeGroundParticle extends BpeRectParticle 
	{
		public function BpeGroundParticle (
			x:Number, 
			y:Number, 
			width:Number, 
			height:Number, 
			rotation:Number = 0, 
			fixed:Boolean = false,
			mass:Number = 1, 
			elasticity:Number = 0.3,
			friction:Number = 0,
			colliResolver:IBpeCollisionResolver=null) 
		{
			super(x, y, width, height, rotation, fixed, mass, elasticity, friction,colliResolver);
		}
	}
}