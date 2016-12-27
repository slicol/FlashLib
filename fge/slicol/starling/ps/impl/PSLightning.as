package slicol.starling.ps.impl
{

	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import slicol.starling.ps.cfg.PSConfig;
	import slicol.starling.ps.core.Particle;
	import slicol.starling.ps.core.ParticleSystemBase;
	import slicol.starling.ps.core.RPSFactory;
	
	import starling.core.RenderSupport;
	import starling.display.BlendMode;
	import starling.display.Shape;
	
	public class PSLightning  extends ParticleSystemBase
	{
		public static var cfgTemplate:XML;
		
		// Config
		private var mCfg:PSConfig = new PSConfig(this);
		
		private var mMaxNumParticles:int = 500;                   // maxParticles
		private var mLifespan:Number = .1;                       // particleLifeSpan
		
		private var m_emitter:LightningEmitter;
		
		public function PSLightning(cfg:XML)
		{
			texture = RPSFactory.me.getTexture("LightningParticle");
			
			var emissionRate:Number = mMaxNumParticles / mLifespan;
			
			super(texture, emissionRate, mMaxNumParticles, mMaxNumParticles,
				mBlendFactorSource, mBlendFactorDestination);
			
			mPremultipliedAlpha = false;
			
			m_emitter = new LightningEmitter(0xffffff, 2);
			m_emitter.childrenDetachedEnd=true;
			m_emitter.childrenLifeSpanMin=0.1;
			m_emitter.childrenLifeSpanMax=2;
			m_emitter.childrenMaxCount=4;
			m_emitter.childrenMaxCountDecay=0.4;
			m_emitter.steps=50;
			m_emitter.smoothPercentage = 0.5;
			m_emitter.alphaFadeType=LightningFadeType.TIP_TO_END;
			m_emitter.childrenDetachedEnd = false;
			m_emitter.speed = 0.51;
			
			m_emitter.childrenProbability=0.3;

			
			m_emitter.endX=100;
			m_emitter.endY=100;
			
			initConfig(cfg);
		}
		
		override public function hitTestEmitters(localPoint:Point, zoneSize:int = 20):int
		{
			var rect:Rectangle = new Rectangle(m_emitter.startX - zoneSize/2, m_emitter.startY - zoneSize/2, zoneSize, zoneSize);
			var ret:Boolean = rect.containsPoint(localPoint);
			if(rect.containsPoint(localPoint))
			{
				mEmitterX = m_emitter.startX;
				mEmitterY = m_emitter.startY;
				return 0;
			}
			
			rect.x = m_emitter.endX;
			rect.y = m_emitter.endY;
			if(rect.containsPoint(localPoint))
			{
				mEmitterX = m_emitter.endX;
				mEmitterY = m_emitter.endY;
				return 1;
			}
			
			return -1;
		}
		
		
		override public function updateEmitterPos(index:uint, x:Number, y:Number):void
		{
			super.updateEmitterPos(index, x,y);
			
			if(index == 0)
			{
				m_emitter.startX = mEmitterX = x;
				m_emitter.startY = mEmitterY = y;
			}
			else if(index == 1)
			{
				m_emitter.endX = mEmitterX = x;
				m_emitter.endY = mEmitterY = y;
			}
			
		}
		
		protected override function createParticle():Particle
		{
			return new Particle();
		}
		
		protected override function initParticle(aParticle:Particle):void
		{
			super.initParticle(aParticle);
			aParticle.currentTime = 0.0;
			aParticle.totalTime = mLifespan;
		}
		
		override protected function advanceParticle(particle:Particle, passedTime:Number, index:int):void
		{
			particle.currentTime += passedTime;
		}

		
	
		override public function advanceTime(passedTime:Number):void
		{			
			var context:ParticlesContext = new ParticlesContext;
			context.listParticles = this.listParticles;
			context.index = 0;
			m_emitter.update(context);
			
			this.mNumParticles = context.index;
			
			super.advanceTime(passedTime);
			
		}
		

		
		override public function setConfig(xml:XML):void
		{
			mCfg.setValue(xml);
			mCfg.validate();
			this.duration = m_emitter.duration;
			this.mLifespan = m_emitter.lifeSpan;
		}
		
		override public function getConfig():XML
		{
			return mCfg.getValue();
		}
		
		override public function validateConfig():void
		{
			mCfg.validate();
			this.duration = m_emitter.duration;
			this.mLifespan = m_emitter.lifeSpan;
		}
		
		protected function initConfig(xml:XML):void
		{
			if(!xml)
			{
				xml = new XML(cfgTemplate);
			}
			mCfg.bindTarget(m_emitter);
			
			mCfg.bindProperty("startX", "start", "x");
			mCfg.bindProperty("startY", "start", "y");
			mCfg.bindProperty("endX", "end", "x");
			mCfg.bindProperty("endY", "end", "y");
			mCfg.bindProperty("steps", "steps", "value");
			mCfg.bindProperty("thickness", "thickness", "value");
			mCfg.bindProperty("speed", "speed", "value");
			mCfg.bindProperty("smoothPercentage", "smoothPercentage", "value");
			mCfg.bindProperty("childrenAngleVariation", "childrenAngleVariation", "value");
			mCfg.bindProperty("childrenMaxCount", "childrenMaxCount", "value");
			mCfg.bindProperty("wavelength", "wavelength", "value");
			mCfg.bindProperty("amplitude", "amplitude", "value");
			mCfg.bindProperty("amplitude2", "amplitude2", "value");
			mCfg.bindProperty("maxLength", "maxLength", "value");
			mCfg.bindProperty("maxLengthVary", "maxLengthVary", "value");
			mCfg.bindProperty("childrenProbability", "childrenProbability", "value");
			mCfg.bindProperty("childrenLifeSpanMin", "childrenLifeSpanMin", "value");
			mCfg.bindProperty("childrenLifeSpanMax", "childrenLifeSpanMax", "value");
			mCfg.bindProperty("childrenDetachedEnd", "childrenDetachedEnd", "value");
			mCfg.bindProperty("alphaFadeType", "alphaFadeType", "value");
			mCfg.bindProperty("thicknessFadeType", "thicknessFadeType", "value");
			mCfg.bindProperty("duration", "duration", "value");
			mCfg.bindProperty("lifeSpan", "particleLifeSpan", "value");
			
			
			mCfg.checkProperty();
			mCfg.setValue(xml);
			mCfg.validate();
			this.duration = m_emitter.duration;
			this.mLifespan = m_emitter.lifeSpan;
		}
		
		override public function getConfigTemplate():XML
		{
			return new XML(cfgTemplate);
		}
	}
}


