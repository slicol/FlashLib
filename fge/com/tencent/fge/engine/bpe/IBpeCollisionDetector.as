package com.tencent.fge.engine.bpe
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public interface IBpeCollisionDetector
	{
		function test(objA:BpeAbstractParticle, objB:BpeAbstractParticle):BpeCollision;
	}
}