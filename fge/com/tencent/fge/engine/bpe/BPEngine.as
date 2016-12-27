package com.tencent.fge.engine.bpe
{
	
	import flash.display.DisplayObjectContainer;
	import com.tencent.fge.engine.bpe.BpeVector;

	public final class BPEngine 
	{
		public static var DEBUG:Boolean = false;
		
		internal static var coefAirResist:Number = 0;
		internal static var force:BpeVector;//环境力,除以质量得到环境加速度
		internal static var masslessForce:BpeVector;//重力加速度
		internal static var damping:Number = 1;//这是用来计算阻尼的
		internal static var collisionDetector:IBpeCollisionDetector;//碰撞检测器
		private static var groups:Array;
		private static var numGroups:int;
		
		
		
		private static var timeCoef:Number = 1/200.0;//时间系数
		private static var timeStep:Number;//每一步的时间值，可以与实际帧率无关，也可以相关
		private static var timeStep2:Number;//每一步的时间值，可以与实际帧率无关，也可以相关
		
		private static var m_width:Number = 0;
		private static var m_height:Number = 0;
		
		public static function initialize(dt:Number = 0.25):void 
		{
			timeStep = dt;
			timeStep2 = dt * dt;//用于公式：0.5at^2
			
			numGroups = 0;
			groups = new Array();
			
			force = new BpeVector(0,0);
			masslessForce = new BpeVector(0,0);
		}
		
		public static function finalize():void
		{
			
		}
		
		
		public static function resize(w:Number, h:Number):void
		{
			m_width = w;
			m_height = h;
		}
		
		public static function get width():Number{return m_width;}
		public static function get height():Number{return m_height;}


		public static function addForce(v:BpeVector):void 
		{
			force.plusEquals(v);
		}
		
		public static function getForce():BpeVector
		{
			return force.clone();
		}
		
		
		//弹道调优：设置环境力（力量）
		public static function setForce(v:BpeVector):void
		{
			force.copy(v);
		}
		
		public static function setCollisionDetector(detector:IBpeCollisionDetector):void
		{
			collisionDetector = detector;
		}
			
		public static function addMasslessForce(v:BpeVector):void 
		{
			masslessForce.plusEquals(v);
		}
		
		
		//弹道调优：设置引力加速度（加速度）
		public static function setMasslessForce(v:BpeVector):void
		{
			masslessForce.copy(v);
		}
		
		//弹道调优：时间系统
		public static function setTimeCoef(coef:Number = 1/1000.0):void
		{
			timeCoef = coef;
		}
		
		//空气阻力系统
		public static function setAirResistCoef(coef:Number):void
		{
			coefAirResist = coef;
		}
		
		
		public static function addGroup(g:BpeGroup):void 
		{
			groups.push(g);
			g.isParented = true;
			numGroups++;
			g.initialize();
		}
		
		public static function removeGroup(g:BpeGroup):void 
		{
			var gpos:int = groups.indexOf(g);
			if (gpos == -1) return;
			
			groups.splice(gpos, 1);
			g.isParented = false;
			numGroups--;
			g.cleanup();
		}
		
		
		public static function update(dt:Number = 0):void 
		{
			if(dt > 0)
			{
				timeStep = dt * timeCoef;
				timeStep2 = timeStep * timeStep;//用于公式：0.5at^2
			}
			integrate();
			checkCollisions();
		}
		
		public static function paint():void 
		{
			for (var j:int = 0; j < numGroups; j++) 
			{
				var g:BpeGroup = groups[j];
				g.paint();
			}
		}
		
		
		private static function integrate():void 
		{	
			for (var j:int = 0; j < numGroups; j++) 
			{
				var g:BpeGroup = groups[j];
				g.integrate(timeStep, timeStep2);
			}
		}
		
		private static function checkCollisions():void 
		{
			for (var j:int = 0; j < numGroups; j++) 
			{
				var g:BpeGroup = groups[j];
				g.checkCollisions();
			}
		}	
		
	}	
}
