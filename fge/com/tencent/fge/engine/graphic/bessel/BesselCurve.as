package com.tencent.fge.engine.graphic.bessel
{ 
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class BesselCurve extends Sprite 
	{ 
		private var m_lstPoint:Array = new Array(); 
		private var m_lstShape:Array = new Array();
		private var m_state:String = BesselState.DRAW;
		private var m_shape:BesselShape;
		private var m_iPt:int;
		private var m_background:Sprite = new Sprite;
		private var m_clrL:Number = 0xff0000;
		private var m_clrR:Number = 0xff0000;
		private var m_clr:Number = 0xff0000;
		private var m_lineWidth:Number = 2;
		private var m_lineColor:Number = 0xff0000;
		private var m_lineAlpha:Number = 100;
		
		public function BesselCurve() 
		{
			this.doubleClickEnabled = true; 
			this.addEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			this.addEventListener(MouseEvent.DOUBLE_CLICK,onDoubleClick); 		

			m_background.mouseEnabled = false;
			addChild(m_background);

			drawBackground();
			m_shape = createShape(0);
		}
		
		public function set color(value:Number):void
		{
			m_clr = value;
			m_clrL = value;
			m_clrR = value;
		}
		
		
		//--------------------------------------------------------------------
		//--------------------------------------------------------------------
		
		private function createShape(i:int):BesselShape
		{
			var shape:BesselShape = new BesselShape;
			shape.iPt1 = i;
			shape.iPt2 = i + 1;
			addChild(shape);
			shape.mouseEnabled = false;
			m_lstShape[i] = shape;
			return shape;
		}
		
		private function findShape():BesselShape
		{
			var shape:BesselShape = null;
			var pt:Point = new Point(this.mouseX, this.mouseY);
			var lst:Array = this.getObjectsUnderPoint(pt);
			if(lst.length > 0)
			{
				shape = lst[lst.length - 1] as BesselShape;
			}
			return shape;
		}
		
		private function clearShapeBesselPoint(shape:BesselShape):void
		{
			if(shape == null) return;
			
			shape.graphics.clear();
			var b1:BesselPoint = m_lstPoint[shape.iPt1];
			var b2:BesselPoint = m_lstPoint[shape.iPt2];
			drawBesselCurve(shape, b1.c, b1.r, b2.l, b2.c, m_lineWidth, m_lineColor, m_lineAlpha); 
		}
		
		private function overShape(shape:BesselShape):void
		{
			if(shape == null) return;
			
			shape.graphics.clear();
			var b1:BesselPoint = m_lstPoint[shape.iPt1];
			var b2:BesselPoint = m_lstPoint[shape.iPt2];
			drawBesselCurve(shape, b1.c, b1.r, b2.l, b2.c, m_lineWidth, m_lineColor, m_lineAlpha); 
			
			drawBesselCtlPoint(shape, b1, 1, 0x33FF00, 60); 
			drawBesselCtlPoint(shape, b2, 1, 0x33FF00, 60); 
		}
		
		private function selectShape(shape:BesselShape):void
		{
			if(shape == null) return;
			
			shape.graphics.clear();
			var b1:BesselPoint = m_lstPoint[shape.iPt1];
			var b2:BesselPoint = m_lstPoint[shape.iPt2];
			drawBesselCurve(shape, b1.c, b1.r, b2.l, b2.c, m_lineWidth+2, m_lineColor, m_lineAlpha+10); 
			
			drawBesselCtlPoint(shape, b1, 1, 0x33FF00, 60); 
			drawBesselCtlPoint(shape, b2, 1, 0x33FF00, 60); 
		}
		
		
		//--------------------------------------------------------------------
		
		private function overPoint(shape:BesselShape):void
		{
			shape.graphics.clear();
			var b1:BesselPoint = m_lstPoint[shape.iPt1];
			var b2:BesselPoint = m_lstPoint[shape.iPt2];
			drawBesselCurve(shape, b1.c, b1.r, b2.l, b2.c, m_lineWidth+2, m_lineColor, m_lineAlpha+10); 
			
			drawBesselCtlPoint(shape, b1, 2, 0xeeFF00, 60); 
			drawBesselCtlPoint(shape, b2, 2, 0xeeFF00, 60); 
		}
		
		private function findCtlPoint(shape:BesselShape):int
		{
			var pt:Point = new Point(this.mouseX, this.mouseY);
			var b1:BesselPoint = m_lstPoint[shape.iPt1];
			var b2:BesselPoint = m_lstPoint[shape.iPt2];
			if( Point.distance(b1.l, pt) < 5 )
			{
				return shape.iPt1;
			}
			if( Point.distance(b1.r, pt) < 5 )
			{
				return shape.iPt1;
			}
			if( Point.distance(b2.l, pt) < 5 )
			{
				return shape.iPt2;
			}
			if( Point.distance(b2.r, pt) < 5 )
			{
				return shape.iPt2;
			}

			return -1;			
		}
		
		private function findFixPoint(shape:BesselShape):int
		{
			var pt:Point = new Point(this.mouseX, this.mouseY);
			var b1:BesselPoint = m_lstPoint[shape.iPt1];
			var b2:BesselPoint = m_lstPoint[shape.iPt2];
			if( Point.distance(b1.c, pt) < 5 )
			{
				return shape.iPt1;
			}
			if( Point.distance(b2.c, pt) < 5 )
			{
				return shape.iPt2;
			}
			
			return -1;			
		}
		
		//--------------------------------------------------------------------

		
		private function onAddToStage(e:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddToStage);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onDown); 
			stage.addEventListener(MouseEvent.MOUSE_UP,onUp); 
		}
		
		private function drawBackground():void
		{
			m_background.graphics.clear();
			var rc:Rectangle = this.getBounds(this);
			m_background.graphics.beginFill(0xffffff, 0.1);
			m_background.graphics.lineStyle(1,0xff00ff,0.5);
			m_background.graphics.drawRect(rc.x,rc.y,rc.width,rc.height);
			m_background.graphics.endFill();
		}
		
		private function clearBackground():void
		{
			m_background.graphics.clear();
		}
		
		private function onDown(e:MouseEvent):void 
		{ 
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onMove); 
			
			switch(m_state)
			{
			case BesselState.DRAW:
				m_state = BesselState.DRAW_FIX_PT;
				m_lstPoint.push(new BesselPoint(mouseX,mouseY)); 
				break;
			case BesselState.DRAW_FIX_PT:
				m_state = BesselState.DRAW_CTL_PT;
				m_lstPoint.push(new BesselPoint(mouseX,mouseY)); 
				break;
			case BesselState.DRAW_CTL_PT:
				m_state = BesselState.DRAW_FIX_PT;
				break;
			case BesselState.END:
				var shape:BesselShape = findShape();
				if(shape != m_shape)
				{
					clearShapeBesselPoint(m_shape);
					m_shape = shape;
					overShape(m_shape);
				}
				if(m_shape)
				{
					selectShape(m_shape);
					m_state = BesselState.EDIT;
				}
				break;
			case BesselState.EDIT:
				var iPt:int = findFixPoint(m_shape);
				if(iPt >= 0)
				{
					m_state = BesselState.EDIT_FIX_PT;
				}
				else
				{
					iPt = findCtlPoint(m_shape);
					if(iPt >= 0)
					{
						m_state = BesselState.EDIT_CTL_PT;
					}
				}
				
				if(iPt >= 0)
				{
					m_iPt = iPt;
					overPoint(m_shape);
				}

				break;
			default:break;
			}
		} 
		
		private function onUp(e:MouseEvent):void 
		{ 
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMove); 
			switch(m_state)
			{
				case BesselState.DRAW_CTL_PT:
					//addBesselCurve(this, m_lstPoint, 2, m_clrL, 100); 
					drawBackground();
					if(m_lstPoint.length > 1)
					{
						clearShapeBesselPoint(m_shape);
						m_shape = createShape(m_lstPoint.length - 1);
					}
					break;
				default:break;
			}
		} 
		
		private function onMove(e:MouseEvent):void 
		{ 
			var newPoint:Point;
			var oldPoint:BesselPoint;
			var mouseDown:Boolean = e.buttonDown;
			if (mouseDown) 
			{ 
				switch(m_state)
				{
					case BesselState.DRAW_FIX_PT:
						if (m_lstPoint.length>0) 
						{ 
							newPoint = new Point(mouseX, mouseY); 
							oldPoint = m_lstPoint[m_lstPoint.length - 1]; 
							m_shape.graphics.clear(); 
							drawBesselCurve(m_shape, newPoint, newPoint, oldPoint.r, oldPoint.c, 0, 0x33FF00, 80); 
						} 
						break;
					case BesselState.DRAW_CTL_PT:
						newPoint = new Point(mouseX,mouseY); 
						oldPoint = m_lstPoint[m_lstPoint.length - 1]; 
						oldPoint.r = newPoint; 
						oldPoint.l = Point.interpolate(oldPoint.c,oldPoint.r,2); 
						drawBesselPoint(m_shape, m_lstPoint, 0, 0x33FF00, 60); 
						break;
					case BesselState.EDIT_FIX_PT:
						newPoint = new Point(mouseX, mouseY); 
						oldPoint = m_lstPoint[m_iPt]; 
						var dx:Number = oldPoint.c.x - newPoint.x;
						var dy:Number = oldPoint.c.y - newPoint.y;
						var oldPtC:BesselPoint = oldPoint.clone();
						oldPtC.l.offset(-dx,-dy);
						oldPtC.r.offset(-dx,-dy);
						//var oldPtL:BesselPoint = m_lstPoint[m_iPt - 1];
						var oldPtR:BesselPoint = m_lstPoint[m_iPt + 1];
						
						m_shape.graphics.clear();
						drawBesselCurve(m_shape, oldPtC.c, oldPtC.l, oldPtR.r, oldPtR.c, 0, 0x33FF00, 80); 
						drawBesselCtlPoint(m_shape, oldPtC, 1, 0x33FF00, 60); 
						drawBesselCtlPoint(m_shape, oldPtR, 1, 0x33FF00, 60); 
						break;
					case BesselState.EDIT_CTL_PT:
						newPoint = new Point(mouseX,mouseY); 
						oldPoint = m_lstPoint[m_iPt]; 
						oldPoint.r = newPoint; 
						oldPoint.l = Point.interpolate(oldPoint.c,oldPoint.r,2); 
						drawBesselPoint(m_shape, m_lstPoint, 0, 0x33FF00, 60); 		
						
						overShape(m_shape);
						break;
					default:break;
				}
			}
			else
			{
				switch(m_state)
				{
					case BesselState.END:
						var shape:BesselShape = findShape();
						if(shape != m_shape)
						{
							clearShapeBesselPoint(m_shape);
							m_shape = shape;
							overShape(m_shape);
						}
						break;
					case BesselState.EDIT:
						if(findFixPoint(m_shape) >= 0)
						{
							overPoint(m_shape);
						}
						if(findCtlPoint(m_shape) >= 0)
						{
							overPoint(m_shape);
						}
						break;
					default:break;
				}

			}
			
			e.updateAfterEvent(); 
		} 
		
		private function onDoubleClick(e:MouseEvent):void 
		{ 
			clearBackground();
			m_lstPoint.push(m_lstPoint[0]); 
			m_shape.graphics.clear(); 
			m_state = BesselState.END;
			
			overShape(m_shape);
			//m_lstPoint = new Array(); 
		} 
		
		
		
		private function drawBesselPoint(target:Sprite,bpArr:Array,lineWidth:Number,lineColor:Number,lineAlpha:Number):void 
		{ 
			target.graphics.clear(); 
			addBesselCurve(target, bpArr, lineWidth, lineColor, lineAlpha); 
			if (bpArr.length>1) 
			{ 
				var b1:BesselPoint = bpArr[bpArr.length-2]; 
				drawBesselCtlPoint(target, b1, 1, lineColor, lineAlpha); 
			} 
			var b2:BesselPoint = bpArr[bpArr.length-1]; 
			drawBesselCtlPoint(target, b2, 1, lineColor, lineAlpha); 
			
			
		} 
		
		private function drawBesselCtlPoint(target:Sprite, bp:BesselPoint, lineWidth:Number, lineColor:Number, lineAlpha:Number):void 
		{ 
			target.graphics.lineStyle(lineWidth, lineColor, lineAlpha/2); 
			target.graphics.moveTo(bp.c.x, bp.c.y); 
			target.graphics.lineTo(bp.r.x, bp.r.y); 
			target.graphics.lineStyle(lineWidth*3, lineColor, lineAlpha); 
			target.graphics.lineTo(bp.r.x, bp.r.y+.5); 
			
			target.graphics.lineStyle(lineWidth, lineColor, lineAlpha/2); 
			target.graphics.moveTo(bp.c.x, bp.c.y); 
			target.graphics.lineTo(bp.l.x, bp.l.y); 
			target.graphics.lineStyle(lineWidth*3, lineColor, lineAlpha); 
			target.graphics.lineTo(bp.l.x, bp.l.y+.5); 
			
			//target.graphics.moveTo(bp.c.x, bp.c.y); 
			target.graphics.drawCircle(bp.c.x, bp.c.y, 3);
		} 
		
		private function addBesselCurve(target:Sprite,bpArr:Array,lineWidth:Number,lineColor:Number,lineAlpha:Number):void 
		{ 
			if (bpArr.length>1) 
			{ 
				var b1:BesselPoint = bpArr[bpArr.length-2]; 
				var b2:BesselPoint = bpArr[bpArr.length-1]; 
				drawBesselCurve(target, b1.c, b1.r, b2.l, b2.c, lineWidth, lineColor, lineAlpha); 
			} 
		} 
		
		private function drawBesselCurve(target:Sprite, a:Point, b:Point, c:Point, d:Point, lineWidth:Number,lineColor:Number,lineAlpha:Number):void
		{ 
			var b_len:Number = b.subtract(a).length; 
			var c_len:Number = c.subtract(d).length; 
			if (b_len == 0 && c_len == 0) 
			{ 
				var e:Point = Point.interpolate(a, d, .5); 
			} 
			else 
			{ 
				e = Point.interpolate(c, b, .5); 
			} 
			target.graphics.lineStyle(lineWidth, lineColor, lineAlpha); 
			target.graphics.moveTo(a.x, a.y); 
			target.graphics.curveTo(b.x, b.y, e.x, e.y); 
			target.graphics.lineStyle(lineWidth, m_clrR, lineAlpha); 
			target.graphics.curveTo(c.x, c.y, d.x, d.y); 
		} 
		
	} 
}


