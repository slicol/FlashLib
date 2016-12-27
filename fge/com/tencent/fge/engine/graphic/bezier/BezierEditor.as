package com.tencent.fge.engine.graphic.bezier
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class BezierEditor extends Sprite
	{		
		private var m_bezier:BEBezierCurve;

		private var m_selectedPoint:BezierPoint=null;
		private var m_selectedType:String = "c";
		
		

		private var m_cursor:Sprite;
		private var m_cfg:XML;
		
		public function BezierEditor()
		{
			init();
			
			if(this.stage)
			{
				initListener();
			}
			else
			{
				this.addEventListener(Event.ADDED_TO_STAGE, initListener);
			}
		}
		
		private function init():void
		{
			m_bezier = new BEBezierCurve(graphics);
			m_bezier.bezierPointVisible = true;
			m_bezier.curvePointVisible = true;
			m_bezier.color = 0xff3ff3;
			m_bezier.precision = 30;
			m_bezier.precisionType = BezierCurve.PrecisionType_Number;
			
			//draw circle
			
		}

		private function initListener(args:* = null):void
		{
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		}
		
		public function updateConfig(cfg:XML):void
		{
			m_cfg = cfg;
			m_bezier.setConfig(cfg);
		}
		
		public function clear():void
		{
			m_bezier.clear();
		}
		
		
		private function updateAnchors2Config():void
		{
			if(m_cfg)
			{
				m_cfg.precision.@value = m_bezier.precision.toString();
				m_cfg.precisionType.@value = m_bezier.precisionType.toString();
				
				var s:String = BEBezierCurve.getStringFromBPoint(m_bezier.getBPoints());
				m_cfg.anchors = s;
			}
		}

		
		public function updateAllParam2Config():void
		{
			updateAnchors2Config();
		
			if(m_cfg)
			{
				var s:String = BEBezierCurve.getStringFromCurvePoints(this.getCurvePoints());
				m_cfg.points = s;
			}
		}
		
		
		public function drawCircle(x:Number, y:Number, r:Number, bpNum:int = 2):void
		{
			var pt:Point = new Point(x,y);
			var bp1:BezierPoint;
			var bp2:BezierPoint;
			var bp3:BezierPoint;
			var bp4:BezierPoint;
			
			if(bpNum == 2)
			{
				bp1 = new BezierPoint(x - r, y);
				bp1.r.x = bp1.c.x;
				bp1.r.y = bp1.c.y - 1.34*r;
				bp1.mirrorR2L(2);
				
				bp2 = new BezierPoint(0, 0);
				BezierPoint.mirror(bp2.c, pt, bp1.c, 2);
				BezierPoint.mirror(bp2.r, pt, bp1.r, 2);
				BezierPoint.mirror(bp2.l, pt, bp1.l, 2);
				
				m_bezier.addBPoints(bp1,bp2,bp1);
			}
			else
			{
				bp1 = new BezierPoint(x - r, y);
				bp1.r.x = bp1.c.x;
				bp1.r.y = bp1.c.y - 0.5*r;
				bp1.mirrorR2L(2);
				
				bp2 = new BezierPoint(x, y - r);
				bp2.r.x = bp2.c.x + 0.5*r;
				bp2.r.y = bp2.c.y;
				bp2.mirrorR2L(2);
				
				bp3 = new BezierPoint(0,0);
				BezierPoint.mirror(bp3.c, pt, bp1.c, 2);
				BezierPoint.mirror(bp3.r, pt, bp1.r, 2);
				BezierPoint.mirror(bp3.l, pt, bp1.l, 2);
				
				bp4 = new BezierPoint(0,0);
				BezierPoint.mirror(bp4.c, pt, bp2.c, 2);
				BezierPoint.mirror(bp4.r, pt, bp2.r, 2);
				BezierPoint.mirror(bp4.l, pt, bp2.l, 2);
				
				m_bezier.addBPoints(bp1,bp2,bp3, bp4, bp1);
			}
			
			
			//todo
			this.graphics.drawCircle(x, y, r);
		}
		
		
		
		public function set precision(value:int):void
		{
			m_bezier.precision = value;
			if(m_cfg)
			{
				m_cfg.precision.@value = value.toString();
			}
		}
		
		public function get precision():int
		{
			return m_bezier.precision;
		}
		
		public function set precisionType(value:int):void
		{
			m_bezier.precisionType = value;
			if(m_cfg)
			{
				m_cfg.precisionType.@value = value.toString();
			}
		}
		
		public function get precisionType():int
		{
			return m_bezier.precisionType;
		}
		
		
		public function getCurvePoints():Vector.<Point>
		{
			var lst:Vector.<Point> = new Vector.<Point>;
			m_bezier.draw(lst);
			return lst;
		}
		

		
		private function onMouseDown(e:MouseEvent):void
		{
			var pt:Point = new Point(e.stageX, e.stageY);
			pt = this.globalToLocal(pt);
			
			removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			
			var points:Vector.<BezierPoint> = m_bezier.getBPoints();
			var hitPoint:Point = new Point(pt.x, pt.y);
			
			for(var i:int = 0;i<points.length;i++)
			{
				var rect_c:Rectangle = new Rectangle(points[i].c.x-10,points[i].c.y-10,20,20);
				var rect_l:Rectangle = new Rectangle(points[i].l.x-10,points[i].l.y-10,20,20);
				var rect_r:Rectangle = new Rectangle(points[i].r.x-10,points[i].r.y-10,20,20);
				
				if(rect_l.containsPoint(hitPoint))
				{
					m_selectedPoint = points[i];
					m_selectedType = "l";
					break;
				}
				
				if(rect_r.containsPoint(hitPoint))
				{
					m_selectedPoint = points[i];
					m_selectedType = "r";
					break;
				}
				
				if(rect_c.containsPoint(hitPoint))
				{
					m_selectedPoint = points[i];
					m_selectedType = "c";
					break;
				}
			}
			
			
			if(!m_cursor)
			{
				m_cursor = new Sprite();
				m_cursor.graphics.beginFill(0x000000,0.3);
				m_cursor.graphics.drawCircle(0,0,5);
				m_cursor.graphics.endFill();
				m_cursor.mouseChildren = false;
				addChild(m_cursor);
			}
			
			m_cursor.x = pt.x;
			m_cursor.y = pt.y;
			m_cursor.visible = true;
		}
		
		
		private function onMouseMove(e:MouseEvent):void
		{
			var pt:Point = new Point(e.stageX, e.stageY);
			pt = this.globalToLocal(pt);
			m_cursor.x = pt.x;
			m_cursor.y = pt.y;
			
			if(!m_selectedPoint)
			{
				return;
			}
			
			if(e.ctrlKey || e.altKey)
			{
				return;
			}
			
			
			var dx:Number = m_selectedPoint[m_selectedType].x - pt.x;
			var dy:Number = m_selectedPoint[m_selectedType].y - pt.y;
			
			//Edit All Point
			if(e.shiftKey)
			{
				if(m_selectedType == "c")
				{
					m_bezier.offset(-dx, -dy);
				}
			}
			else
			{
				m_selectedPoint[m_selectedType].x = pt.x;
				m_selectedPoint[m_selectedType].y = pt.y;
				
				if(m_selectedType == "l")
				{
					m_selectedPoint.mirrorL2R(2);
				}
				else if(m_selectedType == "r")
				{
					m_selectedPoint.mirrorR2L(2);
				}
				else
				{
					m_selectedPoint.l.offset(-dx,-dy);
					m_selectedPoint.r.offset(-dx,-dy);	
				}
				m_bezier.draw();
			}
		}
		
		private function onMouseUp(e:MouseEvent):void
		{			
			var i:int;
			var pt:Point = new Point(e.stageX, e.stageY);
			pt = this.globalToLocal(pt);
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			
			//Add Point
			if(e.controlKey)
			{
				//没有选中关键点
				if(!m_selectedPoint)
				{
					i = m_bezier.getBPointIndexByCurvePoint(pt, 40);
					var bp:BezierPoint = new BezierPoint(pt.x, pt.y);
					var bpNear:BezierPoint;
					
					//Insert Point 
					if(i < 0)
					{
						i = m_bezier.length - 1;
					}
					
					bpNear = m_bezier.getBPoint(i);
					if(bpNear)
					{
						bp.l = Point.interpolate(bp.c, bpNear.c, 0.8);
						bp.r = Point.interpolate(bp.c, bp.l, 2);
					}
					
					m_bezier.addBPoint(bp, i + 1);
					updateAnchors2Config();
					this.dispatchEvent(new Event(Event.COMPLETE));
					return;
				}
				else
				{
					//选中了开始点
					i = m_bezier.getBPointIndex(m_selectedPoint);
					if(i >= 0)
					{
						//将曲线闭合起来
						m_bezier.addBPoint(m_selectedPoint);
						updateAnchors2Config();
						this.dispatchEvent(new Event(Event.COMPLETE));
						return;
					}
				}
			}
			

			//Del Point
			if(e.altKey)
			{
				i = m_bezier.getBPointIndex(m_selectedPoint);
				m_bezier.removeBPoints(i);
				updateAnchors2Config();
				this.dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			
			
			//Edit All Point
			if(e.shiftKey)
			{
				//Edit Point
				if(m_selectedPoint && m_selectedType == "c")
				{
					var dx:Number = m_selectedPoint[m_selectedType].x - pt.x;
					var dy:Number = m_selectedPoint[m_selectedType].y - pt.y;
					
					m_bezier.offset(-dx, -dy);
					
					m_selectedPoint = null;
					updateAnchors2Config();
					this.dispatchEvent(new Event(Event.COMPLETE));
				}
				return;
			}
			
			
			//Edit Point
			if(m_selectedPoint)
			{
				m_selectedPoint[m_selectedType].x = pt.x;
				m_selectedPoint[m_selectedType].y = pt.y;
				m_bezier.draw();
				
				m_selectedPoint = null;
				updateAnchors2Config();
				this.dispatchEvent(new Event(Event.COMPLETE));
			}
			
			if(m_cursor)
			{
				m_cursor.visible = false;
			}
			
			//End Of
		}
		
		
		
	}
	
}