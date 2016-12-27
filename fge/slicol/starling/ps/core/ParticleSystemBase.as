package slicol.starling.ps.core
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.errors.MissingContextError;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import starling.utils.MatrixUtil;
	import starling.utils.VertexData;
	
	/** Dispatched when emission of particles is finished. */
	[Event(name="complete", type="starling.events.Event")]
	public class ParticleSystemBase extends Sprite implements IParticleSystem
	{
		public static var Debug:Boolean = false;
		public static var CursorLayer:Sprite;

		
		protected var mTexture:Texture;
		private var mParticles:Vector.<Particle>;
		private var mFrameTime:Number = 0;
		
		private var mProgram:Program3D;
		private var mVertexData:VertexData;
		private var mVertexBuffer:VertexBuffer3D;
		private var mIndices:Vector.<uint>;
		private var mIndexBuffer:IndexBuffer3D;
		
		protected var mNumParticles:int;
		private var mMaxCapacity:int;
		private var mEmissionRate:Number = 0; // emitted particles per second
		private var mEmissionTime:Number = 0;
		private var mDuration:Number = 0;//持续时间
		
		/** Helper objects. */
		private static var sHelperMatrix:Matrix = new Matrix();
		private static var sHelperPoint:Point = new Point();
		private static var sRenderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
		
		/**一些需要在子类修改的参数**/
		protected var mEmitterX:Number = 0;
		protected var mEmitterY:Number = 0;
		protected var mPremultipliedAlpha:Boolean = false;
		protected var mBlendFactorSource:String = "";
		protected var mBlendFactorDestination:String = "";
		protected var mSmoothing:String = TextureSmoothing.BILINEAR;
		
		/*IParticleSystem*/
		protected var mZ:int;

		protected var mPosCursor:PosCursor;
		
		public function ParticleSystemBase(texture:Texture, emissionRate:Number, 
										   initialCapacity:int=128, maxCapacity:int=8192,
										   blendFactorSource:String=null, blendFactorDest:String=null)
		{
			mTexture = texture;
			mPremultipliedAlpha = texture.premultipliedAlpha;
			mParticles = new Vector.<Particle>(0, false);
			mVertexData = new VertexData(0);
			mIndices = new <uint>[];
			mEmissionRate = emissionRate;
			mEmissionTime = 0.0;
			mFrameTime = 0.0;
			//mEmitterX = mEmitterY = 0;
			mMaxCapacity = Math.min(8192, maxCapacity);
			mSmoothing = TextureSmoothing.BILINEAR;
			
			mBlendFactorDestination = blendFactorDest || Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			mBlendFactorSource = blendFactorSource ||
				(mPremultipliedAlpha ? Context3DBlendFactor.ONE : Context3DBlendFactor.SOURCE_ALPHA);
			
			createProgram();
			raiseCapacity(initialCapacity);
			
			// handle a lost device context
			Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE, 
				onContextCreated, false, 0, true);
			
			if(CursorLayer)
			{
				mPosCursor = new PosCursor(0xff0000);
				mPosCursor.select(this);
				CursorLayer.addChild(mPosCursor);
			}
		}
		
		
		
		public override function dispose():void
		{
			if(mPosCursor)
			{
				mPosCursor.select(null);
				mPosCursor.dispose();
				mPosCursor = null;
			}
			
			Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			
			if (mVertexBuffer) mVertexBuffer.dispose();
			if (mIndexBuffer)  mIndexBuffer.dispose();
			
			super.dispose();
		}
		
		private function onContextCreated(event:Object):void
		{
			createProgram();
			raiseCapacity(0);
		}
		
		protected function createParticle():Particle
		{
			return new Particle();
		}
		
		protected function initParticle(particle:Particle):void
		{
			particle.x = mEmitterX;
			particle.y = mEmitterY;
			particle.currentTime = 0;
			particle.totalTime = 1;
			particle.color = Math.random() * 0xffffff;
		}
		
		protected function advanceParticle(particle:Particle, passedTime:Number, index:int):void
		{
			particle.y += passedTime * 250;
			particle.alpha = 1.0 - particle.currentTime / particle.totalTime;
			particle.scaleX = 1.0 - particle.alpha; 
			particle.scaleY = 1.0 - particle.alpha;
			particle.currentTime += passedTime;
		}
		
		private function raiseCapacity(byAmount:int):void
		{
			var oldCapacity:int = capacity;
			var newCapacity:int = Math.min(mMaxCapacity, capacity + byAmount);
			var context:Context3D = Starling.context;
			
			if (context == null) throw new MissingContextError();
			
			var baseVertexData:VertexData = new VertexData(4);
			baseVertexData.setTexCoords(0, 0.0, 0.0);
			baseVertexData.setTexCoords(1, 1.0, 0.0);
			baseVertexData.setTexCoords(2, 0.0, 1.0);
			baseVertexData.setTexCoords(3, 1.0, 1.0);
			
			if(mTexture)
			{
				mTexture.adjustVertexData(baseVertexData, 0, 4);
			}
			
			mParticles.fixed = false;
			mIndices.fixed = false;
			
			for (var i:int=oldCapacity; i<newCapacity; ++i)  
			{
				var numVertices:int = i * 4;
				var numIndices:int  = i * 6;
				
				mParticles[i] = createParticle();
				mVertexData.append(baseVertexData);
				
				mIndices[    numIndices   ] = numVertices;
				mIndices[int(numIndices+1)] = numVertices + 1;
				mIndices[int(numIndices+2)] = numVertices + 2;
				mIndices[int(numIndices+3)] = numVertices + 1;
				mIndices[int(numIndices+4)] = numVertices + 3;
				mIndices[int(numIndices+5)] = numVertices + 2;
			}
			
			mParticles.fixed = true;
			mIndices.fixed = true;
			
			// upload data to vertex and index buffers
			
			if (mVertexBuffer) mVertexBuffer.dispose();
			if (mIndexBuffer)  mIndexBuffer.dispose();
			
			mVertexBuffer = context.createVertexBuffer(newCapacity * 4, VertexData.ELEMENTS_PER_VERTEX);
			mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, newCapacity * 4);
			
			mIndexBuffer  = context.createIndexBuffer(newCapacity * 6);
			mIndexBuffer.uploadFromVector(mIndices, 0, newCapacity * 6);
		}
		
		/** Starts the emitter for a certain time. @default infinite time */
		public function start(duration:Number=Number.MAX_VALUE):void
		{
			//启动值是默认，或者无效的
			if(duration == Number.MAX_VALUE || duration <=0)
			{
				//则
				if(mDuration > 0)
				{
					duration = mDuration;
				}
				else
				{
					mDuration = Number.MAX_VALUE;
				}
			}
			else
			{
				mDuration = duration;
			}
			
			if (mEmissionRate != 0)        
			{
				mEmissionTime = duration;
			}
		}
		
		/** Stops emitting new particles. Depending on 'clearParticles', the existing particles
		 *  will either keep animating until they die or will be removed right away. */
		public function stop(clearParticles:Boolean=false):void
		{
			mEmissionTime = 0.0;
			if (clearParticles) clear();
		}
		
		/** Removes all currently active particles. */
		public function clear():void
		{
			mNumParticles = 0;
		}
		
		/** Returns an empty rectangle at the particle system's position. Calculating the
		 *  actual bounds would be too expensive. */
		public override function getBounds(targetSpace:DisplayObject, 
										   resultRect:Rectangle=null):Rectangle
		{
			if (resultRect == null) resultRect = new Rectangle();
			
			getTransformationMatrix(targetSpace, sHelperMatrix);
			MatrixUtil.transformCoords(sHelperMatrix, 0, 0, sHelperPoint);
			
			resultRect.x = sHelperPoint.x;
			resultRect.y = sHelperPoint.y;
			resultRect.width = resultRect.height = 0;
			
			return resultRect;
		}
		
		//系统中可能会有多个EmitterPot,返回index，如果没有Hit，则返回-1
		public function hitTestEmitters(localPoint:Point, zoneSize:int = 20):int
		{
			var rect:Rectangle = new Rectangle(mEmitterX - zoneSize/2, mEmitterY - zoneSize/2, zoneSize, zoneSize);
			var ret:Boolean = rect.containsPoint(localPoint);
			return ret ? 0 : -1;
		}
		
		public function updateEmitterPos(index:uint, x:Number, y:Number):void
		{
			this.mEmitterX = x;
			this.mEmitterY = y;
			if(mPosCursor)
			{
				mPosCursor.update();
			}
		}
		
		public function advanceTime(passedTime:Number):void
		{
			var particleIndex:int = 0;
			var particle:Particle;
			
			// advance existing particles
			
			while (particleIndex < mNumParticles)
			{
				particle = mParticles[particleIndex] as Particle;
				
				if (particle.currentTime < particle.totalTime)
				{
					advanceParticle(particle, passedTime,particleIndex);
					++particleIndex;
				}
				else
				{
					if (particleIndex != mNumParticles - 1)
					{
						var nextParticle:Particle = mParticles[int(mNumParticles-1)] as Particle;
						mParticles[int(mNumParticles-1)] = particle;
						mParticles[particleIndex] = nextParticle;
					}
					
					--mNumParticles;
					
					if (mNumParticles == 0 && mEmissionTime == 0)
						dispatchEvent(new Event(Event.COMPLETE));
				}
			}
			
			// create and advance new particles
			
			if (mEmissionTime > 0)
			{
				var timeBetweenParticles:Number = 1.0 / mEmissionRate;
				mFrameTime += passedTime;
				
				while (mFrameTime > 0)
				{
					if (mNumParticles < mMaxCapacity)
					{
						if (mNumParticles == capacity)
							raiseCapacity(capacity);
						
						particle = mParticles[mNumParticles] as Particle;
						initParticle(particle);
						
						// particle might be dead at birth
						if (particle.totalTime > 0.0)
						{
							advanceParticle(particle, mFrameTime,particleIndex);
							++mNumParticles
						}
					}
					
					mFrameTime -= timeBetweenParticles;
				}
				
				if (mEmissionTime != Number.MAX_VALUE)
				{
					mEmissionTime = Math.max(0.0, mEmissionTime - passedTime);
					
				}
			}
			else
			{
				if(Debug)
				{
					if(mNumParticles == 0)
					{
						mEmissionTime = duration;
					}
				}
			}
			
			// update vertex data
			
			var vertexID:int = 0;
			var color:uint;
			var alpha:Number;
			var rotation:Number;
			var x:Number, y:Number;
			var xOffset:Number, yOffset:Number;
			
			var textureWidth:Number = 0;
			var textureHeight:Number = 0;

			textureWidth = mTexture.width;
			textureHeight = mTexture.height;
			
			
			for (var i:int=0; i<mNumParticles; ++i)
			{
				vertexID = i << 2;
				particle = mParticles[i] as Particle;
				color = particle.color;
				alpha = particle.alpha;
				rotation = particle.rotation;
				x = particle.x;
				y = particle.y;
				xOffset = textureWidth  * particle.scaleX >> 1;
				yOffset = textureHeight * particle.scaleY >> 1;
				
				for (var j:int=0; j<4; ++j)
					mVertexData.setColorAndAlpha(vertexID+j, color, alpha);
				
				if (rotation)
				{
					var cos:Number  = Math.cos(rotation);
					var sin:Number  = Math.sin(rotation);
					var cosX:Number = cos * xOffset;
					var cosY:Number = cos * yOffset;
					var sinX:Number = sin * xOffset;
					var sinY:Number = sin * yOffset;
					
					mVertexData.setPosition(vertexID,   x - cosX + sinY, y - sinX - cosY);
					mVertexData.setPosition(vertexID+1, x + cosX + sinY, y + sinX - cosY);
					mVertexData.setPosition(vertexID+2, x - cosX - sinY, y - sinX + cosY);
					mVertexData.setPosition(vertexID+3, x + cosX - sinY, y + sinX + cosY);
				}
				else 
				{
					// optimization for rotation == 0
					mVertexData.setPosition(vertexID,   x - xOffset, y - yOffset);
					mVertexData.setPosition(vertexID+1, x + xOffset, y - yOffset);
					mVertexData.setPosition(vertexID+2, x - xOffset, y + yOffset);
					mVertexData.setPosition(vertexID+3, x + xOffset, y + yOffset);
				}
			}
		}
		
		public override function render(support:RenderSupport, alpha:Number):void
		{
			if (mNumParticles == 0) return;
			
			// always call this method when you write custom rendering code!
			// it causes all previously batched quads/images to render.
			support.finishQuadBatch();
			
			// make this call to keep the statistics display in sync.
			// to play it safe, it's done in a backwards-compatible way here.
			if (support.hasOwnProperty("raiseDrawCount"))
				support.raiseDrawCount();
			
			alpha *= this.alpha;
			
			var context:Context3D = Starling.context;
			var pma:Boolean = texture.premultipliedAlpha;
			
			sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = pma ? alpha : 1.0;
			sRenderAlpha[3] = alpha;
			
			if (context == null) throw new MissingContextError();
			
			mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, mNumParticles * 4);
			mIndexBuffer.uploadFromVector(mIndices, 0, mNumParticles * 6);
			
			context.setBlendFactors(mBlendFactorSource, mBlendFactorDestination);
			context.setTextureAt(0, mTexture.base);
			
			context.setProgram(mProgram);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, sRenderAlpha, 1);
			context.setVertexBufferAt(0, mVertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2); 
			context.setVertexBufferAt(1, mVertexBuffer, VertexData.COLOR_OFFSET,    Context3DVertexBufferFormat.FLOAT_4);
			context.setVertexBufferAt(2, mVertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			
			context.drawTriangles(mIndexBuffer, 0, mNumParticles * 2);
			
			context.setTextureAt(0, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		}
		
		/** Initialize the <tt>ParticleSystem</tt> with particles distributed randomly throughout
		 *  their lifespans. */
		public function populate(count:int):void
		{
			count = Math.min(count, mMaxCapacity - mNumParticles);
			
			if (mNumParticles + count > capacity)
				raiseCapacity(mNumParticles + count - capacity);
			
			var p:Particle;
			for (var i:int=0; i<count; i++)
			{
				p = mParticles[mNumParticles+i];
				initParticle(p);
				advanceParticle(p, Math.random() * p.totalTime, i);
			}
			
			mNumParticles += count;
		}
		
		// program management
		
		private function createProgram():void
		{
			var mipmap:Boolean;
			var textureFormat:String;
			

				mipmap = mTexture.mipMapping;
				textureFormat = mTexture.format;
			


				mSmoothing = TextureSmoothing.BILINEAR;
			
			
			var programName:String = "ext.ParticleSystem." + textureFormat + "/" +
				mSmoothing.charAt(0) + (mipmap ? "+mm" : "");
			
			mProgram = Starling.current.getProgram(programName);
			
			if (mProgram == null)
			{
				var textureOptions:String =
					RenderSupport.getTextureLookupFlags(textureFormat, mipmap, false, mSmoothing);
				
				var vertexProgramCode:String =
					"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clipspace
					"mul v0, va1, vc4 \n" + // multiply color with alpha and pass to fragment program
					"mov v1, va2      \n";  // pass texture coordinates to fragment program
				
				var fragmentProgramCode:String =
					"tex ft1, v1, fs0 " + textureOptions + "\n" + // sample texture 0
					"mul oc, ft1, v0";                            // multiply color with texel color
				
				var assembler:AGALMiniAssembler = new AGALMiniAssembler();
				
				Starling.current.registerProgram(programName,
					assembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode),
					assembler.assemble(Context3DProgramType.FRAGMENT, fragmentProgramCode));
				
				mProgram = Starling.current.getProgram(programName);
			}
		}
		
		
		public function get listParticles():Vector.<Particle>{return mParticles;}
		
		public function get isEmitting():Boolean { return mEmissionTime > 0 && mEmissionRate > 0; }
		public function get capacity():int { return mVertexData.numVertices / 4; }
		public function get numParticles():int { return mNumParticles; }
		
		public function get maxCapacity():int { return mMaxCapacity; }
		public function set maxCapacity(value:int):void { mMaxCapacity = Math.min(8192, value); }
		
		public function get emissionRate():Number { return mEmissionRate; }
		public function set emissionRate(value:Number):void { mEmissionRate = value; }
		
		public function get emitterX():Number { return mEmitterX; }
		public function set emitterX(value:Number):void{ mEmitterX = value; }
		
		public function get emitterY():Number { return mEmitterY; }
		public function set emitterY(value:Number):void { mEmitterY = value; }
		
		public function get blendFactorSource():String { return blendFactor2Value(mBlendFactorSource); }
		public function set blendFactorSource(value:String):void { mBlendFactorSource = blendValue2Factor(value); }
		
		public function get blendFactorDestination():String { return blendFactor2Value(mBlendFactorDestination); }
		public function set blendFactorDestination(value:String):void{ mBlendFactorDestination = blendValue2Factor(value); }
		
		public function get texture():Texture { return mTexture; }
		public function set texture(value:Texture):void { mTexture = value; createProgram(); }
		
		public function get smoothing():String { return mSmoothing; }
		public function set smoothing(value:String):void{ mSmoothing = value; }
	
		
		public function get type():String{return "ParticleSystemBase";}		
		public function get id():String{return "";}

		public function get duration():Number
		{
			if(mDuration == Number.MAX_VALUE)
			{
				return 0;
			}
			return mDuration;
		}
		public function set duration(value:Number):void
		{
			mDuration = value;
			if(mDuration > 0)
			{
				mEmissionTime = value;
			}
			else
			{
				mEmissionTime = Number.MAX_VALUE;
			}
		}
		
		public function get z():int{return mZ;}
		public function set z(value:int):void{mZ = z;}
		
		public function setProperty(name:String, value:*):void
		{
			if(this.hasOwnProperty(name))
			{
				this[name] = value;
			}
		}
		
		public function getProperty(name:String):*
		{
			if(this.hasOwnProperty(name))
			{
				return this[name];
			}
			return null;
		}
		
		public function setConfig(xml:XML):void
		{
		}
		
		public function getConfig():XML
		{
			return null;
		}
		
		public function getConfigTemplate():XML
		{
			return null;
		}
		
		public function validateConfig():void
		{
		}

		//----------------------------------------------------------------
		
		public static function blendValue2Factor(value:String):String
		{
			var nValue:int = Number(value);
			switch (nValue)
			{
				case 0:     return Context3DBlendFactor.ZERO; break;
				case 1:     return Context3DBlendFactor.ONE; break;
				case 0x300: return Context3DBlendFactor.SOURCE_COLOR; break;
				case 0x301: return Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR; break;
				case 0x302: return Context3DBlendFactor.SOURCE_ALPHA; break;
				case 0x303: return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA; break;
				case 0x304: return Context3DBlendFactor.DESTINATION_ALPHA; break;
				case 0x305: return Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA; break;
				case 0x306: return Context3DBlendFactor.DESTINATION_COLOR; break;
				case 0x307: return Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR; break;
				default:   return value;
			}
		}
		
		public static function blendFactor2Value(factor:String):String
		{
			switch (factor)
			{
				case Context3DBlendFactor.ZERO:    return "0"; break;
				case Context3DBlendFactor.ONE:     return "1"; break;
				case Context3DBlendFactor.SOURCE_COLOR: return "0x300"; break;
				case Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR: return "0x301";break;
				case Context3DBlendFactor.SOURCE_ALPHA: return "0x302"; break;
				case Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA: return "0x303"; break;
				case Context3DBlendFactor.DESTINATION_ALPHA: return "0x304"; break;
				case Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA: return "0x305"; break;
				case Context3DBlendFactor.DESTINATION_COLOR: return "0x306"; break;
				case Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR: return "0x307"; break;
				default:   return factor;
			}
		}
	}
}