class ParticlesContext
{
	public var listParticles:Vector.<Particle>;
	public var index:int;
}


import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.Timer;

import slicol.starling.ps.core.Particle;

class LightningEmitter
{
	private const SMOOTH_COLOR:uint=0x808080;
	
	public var z:Number = 0;
	public var alpha:Number = 1;
	public var sbd:BitmapData;
	public var bbd:BitmapData;
	private var soffs:Array;
	private var boffs:Array;
	private var glow:GlowFilter;
	
	public var duration:Number = 0;
	
	public var lifeSpan:Number = 0;
	private var lifeTimer:Timer;
	
	public var startX:Number;
	public var startY:Number;
	public var endX:Number;
	public var endY:Number;
	
	public var len:Number;
	//public var multi:Number;
	//public var multi2:Number;
	
	public var _steps:uint;
	public var stepEvery:Number;
	private var seed1:uint;
	private var seed2:uint;
	
	public var smooth:Sprite;
	public var childrenSmooth:Sprite;
	public var childrenArray:Vector.<ChildHelper> = new Vector.<ChildHelper>;
	
	public var _smoothPercentage:uint=50;
	public var _childrenSmoothPercentage:uint;
	public var _color:uint;
	
	private var generation:uint;
	private var _childrenMaxGenerations:uint=3;
	private var _childrenProbability:Number=0.025;
	private var _childrenProbabilityDecay:Number=0;
	private var _childrenMaxCount:uint=4;
	private var _childrenMaxCountDecay:Number=.5;
	private var _childrenLengthDecay:Number=0;
	private var _childrenAngleVariation:Number=60;
	private var _childrenLifeSpanMin:Number=0;
	private var _childrenLifeSpanMax:Number=0;
	private var _childrenDetachedEnd:Boolean=false;
	
