package com.tencent.fge.engine.bpe
{
	import com.tencent.fge.engine.bpe.debug.CollisionZoneView;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	internal final class BpeCollisionDetector
	{	
		internal static function test(objA:BpeAbstractParticle, objB:BpeAbstractParticle):void
		{
			if(BPEngine.collisionDetector != null)
			{
				BPEngine.collisionDetector.test(objA, objB);
				return;
			}
			
			if (objA.fixed && objB.fixed) return;
			normVsNorm(objA, objB);
		}
		
		private static function normVsNorm(objA:BpeAbstractParticle, objB:BpeAbstractParticle):void 
		{
			//objA.samp.copy(objA.curr);
			//objB.samp.copy(objB.curr);
			testTypes(objA, objB);
		}

		private static function testTypes(objA:BpeAbstractParticle, objB:BpeAbstractParticle):Boolean 
		{	
			if(objA is BpeClimberParticle && objB is BpeGroundParticle)
			{
				return testClimberVsGround(
					objA as BpeClimberParticle, objB as BpeGroundParticle);
			}
			else if(objA is BpeClimberParticle && objB is BpeClimberParticle)
			{
				return testClimberVsClimber(
					objA as BpeClimberParticle, objB as BpeClimberParticle);
			}
			else if(objA is BpeBombParticle && objB is BpeGroundParticle)
			{
				return testBombVsGround(
					objA as BpeBombParticle, objB as BpeGroundParticle);
			}
			else if(objA is BpeBombParticle && objB is BpeClimberParticle)
			{
				return testBombVsClimber(
					objA as BpeBombParticle, objB as BpeClimberParticle);
			}
			return false;
		}
		
		
		public static function testBombVsClimber(
			ra:BpeBombParticle, rb:BpeClimberParticle):Boolean
		{
			var pta:Point = new Point(ra.curr.x, ra.curr.y);
			var ptb:Point = new Point(rb.curr.x, rb.curr.y);
			var dxd:Number = (pta.x - ptb.x)*(pta.x - ptb.x) + (pta.y - ptb.y)*(pta.y - ptb.y);
			var tmp:Number = Math.max(ra.radius, rb.radius);
			if(dxd < tmp * tmp)
			{
				//发生碰撞
				ra.resolveCollisionTo(rb, 0, null, false);
				rb.resolveCollisionBy(ra, 0, null, false);
				return true;
			}
			return false;			
		}
		
		public static function testBombVsGround(
			ra:BpeBombParticle, rb:BpeGroundParticle):Boolean
		{
			var rc:Rectangle = new Rectangle;
			var flag:int = 0;
			
			if(ra.prev.x == ra.curr.x && ra.prev.y == ra.curr.y)
			{
				//两点重叠，没有运动。
				return false;
			}
			
			if(ra.prev.x == ra.curr.x && ra.prev.y < ra.curr.y)
			{
				//垂直向下运动
				flag = 1;
				rc.x = ra.curr.x;
				rc.y = ra.prev.y;
				rc.width = 1;
				rc.bottom = ra.curr.y;
			}
			else if(ra.prev.x == ra.curr.x && ra.prev.y > ra.curr.y)
			{
				//垂直向上
				flag = 2;
				rc.x = ra.curr.x;
				rc.y = ra.curr.y;
				rc.width = 1;
				rc.bottom = ra.prev.y;
			}
			else if(ra.prev.x < ra.curr.x && ra.prev.y == ra.curr.y)
			{
				//水平向右
				flag = 3;
				rc.x = ra.prev.x;
				rc.y = ra.prev.y;
				rc.right = ra.curr.x;
				rc.height = 1;
			}
			else if(ra.prev.x > ra.curr.x && ra.prev.y == ra.curr.y)
			{
				//水平向左
				flag = 4;
				rc.x = ra.curr.x;
				rc.y = ra.curr.y;
				rc.right = ra.prev.x;
				rc.height = 1;
			}
			else if(ra.prev.x > ra.curr.x && ra.prev.y < ra.curr.y)
			{
				//左下
				flag = 5;
				rc.x = ra.curr.x;
				rc.y = ra.prev.y;
				rc.right = ra.prev.x;
				rc.bottom = ra.curr.y;
			}
			else if(ra.prev.x > ra.curr.x && ra.prev.y > ra.curr.y)
			{
				//左上
				flag = 6;
				rc.x = ra.curr.x;
				rc.y = ra.curr.y;
				rc.right = ra.prev.x;
				rc.bottom = ra.prev.y;
			}
			else if(ra.prev.x < ra.curr.x && ra.prev.y < ra.curr.y)
			{
				//右下
				flag = 7;
				rc.x = ra.prev.x;
				rc.y = ra.prev.y;
				rc.right = ra.curr.x;
				rc.bottom = ra.curr.y;
			}
			else if(ra.prev.x < ra.curr.x && ra.prev.y > ra.curr.y)
			{
				//右上
				flag = 8;
				rc.x = ra.prev.x;
				rc.y = ra.curr.y;
				rc.right = ra.curr.x;
				rc.bottom = ra.prev.y;
			}
			
			
			if(rc.width < 1) rc.width = 1;
			if(rc.height < 1) rc.height = 1;
			
			var rca:Rectangle = rc;
			var rcb:Rectangle = new Rectangle(rb.curr.x, rb.curr.y, rb.width, rb.height);
			
			//是否相交。相交是碰撞的前提
			if(!rca.intersects(rcb))
			{
				//没有碰撞
				return false;
			}

			var matB2A:Matrix = new Matrix(1,0,0,1,rcb.x - rca.x, rcb.y - rca.y);
			var bmpB2A:BitmapData = new BitmapData(rca.width,rca.height,true, 0);
			bmpB2A.draw(rb.collisionObject, matB2A);

			
			var x0:Number = ra.prev.x - rc.x;
			var y0:Number = ra.prev.y - rc.y;
			var x1:Number = ra.curr.x - rc.x;
			var y1:Number = ra.curr.y - rc.y;
			var x:Number = 0;
			var y:Number = 0;
			var k:Number = (y1 - y0) / (x1 - x0);
			var hasCross:Boolean = false;
			
			if(Math.abs(k) < 1)
			{
				if(x0 < x1)
				{
					for(x = x0; x <= x1; x += 1)
					{
						y = y0 + k*x;
						if(bmpB2A.getPixel32(x, y) != 0)
						{
							hasCross = true;
							break;
						}
					}				
				}
				else if(x0 > x1)
				{
					for(x = x0; x >= x1; x -= 1)
					{
						y = y0 - k*x;
						if(bmpB2A.getPixel32(x, y) != 0)
						{
							hasCross = true;
							break;
						}
					}					
				}				
			}
			else
			{
				if(y0 < y1)
				{
					for(y = y0; y <= y1; y += 1)
					{
						x = x0 + y/k;
						if(bmpB2A.getPixel32(x, y) != 0)
						{
							hasCross = true;
							break;
						}
					}				
				}
				else if(y0 > y1)
				{
					for(y = y0; y >= y1; y -= 1)
					{
						x = x0 - y/k;
						if(bmpB2A.getPixel32(x, y) != 0)
						{
							hasCross = true;
							break;
						}
					}					
				}					
			}
			

			if(!hasCross)
			{
				return false;
			}
			else
			{
				ra.curr.x = rc.x + x;
				ra.curr.y = rc.y + y;
				//发生碰撞
				ra.resolveCollisionTo(rb, 0, null, false);
				rb.resolveCollisionBy(ra, 0, null, false);
				return true;
			}
			
		}
		

		
		public static function testClimberVsClimber(
			ra:BpeClimberParticle, rb:BpeClimberParticle):Boolean
		{
			var pta:Point = new Point(ra.curr.x, ra.curr.y);
			var ptb:Point = new Point(rb.curr.x, rb.curr.y);
			var dxd:Number = (pta.x - ptb.x)*(pta.x - ptb.x) + (pta.y - ptb.y)*(pta.y - ptb.y);
			var tmp:Number = Math.max(ra.radius, rb.radius);
			if(dxd < tmp * tmp)
			{
				//发生碰撞
				ra.resolveCollisionTo(rb, 0, null, false);
				rb.resolveCollisionBy(ra, 0, null, false);
				return true;
			}
			return false;
		}
		
		
		private static function checkColorNull(clr:uint):Boolean{return clr == 0;}
		private static function checkColorNoNull(clr:uint):Boolean{return clr != 0;}
		
		public static function testClimberVsGround(
			ra:BpeClimberParticle, rb:BpeGroundParticle):Boolean
		{
			var rca:Rectangle = new Rectangle(
				ra.curr.x - ra.radius, ra.curr.y - ra.radius, ra.width, ra.height);
			var rcb:Rectangle = new Rectangle(rb.curr.x, rb.curr.y, rb.width, rb.height);
			
			//是否相交。相交是碰撞的前提
			if(!rca.intersects(rcb))
			{
				//没有碰撞
				return false;
			}
			
			var matB2A:Matrix = new Matrix(1,0,0,1,rcb.x - rca.x, rcb.y - rca.y);
			var bmpB2A:BitmapData = new BitmapData(rca.width, rca.height,true, 0);
			bmpB2A.draw(rb.collisionObject, matB2A);
			
			//CollisionZoneView.getInstance().bitmapData = bmpB2A;
			
			var r:Number = rca.width / 2;
			var tx:Number = rca.width / 2;
			var ty:Number = rca.height / 2;		
			
			
			//有碰撞
			var hold:Boolean = false;
							
			//以下是发生碰撞后，修正Ra的位置
			//上移
			var ptTouch:Point;
			
			ptTouch = BpeBitmapUtil.findBitmapCrossAxis(bmpB2A, r, r, 90, checkColorNoNull);
			if(ptTouch == null)//说明所找到的点，都是空的。
			{
				//没有碰撞
				ra.radian = 0;
				return false;
			}
			
			ptTouch = BpeBitmapUtil.findBitmapCrossAxis(bmpB2A, ptTouch.x, ptTouch.y, 90, checkColorNull);
			if(ptTouch == null)//说明之后所找到的点，都不是空的。
			{
				ty = 0;
				ra.curr.y = ty + rca.y;
				//hold = true;
			}
			else
			{
				ty = ptTouch.y;
				ra.curr.y = ty + rca.y;
			}
			
		
			/*
			rca = new Rectangle(ra.curr.x - ra.radius, ra.curr.y - ra.radius, ra.width, ra.height);
			matB2A = new Matrix(1,0,0,1,rcb.x - rca.x, rcb.y - rca.y);
			bmpB2A.dispose();
			bmpB2A = new BitmapData(rca.width, rca.height,true, 0);
			bmpB2A.draw(rb.collisionObject, matB2A);		
			*/
			
			//CollisionZoneView.getInstance().bitmapData = bmpB2A;	
		
			
			var rad:Number = BpeBitmapUtil.getAngle(bmpB2A, r,r, 30, 100);
			

			if(ra.toward == 1)//右
			{
				if(rad > Math.PI*0.25 && rad < Math.PI/2)
				{
					hold = true;
				}
			}
			else if(ra.toward == -1)
			{
				if(rad < Math.PI*0.75 && rad > Math.PI/2)
				{
					hold = true;
				}
			}

			
			//超过45度
			if(hold)
			{ 
				//左退
				ra.curr.x = ra.prev.x;
				ra.curr.y = ra.prev.y;
			}
			else
			{
				//上移
				/*
				ptTouch = BpeBitmapUtil.findBitmapCrossAxis(bmpB2A, r, 90);
				if(ptTouch == null)
				{
					ra.curr.y = ty + rca.y;
				}
				else
				{
					ty = ptTouch.y;
					ra.curr.y = ty + rca.y;
				}	
				*/				
			}
		
			//处理碰撞
			ra.resolveCollisionTo(rb, rad, null, hold);
			rb.resolveCollisionBy(ra, rad, null, hold);
			return true;
		}

	}
}
