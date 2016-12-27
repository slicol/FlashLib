package com.tencent.fge.engine.bpe
{
	
	//这是分类学的智慧，BpeComposite与BpeGroup很类似，也可以完全用BpeGroup设置一定的参数模拟出来。
	//但是，如果那样，必然会消夏不必要的计算。因为，作了一个专门的分类。slicol
	public class BpeComposite extends BpeAbstractCollection 
	{
		private var delta:BpeVector;
		
		public function BpeComposite() 
		{
			delta = new BpeVector();
		}
		
		
		public function rotateByRadian(angleRadians:Number, center:BpeVector):void 
		{
			var p:BpeAbstractParticle;
			var pa:Array = particles;
			var len:int = pa.length;
			for (var i:int = 0; i < len; i++) 
			{
				p = pa[i];
				var radius:Number = p.center.distance(center);
				var angle:Number = getRelativeAngle(center, p.center) + angleRadians;
				p.x = (Math.cos(angle) * radius) + center.x;
				p.y = (Math.sin(angle) * radius) + center.y;
			}
		}  
		
		public function rotateByAngle(angleDegrees:Number, center:BpeVector):void 
		{
			var angleRadians:Number = angleDegrees * BpeMathUtil.PI_OVER_ONE_EIGHTY;
			rotateByRadian(angleRadians, center);
		}  
		
		public function get fixed():Boolean 
		{
			for (var i:int = 0; i < particles.length; i++) 
			{
				if (! particles[i].fixed) return false;	
			}
			return true;
		}
	
		public function set fixed(b:Boolean):void 
		{
			for (var i:int = 0; i < particles.length; i++) 
			{
				particles[i].fixed = b;	
			}
		}
		
		private function getRelativeAngle(center:BpeVector, p:BpeVector):Number 
		{
			delta.setTo(p.x - center.x, p.y - center.y);
			return Math.atan2(delta.y, delta.x);
		}		
	}
}