	private var _maxLength:Number=0;
	private var _maxLengthVary:Number=0;
	public var _isVisible:Boolean=true;
	public var _alphaFade:Boolean=true;
	public var parentInstance:LightningEmitter;
	private var _thickness:Number;
	private var _thicknessDecay:Number;
	private var initialized:Boolean=false;
	
	private var _wavelength:Number=.3;
	private var _amplitude:Number=.5;
	private var _amplitude2:Number=.03;
	private var _speed:Number=1;
	
	private var calculatedWavelength:Number;
	private var calculatedSpeed:Number;
	
	public var alphaFadeType:String;
	public var thicknessFadeType:String;
	
	private var position:Number=0;
	private var absolutePosition:Number=1;
	
	private var dx:Number;
	private var dy:Number;
	
	private var soff:Number;
	private var soffx:Number;
	private var soffy:Number;
	private var boff:Number;
	private var boffx:Number;
	private var boffy:Number;
	private var angle:Number;
	private var tx:Number;
	private var ty:Number;
	

	
	public function LightningEmitter(pcolor:uint=0xffffff, pthickness:Number=2, pgeneration:uint=0)
	{
		super();
		
		_color=pcolor;
		_thickness=pthickness;
		
		alphaFadeType=LightningFadeType.GENERATION;
		thicknessFadeType=LightningFadeType.NONE;
		
		generation=pgeneration;
		if(generation==0) init();
	}
	
	private function init():void 
	{
		randomizeSeeds();
		
		if(lifeSpan>0) startLifeTimer();
		
		//multi2=.03;
		
		startX=50;
		startY=200;
		endX=50;
		endY=600;
		
		stepEvery=4;
		_steps=50;
		
		sbd=new BitmapData(_steps, 1, false);
		bbd=new BitmapData(_steps, 1, false);
		soffs=[new Point(0, 0), new Point(0, 0)];
		boffs=[new Point(0, 0), new Point(0, 0)];
		
		if(generation==0) 
		{
			smooth=new Sprite();
			childrenSmooth=new Sprite();
			smoothPercentage=50;
			childrenSmoothPercentage=50;
		} 
		else 
		{
			smooth=childrenSmooth=parentInstance.childrenSmooth;
		}
		
		steps=100;
		childrenLengthDecay=.5;
		
		initialized=true;
	}
	
	private function randomizeSeeds():void 
	{
		seed1=Math.random()*100;
		seed2=Math.random()*100;
	}
	
	public function set steps(arg:uint):void 
	{
		if(arg<2) arg=2;
		if(arg>2880) arg=2880;
		_steps=arg;
		sbd=new BitmapData(_steps, 1, false);
		bbd=new BitmapData(_steps, 1, false);
		if(generation==0) smoothPercentage=smoothPercentage;
	}
	
	public function get steps():uint 
	{
		return _steps;
	}
	
	public function startLifeTimer():void
	{
		lifeTimer=new Timer(lifeSpan*1000, 1);
		lifeTimer.start();
		lifeTimer.addEventListener(TimerEvent.TIMER, onTimer);
	}
	
	private function onTimer(event:TimerEvent):void
	{
		kill();
	}
	
