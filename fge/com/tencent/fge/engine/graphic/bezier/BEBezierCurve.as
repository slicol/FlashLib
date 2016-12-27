package com.tencent.fge.engine.graphic.bezier
{
	import flash.display.Graphics;
	import flash.geom.Point;
	
	public class BEBezierCurve extends BezierCurve
	{
		public static var cfgTemplate:XML;
		
		private var m_cfg:XML;
		
		public function BEBezierCurve(target:Graphics, ...points)
		{
			super(target, points);
		}
		
		public function setConfig(cfg:XML):void
		{
			m_cfg = cfg;
			
			//Precision
			this.precision = int(cfg.precision.@value);
			this.precisionType = int(cfg.precisionType.@value);
			
			//Anchor List
			var lstPoints:Vector.<BezierPoint> = new Vector.<BezierPoint>;
			var tmp:String = 	String(cfg.anchors);
			lstPoints = getBPointFromString(tmp);
			this.clear();
			this.addBPoints(lstPoints);
		}
		
		public function getConfig():XML
		{
			return m_cfg;
		}
		
		
		
		public static function getBPointFromString(s:String):Vector.<BezierPoint>
		{
			var lstPoints:Vector.<BezierPoint> = new Vector.<BezierPoint>;
			
			var lstBP_s:Array = s.split("|");
			for(var i:int = 0; i < lstBP_s.length; ++i)
			{
				var bp_s:String = lstBP_s[i];
				var lstPT_s:Array = bp_s.split(",");
				
				if(lstPT_s.length == 6)
				{
					var bp:BezierPoint = new BezierPoint(0,0);
					bp.c = new Point(Number(lstPT_s[0]),Number(lstPT_s[1]));
					bp.l = new Point(Number(lstPT_s[2]),Number(lstPT_s[3]));
					bp.r = new Point(Number(lstPT_s[4]),Number(lstPT_s[5]));
					
					lstPoints.push(bp);
				}
			}
			
			return lstPoints;
		}
		
		public static function getStringFromBPoint(lstPoints:Vector.<BezierPoint>):String
		{
			var s:String = "";
			if(lstPoints.length == 0)
			{
				return s;
			}
			
			for(var i:int = 0; i < lstPoints.length; ++i)
			{
				var bp:BezierPoint = lstPoints[i];
				var bp_s:String = 
					bp.c.x.toFixed(0) + "," + 
					bp.c.y.toFixed(0) + "," + 
					bp.l.x.toFixed(0) + "," + 
					bp.l.y.toFixed(0) + "," + 
					bp.r.x.toFixed(0) + "," + 
					bp.r.y.toFixed(0);
				s = s + bp_s + "|";
			}
			
			return s;
		}
		
		public static function getStringFromCurvePoints(lstPoints:Vector.<Point>):String
		{
			var s:String = "";
			if(lstPoints.length == 0)
			{
				return s;
			}
			
			for(var i:int = 0; i < lstPoints.length; ++i)
			{
				var pt:Point = lstPoints[i];
				var pt_s:String = pt.x.toFixed(2) + "," + pt.y.toFixed(2);
				s = s + pt_s + "|";
			}
			
			return s;
		}
	}
}