import slicol.starling.ps.core.ParticleSystemBase;

import starling.display.DisplayObject;
import starling.display.Shape;

class PosCursor extends Shape
{
	public static const Size:int = 10;
	
	public function PosCursor(color:uint)
	{
		super();
		
		
		// Rect drawn with drawRect()
		
		graphics.lineStyle(2, color, 1);
		

		graphics.moveTo(-Size/2,-Size/2);
		graphics.lineTo(-Size/4,-Size/2);
		graphics.moveTo(-Size/2,-Size/2);
		graphics.lineTo(-Size/2,-Size/4);
		
		graphics.moveTo(Size/2,-Size/2);
		graphics.lineTo(Size/4,-Size/2);
		graphics.moveTo(Size/2,-Size/2);
		graphics.lineTo(Size/2,-Size/4);
		
		graphics.moveTo(-Size/2,Size/2);
		graphics.lineTo(-Size/2,Size/4);
		graphics.moveTo(-Size/2,Size/2);
		graphics.lineTo(-Size/4,Size/2);
		
		graphics.moveTo(Size/2,Size/2);
		graphics.lineTo(Size/2,Size/4);
		graphics.moveTo(Size/2,Size/2);
		graphics.lineTo(Size/4,Size/2);

	}
	
	private var m_target:ParticleSystemBase;
	
	public function select(value:ParticleSystemBase):void
	{
		m_target = value;
		update();
	}
	
	public function get target():ParticleSystemBase
	{
		return m_target;
	}
	
	public function update():void
	{
		if(m_target)
		{
			this.x = m_target.emitterX;
			this.y = m_target.emitterY;
		}
	}
}