	public function kill():void 
	{
		killAllChildren();
		
		if(lifeTimer) 
		{
			lifeTimer.removeEventListener(TimerEvent.TIMER, kill);
			lifeTimer.stop();
		}
		
		if(parentInstance!=null) 
		{
			var count:uint=0;
			var par:LightningEmitter=this.parentInstance as LightningEmitter;
			for each(var obj:Object in par.childrenArray) 
			{
				if(obj.instance==this) 
				{
					par.childrenArray.splice(count, 1);
				}
				count++;
			}
		}

		delete this;
	}
	
	public function killAllChildren():void
	{
		while(childrenArray.length>0) 
		{
			var child:LightningEmitter=childrenArray[0].instance;
			child.kill();
		}
	}
	
	public function generateChild(n:uint=1, recursive:Boolean=false):void 
	{
		if(generation<childrenMaxGenerations && childrenArray.length<childrenMaxCount) 
		{
			var targetChildSteps:uint=steps*childrenLengthDecay;
			if(targetChildSteps>=2) 
			{
				for(var i:uint=0; i<n; i++) 
				{
					var startStep:uint=Math.random()*steps;
					var endStep:uint=Math.random()*steps;
					
					while(endStep==startStep) 
					{
						endStep=Math.random()*steps;
					}
					
					var childAngle:Number=Math.random()*childrenAngleVariation-childrenAngleVariation/2;
					
					var child:LightningEmitter=new LightningEmitter(color, thickness, generation+1);
					
					child.parentInstance=this;
					child.lifeSpan=Math.random()*(childrenLifeSpanMax-childrenLifeSpanMin)+childrenLifeSpanMin;
					child.position=1-startStep/steps;
					child.absolutePosition=absolutePosition*child.position;
					child.alphaFadeType=alphaFadeType;
					child.thicknessFadeType=thicknessFadeType;
					
					if(alphaFadeType==LightningFadeType.GENERATION) 
					{
						child.alpha=1-(1/(childrenMaxGenerations+1))*child.generation;
					}
					
					if(thicknessFadeType==LightningFadeType.GENERATION) 
					{
						child.thickness=thickness-(thickness/(childrenMaxGenerations+1))*child.generation;
					}
					
					child.childrenMaxGenerations=childrenMaxGenerations;
					child.childrenMaxCount=childrenMaxCount*(1-childrenMaxCountDecay);
					child.childrenProbability=childrenProbability*(1-childrenProbabilityDecay);
					child.childrenProbabilityDecay=childrenProbabilityDecay;
					child.childrenLengthDecay=childrenLengthDecay;
					child.childrenDetachedEnd=childrenDetachedEnd;
					
					child.wavelength=wavelength;
					child.amplitude=amplitude;
					child.amplitude2=amplitude2;
					child.speed=speed;
					
					child.init();
					
					var helper:ChildHelper = new ChildHelper;
					helper.instance = child;
					helper.startStep = startStep;
					helper.endStep = endStep;
					helper.detachedEnd = childrenDetachedEnd;
					helper.childAngle = childAngle;
					
					childrenArray.push(helper);
	
					child.steps=steps*(1-childrenLengthDecay);
					if(recursive) child.generateChild(n, true);
				}
			}
		}
	}
	
	
	public function update(context:ParticlesContext):void 
	{
		if(initialized) 
		{
			
			dx=endX-startX;
			dy=endY-startY;
			len=Math.sqrt(dx*dx+dy*dy);
			
			soffs[0].x+=(steps/100)*speed;
			soffs[0].y+=(steps/100)*speed;
			sbd.perlinNoise(steps/20, steps/20, 1, seed1, false, true, 7, true, soffs);
			
			calculatedWavelength=steps*wavelength;
			calculatedSpeed=(calculatedWavelength*.1)*speed;
			boffs[0].x-=calculatedSpeed;
			boffs[0].y+=calculatedSpeed;
			bbd.perlinNoise(calculatedWavelength, calculatedWavelength, 1, seed2, false, true, 7, true, boffs);
			
			if(smoothPercentage>0) 
			{
				var drawMatrix:Matrix=new Matrix();
				drawMatrix.scale(steps/smooth.width,1);
				bbd.draw(smooth, drawMatrix);
			}
			
			if(parentInstance!=null) 
			{
				isVisible=parentInstance.isVisible;
			} 
			else 
			{
				if(maxLength==0) 
				{
					isVisible=true;
				} 
				else 
				{
					var isVisibleProbability:Number;
					
					if(len<=maxLength) 
					{
						isVisibleProbability=1;
					} 
					else if(len>maxLength+maxLengthVary) 
					{
						isVisibleProbability=0;
					} 
					else 
					{
						isVisibleProbability=1-(len-maxLength)/maxLengthVary;
					}
					
					isVisible=Math.random() < isVisibleProbability ? true : false;
				}
			}
			
			var generateChildRandom:Number=Math.random();
			
			if(generateChildRandom<childrenProbability) 
			{
				generateChild();
			}
			
			if(isVisible) 
			{
				draw(context);
			}
			
			var childObject:ChildHelper;
			
			for each (childObject in childrenArray) 
			{
				childObject.instance.update(context);
			}
		}
	}
	
