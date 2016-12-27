package slicol.starling.ps.impl
{
	import com.tencent.fge.engine.graphic.bezier.BEBezierCurve;
	import com.tencent.fge.engine.graphic.bezier.CurvePoint;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import slicol.starling.ps.cfg.PSConfig;
	import slicol.starling.ps.core.ColorArgb;
	import slicol.starling.ps.core.Particle;
	import slicol.starling.ps.core.ParticleSystemBase;
	import slicol.starling.ps.core.RPSFactory;
	
	import starling.utils.deg2rad;
	import starling.utils.rad2deg;
	
	public class PSBasic extends ParticleSystemBase
	{
		public static var cfgTemplate:XML;
		
		// Config
		private var mCfg:PSConfig = new PSConfig(this);
		
		//Enum
		private const EMITTER_TYPE_GRAVITY:int = 0;
		private const EMITTER_TYPE_RADIAL:int  = 1;
		
		// emitter configuration                            // .pex element name
		private var mEmitterType:int;                       // emitterType
		private var mEmitterXVariance:Number;               // sourcePositionVariance x
		private var mEmitterYVariance:Number;               // sourcePositionVariance y
		
		// particle configuration
		private var mMaxNumParticles:int;                   // maxParticles
		private var mLifespan:Number;                       // particleLifeSpan
		private var mLifespanVariance:Number;               // particleLifeSpanVariance
		private var mStartSize:Number;                      // startParticleSize
		private var mStartSizeVariance:Number;              // startParticleSizeVariance
		private var mEndSize:Number;                        // finishParticleSize
		private var mEndSizeVariance:Number;                // finishParticleSizeVariance
		private var mEmitAngle:Number;                      // angle
		private var mEmitAngleVariance:Number;              // angleVariance
		private var mStartRotation:Number;                  // rotationStart
		private var mStartRotationVariance:Number;          // rotationStartVariance
		private var mEndRotation:Number;                    // rotationEnd
		private var mEndRotationVariance:Number;            // rotationEndVariance
		
		// gravity configuration
		private var mSpeed:Number;                          // speed
		private var mSpeedVariance:Number;                  // speedVariance
		protected var mGravityX:Number;                       // gravity x
		protected var mGravityY:Number;                       // gravity y
		private var mRadialAcceleration:Number;             // radialAcceleration
		private var mRadialAccelerationVariance:Number;     // radialAccelerationVariance
		private var mTangentialAcceleration:Number;         // tangentialAcceleration
		private var mTangentialAccelerationVariance:Number; // tangentialAccelerationVariance
		
		// radial configuration 
		private var mMaxRadius:Number;                      // maxRadius
		private var mMaxRadiusVariance:Number;              // maxRadiusVariance
		private var mMinRadius:Number;                      // minRadius
		private var mRotatePerSecond:Number;                // rotatePerSecond
		private var mRotatePerSecondVariance:Number;        // rotatePerSecondVariance
		
		// color configuration
		private var mStartColor:ColorArgb;                  // startColor
		private var mStartColorVariance:ColorArgb;          // startColorVariance
		private var mEndColor:ColorArgb;                    // finishColor
		private var mEndColorVariance:ColorArgb;            // finishColorVariance
		
		//texture
		private var mTextureName:String = "";
		
		//Curve
		private var mCurve:BEBezierCurve;
		private var mCurveName:String = "";
		private var mCurveEffect:int = 0;
		private var mCurvePoints:Vector.<CurvePoint> = new Vector.<CurvePoint>;
		private var mCurveIndex:int = 0;
		private var mCurveEffectFillRatio:Number = 0.6;
		
		
		public function PSBasic(cfg:XML)
		{
			initConfig(cfg);
			
			var emissionRate:Number = mMaxNumParticles / mLifespan;
			super(texture, emissionRate, mMaxNumParticles, mMaxNumParticles,
				mBlendFactorSource, mBlendFactorDestination);
			
			mPremultipliedAlpha = false;
		}
		
		protected override function createParticle():Particle
		{
			return new BasicParticle();
		}
		
		
		//----------------------------------------------------------------------------------------------
		
		protected override function initParticle(aParticle:Particle):void
		{
			var particle:BasicParticle = aParticle as BasicParticle;
			
			initParticle_CurveEffect(particle);
			initParticleBasic(particle);
		}
		
		private function initParticleBasic(particle:BasicParticle):void
		{
			// for performance reasons, the random variances are calculated inline instead
			// of calling a function
			
			var lifespan:Number = mLifespan + mLifespanVariance * (Math.random() * 2.0 - 1.0);
			
			particle.currentTime = 0.0;
			particle.totalTime = lifespan > 0.0 ? lifespan : 0.0;
			
			if (lifespan <= 0.0) return;
			
			particle.x = mEmitterX + mEmitterXVariance * (Math.random() * 2.0 - 1.0);
			particle.y = mEmitterY + mEmitterYVariance * (Math.random() * 2.0 - 1.0);
			particle.startX = mEmitterX;
			particle.startY = mEmitterY;
			
			var angle:Number = mEmitAngle + mEmitAngleVariance * (Math.random() * 2.0 - 1.0);
			var speed:Number = mSpeed + mSpeedVariance * (Math.random() * 2.0 - 1.0);
			particle.velocityX = speed * Math.cos(angle);
			particle.velocityY = speed * Math.sin(angle);
			
			particle.emitRadius = mMaxRadius + mMaxRadiusVariance * (Math.random() * 2.0 - 1.0);
			particle.emitRadiusDelta = mMaxRadius / lifespan;
			particle.emitRotation = mEmitAngle + mEmitAngleVariance * (Math.random() * 2.0 - 1.0); 
			particle.emitRotationDelta = mRotatePerSecond + mRotatePerSecondVariance * (Math.random() * 2.0 - 1.0); 
			particle.radialAcceleration = mRadialAcceleration + mRadialAccelerationVariance * (Math.random() * 2.0 - 1.0);
			particle.tangentialAcceleration = mTangentialAcceleration + mTangentialAccelerationVariance * (Math.random() * 2.0 - 1.0);
			
			var startSize:Number = mStartSize + mStartSizeVariance * (Math.random() * 2.0 - 1.0); 
			var endSize:Number = mEndSize + mEndSizeVariance * (Math.random() * 2.0 - 1.0);
			if (startSize < 0.1) startSize = 0.1;
			if (endSize < 0.1)   endSize = 0.1;
			particle.scaleX = startSize / texture.width;
			particle.scaleY = startSize / texture.width;
			particle.scaleDelta = ((endSize - startSize) / lifespan) / texture.width;
			
			// colors
			
			var startColor:ColorArgb = particle.colorArgb;
			var colorDelta:ColorArgb = particle.colorArgbDelta;
			
			startColor.red   = mStartColor.red;
			startColor.green = mStartColor.green;
			startColor.blue  = mStartColor.blue;
			startColor.alpha = mStartColor.alpha;
			
			if (mStartColorVariance.red != 0)   startColor.red   += mStartColorVariance.red   * (Math.random() * 2.0 - 1.0);
			if (mStartColorVariance.green != 0) startColor.green += mStartColorVariance.green * (Math.random() * 2.0 - 1.0);
			if (mStartColorVariance.blue != 0)  startColor.blue  += mStartColorVariance.blue  * (Math.random() * 2.0 - 1.0);
			if (mStartColorVariance.alpha != 0) startColor.alpha += mStartColorVariance.alpha * (Math.random() * 2.0 - 1.0);
			
			var endColorRed:Number   = mEndColor.red;
			var endColorGreen:Number = mEndColor.green;
			var endColorBlue:Number  = mEndColor.blue;
			var endColorAlpha:Number = mEndColor.alpha;
			
			if (mEndColorVariance.red != 0)   endColorRed   += mEndColorVariance.red   * (Math.random() * 2.0 - 1.0);
			if (mEndColorVariance.green != 0) endColorGreen += mEndColorVariance.green * (Math.random() * 2.0 - 1.0);
			if (mEndColorVariance.blue != 0)  endColorBlue  += mEndColorVariance.blue  * (Math.random() * 2.0 - 1.0);
			if (mEndColorVariance.alpha != 0) endColorAlpha += mEndColorVariance.alpha * (Math.random() * 2.0 - 1.0);
			
			colorDelta.red   = (endColorRed   - startColor.red)   / lifespan;
			colorDelta.green = (endColorGreen - startColor.green) / lifespan;
			colorDelta.blue  = (endColorBlue  - startColor.blue)  / lifespan;
			colorDelta.alpha = (endColorAlpha - startColor.alpha) / lifespan;
			
			// rotation
			
			var startRotation:Number = mStartRotation + mStartRotationVariance * (Math.random() * 2.0 - 1.0); 
			var endRotation:Number   = mEndRotation   + mEndRotationVariance   * (Math.random() * 2.0 - 1.0);
			
			particle.rotation = startRotation;
			particle.rotationDelta = (endRotation - startRotation) / lifespan;
		}
		
		
		
		private function initParticle_CurveEffect(particle:BasicParticle):void
		{
			//新的粒子
			if(mCurveEffect == CurveEffect.CurveEffect_EmitterPosPerNewParticle )
			{
				if(mCurveIndex < mCurvePoints.length)
				{
					this.emitterX = mCurvePoints[mCurveIndex].x;
					this.emitterY = mCurvePoints[mCurveIndex].y;
					++mCurveIndex;
				}
				else
				{
					mCurveIndex = 0;
				}
			}
			else if(mCurveEffect == CurveEffect.CurveEffect_ParticlePosAlongCurve || 
				mCurveEffect == CurveEffect.CurveEffect_ParticlePosFillCurve)
			{
				particle.curveIndex = 0;
				if(mCurvePoints.length > 0)
				{
					this.emitterX = mCurvePoints[0].x;
					this.emitterY = mCurvePoints[0].y;
				}
			}
		}
		
		//----------------------------------------------------------------------------------------------
		
		override public function advanceTime(passedTime:Number):void
		{
			super.advanceTime(passedTime);
			advanceTime_CurveEffect(passedTime);
		}
		
		private function advanceTime_CurveEffect(passedTime:Number):void
		{
			if(mCurveEffect == CurveEffect.CurveEffect_EmitterPosPerFrame)
			{
				if(mCurveIndex < mCurvePoints.length)
				{
					this.emitterX = mCurvePoints[mCurveIndex].x;
					this.emitterY = mCurvePoints[mCurveIndex].y;
					++mCurveIndex;
				}
				else
				{
					mCurveIndex = 0;
				}
			}
		}
		
		
		//----------------------------------------------------------------------------------------------
		
		protected override function advanceParticle(aParticle:Particle, passedTime:Number, index:int):void
		{
			var particle:BasicParticle = aParticle as BasicParticle;
		
			if(mCurveEffect == CurveEffect.CurveEffect_ParticlePosFillCurve)
			{	
				advanceParticle_CurveEffect_ParticlePosFillCurve(particle, passedTime, index);
				return;
			}
			else if(mCurveEffect == CurveEffect.CurveEffect_ParticlePosAlongCurve)
			{
				advanceParticle_CurveEffect_ParticlePosAlongCurve(particle, passedTime, index);
				return;
			}
			else if(mCurveEffect == CurveEffect.CurveEffect_EmitterPosPerParticle)
			{
				//
				if(mCurveIndex < mCurvePoints.length)
				{
					this.emitterX = mCurvePoints[mCurveIndex].x;
					this.emitterY = mCurvePoints[mCurveIndex].y;
					++mCurveIndex;
				}
				else
				{
					mCurveIndex = 0;
				}
			}
			
			advanceParticleBasic(particle, passedTime, index);
		}
		
		
		
		
		
		private function advanceParticleBasic(particle:BasicParticle, passedTime:Number, index:int):void
		{
			var restTime:Number = particle.totalTime - particle.currentTime;
			passedTime = restTime > passedTime ? passedTime : restTime;
			particle.currentTime += passedTime;
			
			if (mEmitterType == EMITTER_TYPE_RADIAL)
			{
				particle.emitRotation += particle.emitRotationDelta * passedTime;
				particle.emitRadius   -= particle.emitRadiusDelta   * passedTime;
				particle.x = mEmitterX - Math.cos(particle.emitRotation) * particle.emitRadius;
				particle.y = mEmitterY - Math.sin(particle.emitRotation) * particle.emitRadius;
				
				if (particle.emitRadius < mMinRadius)
					particle.currentTime = particle.totalTime;
			}
			else
			{
				var distanceX:Number = particle.x - particle.startX;
				var distanceY:Number = particle.y - particle.startY;
				var distanceScalar:Number = Math.sqrt(distanceX*distanceX + distanceY*distanceY);
				if (distanceScalar < 0.01) distanceScalar = 0.01;
				
				var radialX:Number = distanceX / distanceScalar;
				var radialY:Number = distanceY / distanceScalar;
				var tangentialX:Number = radialX;
				var tangentialY:Number = radialY;
				
				radialX *= particle.radialAcceleration;
				radialY *= particle.radialAcceleration;
				
				var newY:Number = tangentialX;
				tangentialX = -tangentialY * particle.tangentialAcceleration;
				tangentialY = newY * particle.tangentialAcceleration;
				
				particle.velocityX += passedTime * (mGravityX + radialX + tangentialX);
				particle.velocityY += passedTime * (mGravityY + radialY + tangentialY);
				particle.x += particle.velocityX * passedTime;
				particle.y += particle.velocityY * passedTime;
			}
			
			particle.scaleX += particle.scaleDelta * passedTime;
			particle.scaleY += particle.scaleDelta * passedTime;
			particle.rotation += particle.rotationDelta * passedTime;
			
			particle.colorArgb.red   += particle.colorArgbDelta.red   * passedTime;
			particle.colorArgb.green += particle.colorArgbDelta.green * passedTime;
			particle.colorArgb.blue  += particle.colorArgbDelta.blue  * passedTime;
			particle.colorArgb.alpha += particle.colorArgbDelta.alpha * passedTime;
			
			particle.color = particle.colorArgb.toRgb();
			particle.alpha = particle.colorArgb.alpha;
		}
		
		
		private function advanceParticle_CurveEffect_ParticlePosAlongCurve(particle:BasicParticle, passedTime:Number, index:int):void
		{
			var restTime:Number = particle.totalTime - particle.currentTime;
			passedTime = restTime > passedTime ? passedTime : restTime;
			particle.currentTime += passedTime;
			
			var distanceX:Number = particle.x - particle.startX;
			var distanceY:Number = particle.y - particle.startY;
			var distanceScalar:Number = Math.sqrt(distanceX*distanceX + distanceY*distanceY);
			if (distanceScalar < 0.01) distanceScalar = 0.01;
			
			var radialX:Number = distanceX / distanceScalar;
			var radialY:Number = distanceY / distanceScalar;
			var tangentialX:Number = radialX;
			var tangentialY:Number = radialY;
			
			radialX *= particle.radialAcceleration;
			radialY *= particle.radialAcceleration;
			
			var newY:Number = tangentialX;
			tangentialX = -tangentialY * particle.tangentialAcceleration;
			tangentialY = newY * particle.tangentialAcceleration;
			
			particle.velocityX += passedTime * (mGravityX + radialX + tangentialX);
			particle.velocityY += passedTime * (mGravityY + radialY + tangentialY);
			
			var dx:Number = particle.velocityX * passedTime;
			var dy:Number = particle.velocityY * passedTime;
			
			if(particle.curveIndex < mCurvePoints.length - 1)
			{
				var pt:Point = new Point(particle.x, particle.y);
				var dd1:Number = dx*dx + dy*dy;
				
				var ptNext:CurvePoint = mCurvePoints[particle.curveIndex + 1];
				var dd2:Number = (ptNext.x - pt.x)*(ptNext.x - pt.x) + (ptNext.y - pt.y)*(ptNext.y - pt.y);
				if(dd1 > dd2)
				{
					particle.curveIndex++;
				}
				pt = Point.interpolate(ptNext, pt, Math.sqrt(dd1/dd2)); 
				particle.x = pt.x;
				particle.y = pt.y;
			}
			else
			{
				particle.x += dx;
				particle.y += dy;
			}
			
			advanceParticle_CurveEffect_Basic(particle, passedTime, index);
		}
		
		
		private function advanceParticle_CurveEffect_ParticlePosFillCurve(particle:BasicParticle, passedTime:Number, index:int):void
		{
			var restTime:Number = particle.totalTime - particle.currentTime;
			passedTime = restTime > passedTime ? passedTime : restTime;
			particle.currentTime += passedTime;
			
			
			
			var timeRatio:Number = particle.currentTime / particle.totalTime;
			if(timeRatio > mCurveEffectFillRatio)
			{
				advanceParticleBasic(particle, passedTime, index);
				return;
			}
			
			if(mCurvePoints.length == 0)
			{
				advanceParticleBasic(particle, passedTime, index);
				return;
			}
			
			var indexCurve:Number = (timeRatio/mCurveEffectFillRatio) * mCurvePoints.length ;
			var index0:int = int(indexCurve);
			var index1:int = 0;
			
			if(index0 >= mCurvePoints.length)
			{
				index0 = mCurvePoints.length - 1;
			}
			
			if(index0 == mCurvePoints.length - 1)
			{
				index1 = index0;
			}
			else
			{
				index1 = index0 + 1;
			}
			
			var di:Number = (indexCurve - index0);
			
			var pt0:Point = mCurvePoints[index0];
			var pt1:Point = mCurvePoints[index1];
			var pt:Point = Point.interpolate(pt1, pt0, di);
			particle.x = pt.x;
			particle.y = pt.y;
			
			
			advanceParticle_CurveEffect_Basic(particle, passedTime, index);
		}
		
		private function advanceParticle_CurveEffect_Basic(particle:BasicParticle, passedTime:Number, index:int):void
		{
			particle.scaleX += particle.scaleDelta * passedTime;
			particle.scaleY += particle.scaleDelta * passedTime;
			particle.rotation += particle.rotationDelta * passedTime;
			
			particle.colorArgb.red   += particle.colorArgbDelta.red   * passedTime;
			particle.colorArgb.green += particle.colorArgbDelta.green * passedTime;
			particle.colorArgb.blue  += particle.colorArgbDelta.blue  * passedTime;
			particle.colorArgb.alpha += particle.colorArgbDelta.alpha * passedTime;
			
			particle.color = particle.colorArgb.toRgb();
			particle.alpha = particle.colorArgb.alpha;
		}
		//----------------------------------------------------------------------------------------------
		
		override public function hitTestEmitters(localPoint:Point, zoneSize:int = 20):int
		{
			if(!mCurvePoints || mCurvePoints.length <= 0 || mCurveEffect == CurveEffect.CurveEffect_Disable)
			{
				return super.hitTestEmitters(localPoint, zoneSize);
			}
			
			var rect:Rectangle = new Rectangle(0,0,zoneSize, zoneSize);
			for(var i:int = 0; i < mCurvePoints.length; ++i)
			{
				rect.x = mCurvePoints[i].x - zoneSize/2;
				rect.y = mCurvePoints[i].y - zoneSize/2;
				if(rect.containsPoint(localPoint))
				{
					return i;
				}
			}
			
			return -1;
		}
		
		//----------------------------------------------------------------------------------------------
		
		protected function updateEmissionRate():void
		{
			emissionRate = mMaxNumParticles / mLifespan;
		}
		
		override public function get id():String{return mCfg.id;}
		override public function get type():String{return mCfg.type;}
		
		
		public function get emitterType():int { return mEmitterType; }
		public function set emitterType(value:int):void { mEmitterType = value; }
		
		public function get emitterXVariance():Number { return mEmitterXVariance; }
		public function set emitterXVariance(value:Number):void { mEmitterXVariance = value; }
		
		public function get emitterYVariance():Number { return mEmitterYVariance; }
		public function set emitterYVariance(value:Number):void { mEmitterYVariance = value; }
		
		public function get maxNumParticles():int { return mMaxNumParticles; }
		public function set maxNumParticles(value:int):void 
		{ 
			maxCapacity = value;
			mMaxNumParticles = maxCapacity; 
			updateEmissionRate(); 
		}
		
		public function get lifespan():Number { return mLifespan; }
		public function set lifespan(value:Number):void 
		{ 
			mLifespan = Math.max(0.01, value);
			updateEmissionRate();
		}
		
		public function get lifespanVariance():Number { return mLifespanVariance; }
		public function set lifespanVariance(value:Number):void { mLifespanVariance = value; }
		
		public function get startSize():Number { return mStartSize; }
		public function set startSize(value:Number):void { mStartSize = value; }
		
		public function get startSizeVariance():Number { return mStartSizeVariance; }
		public function set startSizeVariance(value:Number):void { mStartSizeVariance = value; }
		
		public function get endSize():Number { return mEndSize; }
		public function set endSize(value:Number):void { mEndSize = value; }
		
		public function get endSizeVariance():Number { return mEndSizeVariance; }
		public function set endSizeVariance(value:Number):void { mEndSizeVariance = value; }
		
		public function get emitAngle():Number { return rad2deg(mEmitAngle); }
		public function set emitAngle(value:Number):void{ mEmitAngle = deg2rad(value); }
		
		public function get emitAngleVariance():Number { return rad2deg(mEmitAngleVariance); }
		public function set emitAngleVariance(value:Number):void { mEmitAngleVariance = deg2rad(value); }
		
		public function get startRotation():Number { return rad2deg(mStartRotation); } 
		public function set startRotation(value:Number):void { mStartRotation = deg2rad(value); }
		
		public function get startRotationVariance():Number { return rad2deg(mStartRotationVariance); } 
		public function set startRotationVariance(value:Number):void { mStartRotationVariance = deg2rad(value); }
		
		public function get endRotation():Number { return rad2deg(mEndRotation); } 
		public function set endRotation(value:Number):void { mEndRotation = deg2rad(value); }
		
		public function get endRotationVariance():Number { return rad2deg(mEndRotationVariance); } 
		public function set endRotationVariance(value:Number):void { mEndRotationVariance = deg2rad(value); }
		
		public function get speed():Number { return mSpeed; }
		public function set speed(value:Number):void { mSpeed = value; }
		
		public function get speedVariance():Number { return mSpeedVariance; }
		public function set speedVariance(value:Number):void { mSpeedVariance = value; }
		
		public function get gravityX():Number { return mGravityX; }
		public function set gravityX(value:Number):void { mGravityX = value; }
		
		public function get gravityY():Number { return mGravityY; }
		public function set gravityY(value:Number):void { mGravityY = value; }
		
		public function get radialAcceleration():Number { return mRadialAcceleration; }
		public function set radialAcceleration(value:Number):void { mRadialAcceleration = value; }
		
		public function get radialAccelerationVariance():Number { return mRadialAccelerationVariance; }
		public function set radialAccelerationVariance(value:Number):void { mRadialAccelerationVariance = value; }
		
		public function get tangentialAcceleration():Number { return mTangentialAcceleration; }
		public function set tangentialAcceleration(value:Number):void { mTangentialAcceleration = value; }
		
		public function get tangentialAccelerationVariance():Number { return mTangentialAccelerationVariance; }
		public function set tangentialAccelerationVariance(value:Number):void{ mTangentialAccelerationVariance = value; }
		
		public function get maxRadius():Number { return mMaxRadius; }
		public function set maxRadius(value:Number):void { mMaxRadius = value; }
		
		public function get maxRadiusVariance():Number { return mMaxRadiusVariance; }
		public function set maxRadiusVariance(value:Number):void { mMaxRadiusVariance = value; }
		
		public function get minRadius():Number { return mMinRadius; }
		public function set minRadius(value:Number):void{ mMinRadius = value; }
		
		public function get rotatePerSecond():Number { return rad2deg(mRotatePerSecond); }
		public function set rotatePerSecond(value:Number):void { mRotatePerSecond = deg2rad(value); }
		
		public function get rotatePerSecondVariance():Number { return rad2deg(mRotatePerSecondVariance); }
		public function set rotatePerSecondVariance(value:Number):void { mRotatePerSecondVariance = deg2rad(value); }
		
		public function get startColor():ColorArgb { return mStartColor; }
		public function set startColor(value:ColorArgb):void { mStartColor = value; }
		
		public function get startColorVariance():ColorArgb { return mStartColorVariance; }
		public function set startColorVariance(value:ColorArgb):void { mStartColorVariance = value; }
		
		public function get endColor():ColorArgb { return mEndColor; }
		public function set endColor(value:ColorArgb):void{ mEndColor = value; }
		
		public function get endColorVariance():ColorArgb { return mEndColorVariance; }
		public function set endColorVariance(value:ColorArgb):void{ mEndColorVariance = value; }
		
		//-------------------------------------------------------------------
		
		public function get textureName():String
		{	
			mTextureName = RPSFactory.makeRelativePath(mTextureName);
			return mTextureName;
		}
		public function set textureName(value:String):void
		{
			mTextureName = RPSFactory.makeRelativePath(value);
			mTexture = RPSFactory.me.getTexture(mTextureName);
		}
		
		
		public function get curveName():String
		{	
			mCurveName = RPSFactory.makeRelativePath(mCurveName);
			return mCurveName;
		}
		public function set curveName(value:String):void
		{
			mCurveName = RPSFactory.makeRelativePath(value);
			var xml:XML = RPSFactory.me.getCurve(mCurveName);
			setCurveConfig(xml);
		}
		
		public function set curvePath(lstPoint:Array):void
		{
			if(!mCurve)
			{
				mCurve = new BEBezierCurve(null);
			}
			mCurveIndex = 0;
			mCurve.clear();
			mCurvePoints = new Vector.<CurvePoint>;
			
			mCurve.addBPoints(lstPoint);
			mCurve.draw(mCurvePoints);
		}
		
		public function get curveEffect():int{	return mCurveEffect;}
		public function set curveEffect(value:int):void{	mCurveEffect = value;}
		
		//-------------------------------------------------------------------
		override public function setConfig(xml:XML):void
		{
			mCfg.setValue(xml);
			mCfg.validate();
		}
		
		
		
		public function setCurveConfig(xml:XML):void
		{
			if(!mCurve)
			{
				mCurve = new BEBezierCurve(null);
			}
			mCurveIndex = 0;
			mCurve.clear();
			mCurvePoints = new Vector.<CurvePoint>;
			
			if(xml)
			{
				mCurve.setConfig(xml);
				mCurve.draw(mCurvePoints);
			}
		}
		
		public function getCurveConfig():XML
		{
			if(mCurve)
			{
				return mCurve.getConfig();
			}
			return null;
		}
		
		override public function getConfig():XML
		{
			return mCfg.getValue();
		}
		
		override public function validateConfig():void
		{
			mCfg.validate();
		}
		
		

		
		protected function initConfig(xml:XML):void
		{
			if(!xml)
			{
				xml = new XML(cfgTemplate);
			}
			
			mCfg.bindProperty("emitterX", "sourcePosition", "x");
			mCfg.bindProperty("emitterY", "sourcePosition", "y");
			mCfg.bindProperty("emitterXVariance", "sourcePositionVariance", "x");
			mCfg.bindProperty("emitterYVariance", "sourcePositionVariance", "y");
			mCfg.bindProperty("gravityX", "gravity", "x");
			mCfg.bindProperty("gravityY", "gravity", "y");
			mCfg.bindProperty("emitterType", "emitterType", "value");
			mCfg.bindProperty("maxNumParticles", "maxParticles", "value");
			mCfg.bindProperty("lifespan", "particleLifeSpan", "value");
			mCfg.bindProperty("lifespanVariance", "particleLifespanVariance", "value");
			mCfg.bindProperty("startSize", "startParticleSize", "value");
			mCfg.bindProperty("startSizeVariance", "startParticleSizeVariance", "value");
			mCfg.bindProperty("endSize", "finishParticleSize", "value");
			mCfg.bindProperty("endSizeVariance", "finishParticleSizeVariance", "value");
			mCfg.bindProperty("emitAngle", "angle", "value");
			mCfg.bindProperty("emitAngleVariance", "angleVariance", "value");
			mCfg.bindProperty("startRotation", "rotationStart", "value");
			mCfg.bindProperty("startRotationVariance", "rotationStartVariance", "value");
			mCfg.bindProperty("endRotation", "rotationEnd", "value");
			mCfg.bindProperty("endRotationVariance", "rotationEndVariance", "value");
			mCfg.bindProperty("speed", "speed", "value");
			mCfg.bindProperty("speedVariance", "speedVariance", "value");
			mCfg.bindProperty("radialAcceleration", "radialAcceleration", "value");
			mCfg.bindProperty("radialAccelerationVariance", "radialAccelVariance", "value");
			mCfg.bindProperty("tangentialAcceleration", "tangentialAcceleration", "value");
			mCfg.bindProperty("tangentialAccelerationVariance", "tangentialAccelVariance", "value");
			mCfg.bindProperty("maxRadius", "maxRadius", "value");
			mCfg.bindProperty("maxRadiusVariance", "maxRadiusVariance", "value");
			mCfg.bindProperty("minRadius", "minRadius", "value");
			mCfg.bindProperty("rotatePerSecond", "rotatePerSecond", "value");
			mCfg.bindProperty("rotatePerSecondVariance", "rotatePerSecondVariance", "value");
			mCfg.bindProperty("startColor", "startColor", "value");
			mCfg.bindProperty("startColorVariance", "startColorVariance", "value");
			mCfg.bindProperty("endColor", "finishColor", "value");
			mCfg.bindProperty("endColorVariance", "finishColorVariance", "value");
			mCfg.bindProperty("blendFactorSource", "blendFuncSource", "value");
			mCfg.bindProperty("blendFactorDestination", "blendFuncDestination", "value");
			mCfg.bindProperty("duration", "duration", "value");
			
			mCfg.bindProperty("textureName", "texture", "name");
			
			mCfg.bindProperty("curveName", "curve", "name");
			mCfg.bindProperty("curveEffect", "curveEffect", "value");
			
			
			mCfg.checkProperty();
			
			mCfg.setValue(xml);
						
			mCfg.validate();
		}
		
		override public function getConfigTemplate():XML
		{
			return new XML(cfgTemplate);
		}

	}
}
import slicol.starling.ps.core.ColorArgb;
import slicol.starling.ps.core.Particle;


class BasicParticle extends Particle
{
	public var colorArgb:ColorArgb;
	public var colorArgbDelta:ColorArgb;
	public var startX:Number, startY:Number;
	public var velocityX:Number, velocityY:Number;
	public var radialAcceleration:Number;
	public var tangentialAcceleration:Number;
	public var emitRadius:Number, emitRadiusDelta:Number;
	public var emitRotation:Number, emitRotationDelta:Number;
	public var rotationDelta:Number;
	public var scaleDelta:Number;
	public var curveIndex:int;
	
	public function BasicParticle()
	{
		colorArgb = new ColorArgb();
		colorArgbDelta = new ColorArgb();
	}
}

class CurveEffect
{
	public static const CurveEffect_Disable:int = 0;
	public static const CurveEffect_EmitterPosPerFrame:int = 1;
	public static const CurveEffect_EmitterPosPerParticle:int = 2;
	public static const CurveEffect_EmitterPosPerNewParticle:int = 3;
	public static const CurveEffect_ParticlePosFillCurve:int = 4;
	public static const CurveEffect_ParticlePosAlongCurve:int = 5;
}