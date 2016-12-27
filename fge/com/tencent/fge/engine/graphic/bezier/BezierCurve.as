package com.tencent.fge.engine.graphic.bezier
{
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	
	public class BezierCurve 
	{
		
		public static const PrecisionType_Length_Uniform:int = 0;
		public static const PrecisionType_Length_Natural:int = 1;
		public static const PrecisionType_Number:int = 2;
		
		
		private var m_lstBPoints:Vector.<BezierPoint> = new Vector.<BezierPoint>;
		private var m_target:Graphics;
		private var m_precision:uint = 30;
		private var m_precisionType:int = 0;
		private var m_color:uint = 0xff0000;

		
		private var m_bezierPointVisible:Boolean = false;
		private var m_curvePointVisible:Boolean = false;
		
		public function BezierCurve(target:Graphics,...points/*BezierPoint*/)
		{	
			m_target = target;
			
			var lstTmp:Array = [];
			
			for(var i:int =0; i < points.length; i++)
			{
				lstTmp = lstTmp.concat(points[i]);
			}
			addBPoints(lstTmp);
		}
		

		//----------------------------------------------------------------------
		//设置参数
		public function get graphics():Graphics{	return m_target;}
		public function set graphics(value:Graphics):void{m_target = value;}
		
		public function get color():uint{return m_color;}
		public function set color(c:uint):void
		{
			if(m_color == c)return;
			m_color = c;
			draw();
		}
		
		public function get precision():uint{	return m_precision;	}
		public function set precision(value:uint):void
		{
			if(m_precision == value)return;
			m_precision = value;
			draw();
		}
		
		public function get precisionType():uint{	return m_precisionType;}
		public function set precisionType(value:uint):void
		{
			if(m_precisionType == value)return;
			m_precisionType = value;
			draw();
		}
		
		public function get bezierPointVisible():Boolean{return m_bezierPointVisible;}
		public function set bezierPointVisible(value:Boolean):void
		{
			if(m_bezierPointVisible == value) return;
			m_bezierPointVisible = value;
			draw();
		}
		
		public function get curvePointVisible():Boolean{return m_curvePointVisible;}
		public function set curvePointVisible(value:Boolean):void
		{
			if(m_curvePointVisible==value) return ;
			m_curvePointVisible = value;
			draw();
		}
		
		public function hitTestBPoint(localPoint:Point, zoneSize:int = 20):Boolean
		{
			var rect:Rectangle = new Rectangle(0,0,zoneSize, zoneSize);
			for(var i:int = 0; i < m_lstBPoints.length; ++i)
			{
				rect.x = m_lstBPoints[i].c.x - zoneSize/2;
				rect.y = m_lstBPoints[i].c.y - zoneSize/2;
				if(rect.containsPoint(localPoint))
				{
					return true;
				}
			}
			
			return false;
		}
		
		//----------------------------------------------------------------------
		//操作数据 

		/**addPoint
		 * @param point 系统Point类型或者BezierPoint类型
		 * 				如果是Point，则会转为BezierPoint
		 */
		public function addBPoint(point:*,from:int=-1):void
		{
			var bp:BezierPoint;
			
			if(point is Point)
			{
				bp = new BezierPoint(point.x, point.y);
			}
			else
			{
				bp = point;
			}
			
			if(from==-1)
			{
				m_lstBPoints.push(bp);
			}
			else
			{
				m_lstBPoints.splice(from,0,bp);
			}
			
			draw();
		}
		
		
		/**addPoints
		 * @param points 	坐标数组。是Array类型或者Vector类型，数组元素可以是Point或者BezierPoint。
		 *					如果是Point，则会转为BezierPoint
		 */
		public function addBPoints(...points):void
		{
			var bp:BezierPoint;
			var pt:Point;
			
			for(var i:int = 0; i < points.length; i++)
			{
				if(points[i] is Array || points[i] is Vector.<BezierPoint>)
				{
					for(var j:int = 0; j < points[i].length; j++)
					{
						if(points[i][j] is Point)
						{
							pt = points[i][j];
							bp = new BezierPoint(pt.x, pt.y);
							m_lstBPoints.push(bp);
						}
						else if(points[i][j] is BezierPoint)
						{
							m_lstBPoints.push(points[i][j]);
						}
					}
					continue;
				}
				else
				{
					if(points[i] is Point)
					{
						pt = points[i];
						bp = new BezierPoint(pt.x, pt.y);
						m_lstBPoints.push(bp);
					}
					else if(points[i] is BezierPoint)
					{
						m_lstBPoints.push(points[i]);
					}
				}
			}
			
			draw();
		}
		
		
		public function getBPointIndex(point:BezierPoint):int
		{
			return m_lstBPoints.indexOf(point);
		}
		
		public function getBPointIndexByCurvePoint(pt:Point, hitSize:int = 20):int
		{
			var bp:BezierPoint;
			var bpNext:BezierPoint;
			var lstTmp:Vector.<CurvePoint> = new Vector.<CurvePoint>;
			var halfSize:Number = hitSize/2;
			
			for(var i:int = 0; i < m_lstBPoints.length - 1; ++i)
			{
				bp = m_lstBPoints[i];
				bpNext = m_lstBPoints[i + 1];
				lstTmp = new Vector.<CurvePoint>;
				drawCurveLine2Array(lstTmp, bp, bpNext);
				
				for(var j:int = 0; j < lstTmp.length; ++j)
				{
					var rect:Rectangle = new Rectangle(lstTmp[j].x-halfSize,lstTmp[j].y-halfSize,hitSize,hitSize);
					if(rect.containsPoint(pt))
					{
						return i;
					}
				}
			}
			return -1;
		}
		

		/**removePoints
		 * @param indexs 索引数组
		 */
		public function removeBPoints(...indexs):void
		{
			for(var i:int = 0; i < indexs.length; i++)
			{
				if(isNaN(indexs[i]))
				{
					throw new Error(indexs[i]+"不是一个数字对象");
				}

				var index:int = indexs[i];
				
				if(index < 0)
				{
					if(m_lstBPoints.length+index < 0)
					{
						return;
						throw new Error("索引位置"+index+" 超出数组最大长度");
					}
					
					m_lstBPoints[m_lstBPoints.length+index] = null;
				}
				else
				{
					if(m_lstBPoints.length<index)
					{
						return;
						throw new Error("索引位置"+index+" 超出数组最大长度");
					}
					
					m_lstBPoints[index] = null;
				}
			}
			
			if(m_lstBPoints.length <= 0 )
			{
				return;
			}
			
			m_lstBPoints = m_lstBPoints.filter(function(element:*,index:*,c:*):Boolean
			{
				if(element == null)return false;
				else return true;
			});
				
	
			draw();
		}
		
		

		/**getPoint
		 * @param index 索引
		 */
		public function getBPoint(index:uint):BezierPoint
		{
			if(index<m_lstBPoints.length)
			{
				return m_lstBPoints[index];
			}
			else
			{
				return null;
			}
		}
		
		/**getPoints
		 * @param from,to 索引区间
		 */
		public function getBPoints(from:int=0,to:int=16777215):Vector.<BezierPoint>
		{
			return m_lstBPoints.slice(from,to);
		}

		/**getPointsByIndexs，获取指定的坐标数组
		 * @param indexs 索引数组
		 */
		public function getBPointsByIndexs(...indexs):Vector.<BezierPoint>
		{
			var arr:Vector.<BezierPoint> = new Vector.<BezierPoint>();
			
			for(var i:int=0;i<indexs.length;i++)
			{
				arr.push(m_lstBPoints[indexs[i]]);
			}
			
			return arr;
		}
		

		public function get length():uint
		{
			return m_lstBPoints.length;
		}
		
		//-----------------------------------------------------------------
		
		public function offset(dx:Number, dy:Number):void
		{
			var bp:BezierPoint;
			var i:int = 0;
			
			for(i=0;i<m_lstBPoints.length;i++)
			{
				bp = m_lstBPoints[i];
				bp.offset(dx,dy);
			}
			
			draw();
		}

		//-----------------------------------------------------------------
		
		public function draw(target:* = null):void
		{
			if(target is Array || target is Vector.<Point> || target is Vector.<CurvePoint>)
			{
				drawCurve2Array(target);
			}
			else
			{
				drawCurve2Graphics(target);
			}
			
			
		}
		
		
		private function drawCurve2Array(target:*):void
		{
			var bp:BezierPoint;
			var bpNext:BezierPoint;
			var i:int = 0;
			
			for(i=0;i<m_lstBPoints.length - 1;i++)
			{
				bp = m_lstBPoints[i];
				bpNext = m_lstBPoints[i + 1];
				drawCurveLine2Array(target, bp, bpNext);
				if(i < m_lstBPoints.length - 2)
				{
					target.pop();
				}
			}
		}
		
		

		
		private function drawCurve2Graphics(target:Graphics):void
		{
			var pen:Graphics = target? target:m_target;
			
			if(!pen) return;
			
			pen.clear();
			
			if(m_lstBPoints.length<2)
			{
				if(m_lstBPoints.length > 0)
				{
					drawBrezierPoint2Graphics(pen, m_lstBPoints[0], true);
				}
				return;
			}
						
			
			var bp:BezierPoint;
			var bpNext:BezierPoint;
			var lstTmp:Vector.<CurvePoint> = new Vector.<CurvePoint>;
			
			for(var i:int=0;i<m_lstBPoints.length - 1;i++)
			{
				bp = m_lstBPoints[i];
				drawBrezierPoint2Graphics(pen, bp, i == 0);

				bpNext = m_lstBPoints[i + 1];
				drawCurveLine2Array(lstTmp, bp, bpNext);
			}
			
			bp = m_lstBPoints[i];
			drawBrezierPoint2Graphics(pen, bp, false);
			
			pen.endFill();
			
			
			var beginPoint:BezierPoint = m_lstBPoints[0];
			var endPoint:BezierPoint = m_lstBPoints[1];
			
			pen.lineStyle(2,color,1);
			pen.moveTo(beginPoint.c.x,beginPoint.c.y);
			
			var j:int;
			var pt:CurvePoint;
			
			for(j = 0; j<lstTmp.length; ++j)
			{
				pt = lstTmp[j];
				pen.lineTo(pt.x,pt.y);
			}
			
			if(m_curvePointVisible)
			{
				pen.beginFill(0xeeeeee,1);
				for(j = 0; j<lstTmp.length; ++j)
				{
					pt = lstTmp[j];
					pen.drawCircle(pt.x, pt.y, 2);
				}
			}
		}
		
		private function drawBrezierPoint2Graphics(target:Graphics, bp:BezierPoint, isBeginPoint:Boolean):void
		{
			target.lineStyle(1, 0xeeff00, 0.5);
			if(isBeginPoint)
			{
				target.beginFill(0xff0000,1);
				target.drawRect(bp.c.x - 7,bp.c.y - 7,14,14);
			}
			else
			{
				target.beginFill(0x333333,1);
				target.drawCircle(bp.c.x,bp.c.y,7);
			}
			
			if(!m_bezierPointVisible)
			{
				return;
			}
			
			target.beginFill(0x2222ff,1);
			target.drawRect(bp.l.x - 3, bp.l.y - 3, 6,6);
			
			target.beginFill(0x22eeff,1);
			target.drawRect(bp.r.x - 3, bp.r.y - 3, 6,6);
			
			target.lineStyle(1, 0xeeff00, 0.5);
			target.moveTo(bp.c.x, bp.c.y);
			target.lineTo(bp.l.x, bp.l.y);
			target.moveTo(bp.c.x, bp.c.y);
			target.lineTo(bp.r.x, bp.r.y);
			
			
		}
		
		private function drawCurveLine2Array(target:*, beginPoint:BezierPoint, endPoint:BezierPoint):void
		{
			//--这是4个控制点
			var x0:Number = beginPoint.c.x;
			var y0:Number = beginPoint.c.y;
			
			var xr:Number = beginPoint.r.x;
			var yr:Number = beginPoint.r.y;
			
			var xl:Number = endPoint.l.x;
			var yl:Number = endPoint.l.y;
			
			var x2:Number = endPoint.c.x;
			var y2:Number = endPoint.c.y;
			//---
			
			//
			var t:Number = 0;//时间轴
			var xp:Number = 0;//曲线点X
			var yp:Number = 0;//曲线点Y
			var num:int = m_precision;//精度，可以是长度，也可以是分段数量
			
			var xb:Number = x0;//临时参数
			var yb:Number = y0;//临时参数
			var s:Number = 0;//长度
			var ds:Number = 0;//速度
			
			var integral:int = 1000;//积分精度
			
			if(m_precisionType == PrecisionType_Length_Natural)
			{
				
				
				for (t=0; t<=1; t+=1/integral)
				{
					xp = (1 - t) * (1 - t) *(1 - t) * x0 + 3 * t * (1 - t) * (1 - t) * xr + 3 * t * t * (1 - t) * xl + t * t *  t * x2;
					yp = (1 - t) * (1 - t) *(1 - t) * y0 + 3 * t * (1 - t) * (1 - t) * yr + 3 * t * t * (1 - t) * yl + t * t *  t * y2;
					ds = Math.sqrt((xp-xb)*(xp-xb) + (yp-yb)*(yp-yb));
					s += ds;
					xb = xp;
					yb = yp;
				}

				num = s / m_precision;
				
				for (t=0; t<=1; t+=1/num)
				{
					xp = (1 - t) * (1 - t) *(1 - t) * x0 + 
						3 * t * (1 - t) * (1 - t) * xr + 
						3 * t * t * (1 - t) * xl + 
						t * t *  t * x2;
					yp = (1 - t) * (1 - t) *(1 - t) * y0 + 
						3 * t * (1 - t) * (1 - t) * yr + 
						3 * t * t * (1 - t) * yl +
						t * t *  t * y2;
					target.push(new CurvePoint(xp, yp));
				}
				
			}
			else if(m_precisionType == PrecisionType_Length_Uniform)
			{
				var mapLen:Vector.<Number> = new Vector.<Number>;
				var mapSpeed:Vector.<Number> = new Vector.<Number>;

				//计算总长度
				for (t=0; t<=1; t+=1/integral)
				{
					xp = (1 - t) * (1 - t) *(1 - t) * x0 + 3 * t * (1 - t) * (1 - t) * xr + 3 * t * t * (1 - t) * xl + t * t *  t * x2;
					yp = (1 - t) * (1 - t) *(1 - t) * y0 + 3 * t * (1 - t) * (1 - t) * yr + 3 * t * t * (1 - t) * yl + t * t *  t * y2;
					ds = Math.sqrt((xp-xb)*(xp-xb) + (yp-yb)*(yp-yb));
					s += ds;
					mapLen.push(s);
					mapSpeed.push(ds * integral);
					
					xb = xp;
					yb = yp;
				}
				
				//对精度进行修正
				var prec:Number = s/int(s/m_precision);
				
				t = 0;
				for(var len:Number = 0; len <= s; len +=  prec)
				{
					t = InvertL(t, len);//牛顿积分法求T(Len)
					xp = (1 - t) * (1 - t) *(1 - t) * x0 + 
						3 * t * (1 - t) * (1 - t) * xr + 
						3 * t * t * (1 - t) * xl + 
						t * t *  t * x2;
					yp = (1 - t) * (1 - t) *(1 - t) * y0 + 
						3 * t * (1 - t) * (1 - t) * yr + 
						3 * t * t * (1 - t) * yl + 
						t * t *  t * y2;
					target.push(new CurvePoint(xp, yp));
				}
				
				
				function InvertL(t:Number, len:Number):Number
				{
					var t1:Number = t;
					var t2:Number = 0;
					
					var dl1:Number = 0;
					var dl2:Number = 0;
					
					//integral 积分精度,目前取1000
					//mapLen 用于快速计算Len(t)
					var i:int = int(t1 * integral);				
					dl1 = Math.abs(mapLen[i] - len);
					
					++i;
				
					while(i < mapLen.length)
					{//逐步逼近len
						dl2 = Math.abs(mapLen[i] - len);
						if(dl2 <= dl1)
						{
							++i;
							dl1 = dl2;
						}
						else
						{
							break;
						}
					}
					
					t2 = i/integral;//积分换算

					return t2;
				}
			}
			else
			{
				for (t=0; t<=1; t+=1/num)
				{
					xp = (1 - t) * (1 - t) *(1 - t) * x0 + 3 * t * (1 - t) * (1 - t) * xr + 3 * t * t * (1 - t) * xl + t * t *  t * x2;
					yp = (1 - t) * (1 - t) *(1 - t) * y0 + 3 * t * (1 - t) * (1 - t) * yr + 3 * t * t * (1 - t) * yl + t * t *  t * y2;
					target.push(new CurvePoint(xp, yp));
				}
			}
		}
		
		//------------------------------------------------------------------------------
		
		public function clear():void
		{
			if(graphics)graphics.clear();
			if(m_lstBPoints.length>0)m_lstBPoints.splice(0, m_lstBPoints.length);
		}
		
		//------------------------------------------------------------------------------

		public function toString():String
		{
			return "(起始点:"+m_lstBPoints[0] + "\n终结点:"+m_lstBPoints[m_lstBPoints.length-1]+"\n参照点:"+m_lstBPoints.slice(1,-2)+")";
		}
	}
}