	public function draw(context:ParticlesContext):void 
	{
		//holder.graphics.lineStyle(thickness, _color);
		
		angle = Math.atan2(endY-startY, endX-startX);
		
		var childObject:ChildHelper;
		var ptBegin:Point = new Point;
		var ptEnd:Point = new Point;
		
		for (var i:uint=0; i<steps; i++) 
		{
			var currentPosition:Number=1/steps*(steps-i)
			var relAlpha:Number=1;
			var relThickness:Number=thickness;
			
			if(alphaFadeType==LightningFadeType.TIP_TO_END) 
			{						
				relAlpha=absolutePosition*currentPosition;
			}
			if(thicknessFadeType==LightningFadeType.TIP_TO_END) 
			{						
				relThickness=thickness*(absolutePosition*currentPosition);
			}
			
			if(alphaFadeType == LightningFadeType.TIP_TO_END || thicknessFadeType == LightningFadeType.TIP_TO_END) 
			{
				//holder.graphics.lineStyle(int(relThickness), _color, relAlpha);
			}
			
			//Perlin
			soff=(sbd.getPixel(i, 0)-0x808080)/0xffffff*len*amplitude2;
			//Random
			//soff=Math.random()*len*multi2;
			soffx=Math.sin(angle)*soff;
			soffy=Math.cos(angle)*soff;
			
			//Perlin
			boff=(bbd.getPixel(i, 0)-0x808080)/0xffffff*len*amplitude;
			//Random
			//boff=Math.random()*len*amplitude;
			boffx=Math.sin(angle)*boff;
			boffy=Math.cos(angle)*boff;
			
			tx=startX+dx/(steps-1)*i+soffx+boffx;
			ty=startY+dy/(steps-1)*i-soffy-boffy;

			
			if (i==0)
			{
				ptBegin.x = tx;
				ptBegin.y = ty;
				//holder.graphics.moveTo(tx, ty);
			}
			else
			{
				ptBegin.x = ptEnd.x;
				ptBegin.y = ptEnd.y;
			}
			
			ptEnd.x = tx;
			ptEnd.y = ty;
			
			//holder.graphics.lineTo(tx, ty);
			
			if(context.index < context.listParticles.length)
			{
				var particle:Particle = context.listParticles[context.index];
			
				particle.x = (ptBegin.x + ptEnd.x)/2;
				particle.y = (ptBegin.y + ptEnd.y)/2;
				particle.alpha = relAlpha;
				particle.color = _color;
				particle.scaleY = relThickness * 0.1;
				particle.scaleX = (Point.distance(ptBegin, ptEnd) + 10)/32;
				particle.rotation = Math.atan2(ptEnd.y - ptBegin.y, ptEnd.x - ptBegin.x);
			
			
				context.index++;
			}
			
			
			for each (childObject in childrenArray) 
			{
				if(childObject.startStep==i) 
				{
					childObject.instance.startX=tx;
					childObject.instance.startY=ty;
				}
				if(childObject.detachedEnd) 
				{
					var arad:Number=angle+childObject.childAngle/180*Math.PI;
					
					var childLength:Number=len*childrenLengthDecay;
					childObject.instance.endX=childObject.instance.startX+Math.cos(arad)*childLength;
					childObject.instance.endY=childObject.instance.startY+Math.sin(arad)*childLength;
				} 
				else 
				{
					if(childObject.endStep==i) 
					{
						childObject.instance.endX=tx;
						childObject.instance.endY=ty;
					}
				}
			}
		}
	}
	public function killSurplus():void
	{
		while(childrenArray.length>childrenMaxCount) 
		{
			var child:LightningEmitter=childrenArray[childrenArray.length-1].instance;
			child.kill();
		}
	}
	
