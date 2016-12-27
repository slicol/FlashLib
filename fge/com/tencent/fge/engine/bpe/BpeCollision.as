package com.tencent.fge.engine.bpe
{
	
	internal final class BpeCollision 
	{
		
		internal var vn:BpeVector;
		internal var vt:BpeVector;
		
		public function BpeCollision(vn:BpeVector, vt:BpeVector) 
		{
			this.vn = vn;
			this.vt = vt;
		}
	}
}