/*
import flash.geom.Point;



class BezierEquilongHelper
{
	//  对外变量
	private static var p0:Point;					// 起点
	private static var pl:Point;					// 贝塞尔点Left
	private static var pr:Point;					// 贝塞尔点Right
	private static var p2:Point;					// 终点
	private static var step:uint;					// 分割份数
	
	//  辅助变量
	private static var ax:int;
	private static var ay:int;
	private static var bx:int;
	private static var by:int;
	
	private static var A:Number;
	private static var B:Number;
	private static var C:Number;
	
	private static var total_length:Number;			// 长度
	
	//  速度函数
	private static function s(t:Number):Number
	{
		return Math.sqrt(A * t * t + B * t + C);
	}
	
	
	//  长度函数
	private static function L (t:Number):Number
	{
		var temp1:Number = Math.sqrt(C + t * (B + A * t));
		var temp2:Number = (2 * A * t * temp1 + B *(temp1 - Math.sqrt(C)));
		var temp3:Number = Math.log(B + 2 * Math.sqrt(A) * Math.sqrt(C));
		var temp4:Number = Math.log(B + 2 * A * t + 2 * Math.sqrt(A) * temp1);
		var temp5:Number = 2 * Math.sqrt(A) * temp2;
		var temp6:Number = (B * B - 4 * A * C) * (temp3 - temp4);
		
		return (temp5 + temp6) / (8 * Math.pow(A, 1.5));
	}
	
	
	//  长度函数反函数，使用牛顿切线法求解
	private static function InvertL (t:Number, l:Number):Number
	{
		var t1:Number = t;
		var t2:Number;
		do
		{
			t2 = t1 - (L(t1) - l)/s(t1);
			if (Math.abs(t1-t2) < 0.000001) break;
			t1 = t2;
		}while(true);
		return t2;
	}
	
	
	
	//  =====================================  封装
	
	
	//  返回所需总步数
	public static function init ($p0:Point, $p1:Point, $p2:Point, $speed:Number):uint
	{
		p0   = $p0;
		p1   = $p1;
		p2   = $p2;
		//step = 30;
		
		ax = p0.x - 2 * p1.x + p2.x;
		ay = p0.y - 2 * p1.y + p2.y;
		bx = 2 * p1.x - 2 * p0.x;
		by = 2 * p1.y - 2 * p0.y;
		
		A = 4*(ax * ax + ay * ay);
		B = 4*(ax * bx + ay * by);
		C = bx * bx + by * by;
		
		//  计算长度
		total_length = L(1);
		
		//  计算步数
		step = Math.floor(total_length / $speed);
		if (total_length % $speed > $speed / 2)	step ++;
		
		trace("曲长：" + total_length);
		trace("步数：" + step);
		return step;
	}
	
	
	// 根据指定nIndex位置获取锚点：返回坐标和角度
	public static function getAnchorPoint (nIndex:Number):Array
	{
		if (nIndex >= 0 && nIndex <= step)
		{
			var t:Number = nIndex/step;
			//  如果按照线行增长，此时对应的曲线长度
			var l:Number = t*total_length;
			//  根据L函数的反函数，求得l对应的t值
			t = InvertL(t, l);
			
			//  根据贝塞尔曲线函数，求得取得此时的x,y坐标
			var xx:Number = (1 - t) * (1 - t) * p0.x + 2 * (1 - t) * t * p1.x + t * t * p2.x;
			var yy:Number = (1 - t) * (1 - t) * p0.y + 2 * (1 - t) * t * p1.y + t * t * p2.y;
			
			//  获取切线
			var Q0:Point = new Point((1 - t) * p0.x + t * p1.x, (1 - t) * p0.y + t * p1.y);
			var Q1:Point = new Point((1 - t) * p1.x + t * p2.x, (1 - t) * p1.y + t * p2.y);
			
			//  计算角度
			var dx:Number = Q1.x - Q0.x;
			var dy:Number = Q1.y - Q0.y;
			var radians:Number = Math.atan2(dy, dx);
			var degrees:Number = radians * 180 / Math.PI;
			
			return new Array(xx, yy, degrees);
		}
		else
		{
			return [];
		}
	}
}
*/