	public function set smoothPercentage(arg:Number):void 
	{
		if(smooth)
		{
			_smoothPercentage=arg;
			
			var smoothmatrix:Matrix=new Matrix();
			smoothmatrix.createGradientBox(steps, 1);
			var ratioOffset:uint=_smoothPercentage/100*128;			
			
			smooth.graphics.clear();
			smooth.graphics.beginGradientFill("linear", [SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR], [1,0,0,1], [0,ratioOffset,255-ratioOffset,255], smoothmatrix);
			smooth.graphics.drawRect(0, 0, steps, 1);
			smooth.graphics.endFill();
		}
	}
	
	public function set childrenSmoothPercentage(arg:Number):void 
	{
		_childrenSmoothPercentage=arg;
		
		var smoothmatrix:Matrix=new Matrix();
		smoothmatrix.createGradientBox(steps, 1);
		var ratioOffset:uint=_childrenSmoothPercentage/100*128;			
		
		childrenSmooth.graphics.clear();
		childrenSmooth.graphics.beginGradientFill("linear", [SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR, SMOOTH_COLOR], [1,0,0,1], [0,ratioOffset,255-ratioOffset,255], smoothmatrix);
		childrenSmooth.graphics.drawRect(0, 0, steps, 1);
		childrenSmooth.graphics.endFill();
	}
	
	public function get smoothPercentage():Number 
	{
		return _smoothPercentage;
	}
	
	public function get childrenSmoothPercentage():Number 
	{
		return _childrenSmoothPercentage;
	}
	
	public function set color(arg:uint):void 
	{
		_color=arg;
		glow.color=arg;

		for each(var child:Object in childrenArray) child.instance.color=arg;
	}
	
	public function get color():uint 
	{
		return _color;
	}
	
	public function set childrenProbability(arg:Number):void 
	{
		if(arg>1) { arg=1 } else if(arg<0) arg=0;
		_childrenProbability=arg;
	}
	
	public function get childrenProbability():Number 
	{
		return _childrenProbability;
	}
	
	public function set childrenProbabilityDecay(arg:Number):void 
	{
		if(arg>1) { arg=1 } else if(arg<0) arg=0;
		_childrenProbabilityDecay=arg;
	}
	
	public function get childrenProbabilityDecay():Number 
	{
		return _childrenProbabilityDecay;
	}
	
	public function set maxLength(arg:Number):void
	{
		_maxLength=arg;
	}
	
	public function get maxLength():Number 
	{
		return _maxLength;
	}
	
	public function set maxLengthVary(arg:Number):void
	{
		_maxLengthVary=arg;
	}
	
	public function get maxLengthVary():Number
	{
		return _maxLengthVary;
	}
	
	public function set thickness(arg:Number):void 
	{
		if(arg<0) arg=0;
		_thickness=arg;
	}
	
	public function get thickness():Number 
	{
		return _thickness;
	}
	
	public function set thicknessDecay(arg:Number):void
	{
		if(arg>1) { arg=1 } else if(arg<0) arg=0;
		_thicknessDecay=arg;
	}
	
