package slicol.starling.ps
{
	import com.tencent.fge.engine.graphic.bezier.BEBezierCurve;
	import com.tencent.fge.engine.graphic.bezier.BezierCurve;
	import com.tencent.fge.engine.graphic.bezier.CurvePoint;
	
	import flash.geom.Point;
	
	import starling.display.Shape;
	import starling.extensions.PDParticle;
	import starling.extensions.PDParticleSystem;
	import starling.extensions.Particle;
	import starling.textures.Texture;
	import starling.utils.VertexData;
	import slicol.starling.ps.math.PerlinNoise;
	
	public class RichPDParticleSystem_del extends PDParticleSystem
	{
		public static const CurveEffect_Disable:int = 0;
		public static const CurveEffect_EmitterPosPerFrame:int = 1;
		public static const CurveEffect_EmitterPosPerParticle:int = 2;
		public static const CurveEffect_EmitterPosPerNewParticle:int = 3;
		public static const CurveEffect_ParticlePosFillCurve:int = 4;
		public static const CurveEffect_ParticlePosAlongCurve:int = 5;
		
		private var m_curve:BEBezierCurve;
		private var m_curveEffect:int = 0;
		private var m_curvePoints:Vector.<CurvePoint>;
		private var m_curveIndex:int = 0;
		private var m_curveEffectFillRatio:Number = 0.5;
		

		public function RichPDParticleSystem_del(basicCfg:XML, texture:Texture)
		{
			super(basicCfg, texture);
			m_curve = new BEBezierCurve(null);
			m_curve.precisionType = BezierCurve.PrecisionType_Length1;
			m_curvePoints = new Vector.<CurvePoint>;
		}
		
		
		//-----------------------------------------------------------------------
		
		public function setBasicConfig(cfg:XML):void
		{
			parseConfig(cfg);
			updateEmissionRate();	
		}		
		
		public function setTexture(tex:Texture):void
		{
			var baseVertexData:VertexData = new VertexData(4);
			baseVertexData.setTexCoords(0, 0.0, 0.0);
			baseVertexData.setTexCoords(1, 1.0, 0.0);
			baseVertexData.setTexCoords(2, 0.0, 1.0);
			baseVertexData.setTexCoords(3, 1.0, 1.0);
			tex.adjustVertexData(baseVertexData, 0, 4);
			this.texture = tex;
		}
		
		//-----------------------------------------------------------------------
	
		public function setCurveConfig(cfg:XML):void
		{
			clearCurveEffect();
			
			m_curve.setConfig(cfg);
			m_curvePoints = new Vector.<CurvePoint>;
			m_curve.draw(m_curvePoints);
			

			var effect:int = int(cfg.effect.@value);
			m_curveEffect = effect;
		}
		
		public function setCurvePoints(lstPoints:Vector.<CurvePoint>):void
		{
			if(lstPoints)
			{
				clearCurveEffect();
				m_curvePoints = lstPoints;
			}
		}
		
		public function setCurveEffect(value:int):void
		{
			clearCurveEffect();
			m_curveEffect = value;
		}
		
		public function clearCurveEffect():void
		{
			m_curveEffect = 0;
			m_curveIndex = 0;
		}
		
		//-----------------------------------------------------------------------
		override public function advanceTime(passedTime:Number):void
		{
			super.advanceTime(passedTime);
			

			if(m_curveEffect == CurveEffect_EmitterPosPerFrame)
			{
				if(m_curveIndex < m_curvePoints.length)
				{
					this.emitterX = m_curvePoints[m_curveIndex].x;
					this.emitterY = m_curvePoints[m_curveIndex].y;
					++m_curveIndex;
				}
				else
				{
					m_curveIndex = 0;
				}
			}
		}
		
		//-----------------------------------------------------------------------
		
		override protected function initParticle(aParticle:Particle):void
		{
			//新的粒子
			if(m_curveEffect == CurveEffect_EmitterPosPerNewParticle )
			{
				if(m_curveIndex < m_curvePoints.length)
				{
					this.emitterX = m_curvePoints[m_curveIndex].x;
					this.emitterY = m_curvePoints[m_curveIndex].y;
					++m_curveIndex;
				}
				else
				{
					m_curveIndex = 0;
				}
			}
			else if(m_curveEffect == CurveEffect_ParticlePosAlongCurve || 
				m_curveEffect == CurveEffect_ParticlePosFillCurve)
			{
				var particle:PDParticle = aParticle as PDParticle;
				particle.curveIndex = 0;
				this.emitterX = m_curvePoints[0].x;
				this.emitterY = m_curvePoints[0].y;
			}

			
			super.initParticle(aParticle);
		}
		
		override protected function advanceParticle(aParticle:Particle, passedTime:Number, index:int):void
		{
			advanceParticle_PerlinEffect_Lightning(aParticle, passedTime, index);
			return;
			
			if(m_curveEffect == CurveEffect_ParticlePosFillCurve)
			{	
				advanceParticle_CurveEffect_ParticlePosFillCurve(aParticle, passedTime);
				return;
			}
			else if(m_curveEffect == CurveEffect_ParticlePosAlongCurve)
			{
				advanceParticle_CurveEffect_ParticlePosAlongCurve(aParticle, passedTime);
				return;
			}
			else if(m_curveEffect == CurveEffect_EmitterPosPerParticle)
			{
				//
				if(m_curveIndex < m_curvePoints.length)
				{
					this.emitterX = m_curvePoints[m_curveIndex].x;
					this.emitterY = m_curvePoints[m_curveIndex].y;
					++m_curveIndex;
				}
				else
				{
					m_curveIndex = 0;
				}
			}

			super.advanceParticle(aParticle, passedTime);
		}
		
		
		private function advanceParticle_PerlinEffect_Lightning(aParticle:Particle, passedTime:Number, index:int):void
		{
			var particle:PDParticle = aParticle as PDParticle;
			
			var restTime:Number = particle.totalTime - particle.currentTime;
			passedTime = restTime > passedTime ? passedTime : restTime;
			particle.currentTime += passedTime;
			
			var timex:Number = passedTime * this.speed * 0.1365143;
			var timey:Number = passedTime * this.speed * 1.21688;
			
			var xx:Number = index/this.maxNumParticles * 200;
			var yy:Number = index/this.maxNumParticles * 200;
			

			var offsetX:Number = m_noise.noise(timex+xx, timex+yy, 0);
			var offsetY:Number = m_noise.noise(timey+xx, timey+yy, 0);
			
			var dx:Number = offsetX * index/this.maxNumParticles * 100;
			var dy:Number = offsetY * index/this.maxNumParticles * 100;
			
			xx += dx;
			yy += dy;

			particle.x = xx;
			particle.y = yy;
			
			advanceParticle_CurveEffect_Basic(particle, passedTime, index);
		}
		

		private var m_noise:PerlinNoise = new PerlinNoise();
		
		
		private function advanceParticle_CurveEffect_ParticlePosAlongCurve(aParticle:Particle, passedTime:Number, index:int):void
		{
			var particle:PDParticle = aParticle as PDParticle;
			
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
			
			if(particle.curveIndex < m_curvePoints.length - 1)
			{
				var pt:Point = new Point(particle.x, particle.y);
				var dd1:Number = dx*dx + dy*dy;
				
				var ptNext:CurvePoint = m_curvePoints[particle.curveIndex + 1];
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
		
		
		private function advanceParticle_CurveEffect_ParticlePosFillCurve(aParticle:Particle, passedTime:Number, index:int):void
		{
			var particle:PDParticle = aParticle as PDParticle;
			
			var restTime:Number = particle.totalTime - particle.currentTime;
			passedTime = restTime > passedTime ? passedTime : restTime;
			particle.currentTime += passedTime;
			
			
			
			var timeRatio:Number = particle.currentTime / particle.totalTime;
			if(timeRatio > m_curveEffectFillRatio)
			{
				super.advanceParticle(aParticle, passedTime, index);
				return;
			}
			
			if(m_curvePoints.length == 0)
			{
				super.advanceParticle(aParticle, passedTime, index);
				return;
			}
			
			var indexCurve:Number = (timeRatio/m_curveEffectFillRatio) * m_curvePoints.length ;
			var index0:int = int(indexCurve);
			var index1:int = 0;
			
			if(index0 >= m_curvePoints.length)
			{
				index0 = m_curvePoints.length - 1;
			}
			
			if(index0 == m_curvePoints.length - 1)
			{
				index1 = index0;
			}
			else
			{
				index1 = index0 + 1;
			}
			
			var di:Number = (indexCurve - index0);
			
			var pt0:Point = m_curvePoints[index0];
			var pt1:Point = m_curvePoints[index1];
			var pt:Point = Point.interpolate(pt1, pt0, di);
			particle.x = pt.x;
			particle.y = pt.y;
	
			
			advanceParticle_CurveEffect_Basic(particle, passedTime, index);
		}
		
		private function advanceParticle_CurveEffect_Basic(particle:PDParticle, passedTime:Number, index:int):void
		{
			particle.scale += particle.scaleDelta * passedTime;
			particle.rotation += particle.rotationDelta * passedTime;
			
			particle.colorArgb.red   += particle.colorArgbDelta.red   * passedTime;
			particle.colorArgb.green += particle.colorArgbDelta.green * passedTime;
			particle.colorArgb.blue  += particle.colorArgbDelta.blue  * passedTime;
			particle.colorArgb.alpha += particle.colorArgbDelta.alpha * passedTime;
			
			particle.color = particle.colorArgb.toRgb();
			particle.alpha = particle.colorArgb.alpha;
		}
		
	}
}