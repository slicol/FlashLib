package com.tencent.fge.engine.bpe
{
	public interface IBpeCollisionResolver
	{
		function resolveCollisionBy(bpeObject:BpeAbstractParticle,rad:Number, v:BpeVector, hold:Boolean):void;
		function resolveCollisionTo(bpeObject:BpeAbstractParticle,rad:Number, v:BpeVector, hold:Boolean):void;
	}
}