	public function get thicknessDecay():Number
	{
		return _thicknessDecay;
	}
	
	public function set childrenLengthDecay(arg:Number):void 
	{
		if(arg>1) { arg=1 } else if(arg<0) arg=0;
		_childrenLengthDecay=arg;
	}
	
	public function get childrenLengthDecay():Number 
	{
		return _childrenLengthDecay;
	}
	
	public function set childrenMaxGenerations(arg:uint):void
	{
		_childrenMaxGenerations=arg;
		killSurplus();
	}
	
	public function get childrenMaxGenerations():uint
	{
		return _childrenMaxGenerations;
	}
	
	public function set childrenMaxCount(arg:uint):void
	{
		_childrenMaxCount=arg;
		killSurplus();
	}
	
	public function get childrenMaxCount():uint 
	{
		return _childrenMaxCount;
	}
	
	public function set childrenMaxCountDecay(arg:Number):void 
	{
		if(arg>1) { arg=1 } else if(arg<0) arg=0;
		_childrenMaxCountDecay=arg;
	}
	
	public function get childrenMaxCountDecay():Number 
	{
		return _childrenMaxCountDecay;
	}
	
	public function set childrenAngleVariation(arg:Number):void 
	{
		_childrenAngleVariation=arg;
		for each(var o:Object in childrenArray) {
			o.childAngle=Math.random()*arg-arg/2;
			o.instance.childrenAngleVariation=arg;
		}
	}
	
	public function get childrenAngleVariation():Number 
	{
		return _childrenAngleVariation;
	}
	
	public function set childrenLifeSpanMin(arg:Number):void 
	{
		_childrenLifeSpanMin=arg;
	}
	
	public function get childrenLifeSpanMin():Number 
	{
		return _childrenLifeSpanMin;
	}
	
	public function set childrenLifeSpanMax(arg:Number):void 
	{
		_childrenLifeSpanMax=arg;
	}
	
	public function get childrenLifeSpanMax():Number 
	{
		return _childrenLifeSpanMax;
	}
	
	public function set childrenDetachedEnd(arg:Boolean):void 
	{
		_childrenDetachedEnd=arg;
	}
	
	public function get childrenDetachedEnd():Boolean
	{
		return _childrenDetachedEnd;
	}
	
	public function set wavelength(arg:Number):void
	{
		_wavelength=arg;
		for each(var o:Object in childrenArray) 
		{
			o.instance.wavelength=arg;
		}
	}
	
	public function get wavelength():Number 
	{
		return _wavelength;
	}
	
	public function set amplitude(arg:Number):void 
	{
		_amplitude=arg;
		for each(var o:Object in childrenArray)
		{
			o.instance.amplitude=arg;
		}
	}
	
	public function get amplitude():Number
	{
		return _amplitude;
	}
	
	public function set amplitude2(arg:Number):void 
	{
		_amplitude2=arg;
		for each(var o:Object in childrenArray)
		{
			o.instance.amplitude2=arg;
		}
	}
	
	public function get amplitude2():Number
	{
		return _amplitude2;
	}
	
	public function set speed(arg:Number):void 
	{
		_speed=arg;
		for each(var o:Object in childrenArray) 
		{
			o.instance.speed=arg;
		}
	}
	
	public function get speed():Number 
	{
		return _speed;
	}
	
	public function set isVisible(arg:Boolean):void 
	{
		_isVisible=arg;
	}
	
	public function get isVisible():Boolean 
	{
		return _isVisible;
	}
}



class ChildHelper
{
	public var instance:LightningEmitter;
	public var startStep:int;
	public var endStep:int;
	public var detachedEnd:Boolean;
	public var childAngle:Number = 0;
	
	
}



class LightningFadeType 
{
	public static const NONE:String="none";
	public static const GENERATION:String="generation";
	public static const TIP_TO_END:String="tip";
}


