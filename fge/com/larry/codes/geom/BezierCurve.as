/* Copyright 2009 larry.zzn@gmail.com. all rights reserved;
**
** package		: com.larry.codes.geom
** name			: BezierCurve
** version		: 1.0
** author		: larry.z
** email		: larry.zzn@gmail.com
** description	: use some points to draw a Bezier curve.
**				  the first point and last point is form point and end point of the curve.
**				  if just give BezierCurve two points, 
**				  the BezierCurve will use them to draw a beeline;
*/

package com.larry.codes.geom{
	
	import flash.display.Graphics;
	import flash.geom.Point;	
	import flash.utils.getQualifiedClassName;


	public class BezierCurve{
		
		// points list
		private var _points:Array;
		// graphics reference
		private var drawer:Graphics;
		// curve's precision default = 40
		private var _precision:uint = 40;
		// curve's color default = red
		private var _color = 0xff0000;
		
		/*
		** Constructor BezierCurve
		** @Parameters	: graphics:Graphics
		**				  ...points:*
		** @return		: void
		** @description	: graphics is a Graphics reference,
		**				  use this to draw the BezierCurve on the graphics owener.
		**				  points is an Array Object,
		**				  it Contains Array Object or Point Object;
		*/
		public function BezierCurve(graphics:Graphics,...points){
			
			initialize();
			drawer = graphics;
			
			var tempArr:Array = new Array();
			for(var i =0;i<points.length;i++){
				tempArr = tempArr.concat(points[i]);
			}
			addPoints(tempArr);
		}
		
		private function initialize():void{
			_points = new Array();
		}
		
		/*
		** graphics setter & getter;
		*/
		public function set graphics(graphics:Graphics):void{
			drawer = graphics;
		}
		public function get graphics():Graphics{
			return drawer;
		}
		
		/*
		** curve's color
		*/
		public function set color(c:uint):void{
			if(_color == c)return;
			_color = c;
			draw();
		}
		public function get color():uint{
			return _color;
		}
		
		/*
		** precision setter & getter; 
		*/
		public function set precision(pcs:uint):void{
			//if(pcs<10 || pcs>150)return;
			if(_precision == pcs)return;
			_precision = pcs;
			draw();
		}
		public function get precision():uint{
			return _precision;
		}
		
		
		/*
		** @method			: addPoint()
		** @parameters		: point:Point
		**					  from:int(Default=-1)
		** @return			: void
		** @description		: added a anchor point to the BezierCurve.
		**					  if you dont use the default form value.
		**					  the point will be insert to the points list at from's value index.
		**					  when the point added to the points list, BezierCurve will redraw the curve.
		*/
		public function addPoint(point:Point,from:int=-1):void{
			if(from==-1){
				_points.push(point);
			}else{
				_points.splice(from,0,point);
			}
			
			// redarw
			draw();
		}
		
		/*
		** @method			: addPoints()
		** @parameters		: ...points:Array
		** @return			: void
		** @description		: add points to the points list ,and redraw the BezierCurve
		*/
		public function addPoints(...points):void{
			for(var i=0;i<points.length;i++){
				if(getQualifiedClassName(points[i]) === "Array"){
					for(var j=0;j<points[i].length;j++){
						if(getQualifiedClassName(points[i][j]).indexOf("Point")==-1){
							throw new Error(points[i][j]+"不是一个Point对象");
						}
						_points.push(points[i][j]);
					}
					continue;
				}
				if(getQualifiedClassName(points[i]).indexOf("Point")>-1)
					_points.push(points[i]);
			}
			
			// redraw
			draw();
		}
		
		/*
		** remove points 
		*/
		public function removePoint(...index):void{
			
			for(var i = 0;i<index.length;i++){
				if(isNaN(index[i]))
					throw new Error(index[i]+"不是一个数字对象");
				
				if(index[i]<0){
					if(_points.length+index[i] < 0){
						throw new Error("索引位置"+index[i]+" 超出数组最大长度");
					}
					
					_points[_points.length+index[i]] = null;
				}else{
					if(_points.length<index[i]){
						throw new Error("索引位置"+index[i]+" 超出数组最大长度");
					}
					
					_points[index[i]] = null;
				}
			}
			
			purify();
			draw();
		}
		
		/*
		** get points 
		*/
		public function getPoint(index:uint):Point{
			if(index<_points.length){
				return _points[index];
			}else{
				return null;
			}
		}
		public function getPoints(from:int=0,to:int=16777215):Array{
			return _points.slice(from,to);
		}
		public function getPointByIndex(index:uint):Point{
			return _points[index];
		}
		public function getPointsByIndex(...index):Array{
			var arr:Array = new Array();
			
			for(var i=0;i<index.length;i++){
				arr.push(_points[index[i]]);
			}
			
			return arr;
		}
		
		/*
		** count the points
		*/
		public function get length():uint{
			return _points.length;
		}
		
		/*
		** draw BezierCurve
		*/
		public function draw(graf:Graphics=null):void{

			var pen:Graphics = graf? graf:graphics;
			pen.clear();
			
			if(!drawer)throw new Error("没有绘图目标的引用! @BezierCurve::draw()");
			if(_points.length<2)throw new Error("没有足够的点位来绘制曲线");
			
			var beginPoint:Point	= _points[0];
			var endPoint:Point		= _points[_points.length-1];
			
			for(var i=0;i<_points.length;i++){
				if(i==0 || i == _points.length-1){
					pen.beginFill(0x333333,1);
					pen.drawCircle(_points[i].x,_points[i].y,7);
				}else{
					pen.beginFill(0x2222ff,1);
					pen.drawCircle(_points[i].x,_points[i].y,5);
				}
			}
			
			pen.endFill();
			
			pen.lineStyle(2,color,1);
			pen.moveTo(beginPoint.x,beginPoint.y);
			
			
			//两点间的直线
			if(_points.length == 2){
				pen.lineTo(endPoint.x,endPoint.y);
				return;
			}
			
			//多点描述的贝塞尔曲线
			for(var j=0;j<precision;j++){
				var Po:Point = getPointOnCurve(_points,j+1);
				pen.lineTo(Po.x,Po.y);
			}
			
			//绘制引导线
			pen.lineStyle(1, 0xeeff00,0.5);
			pen.moveTo(_points[0].x, _points[0].y);
			for(var k:int = 1; k < _points.length; ++k)
			{
				pen.lineTo(_points[k].x, _points[k].y);
			}

		}
		
		/*
		** clear curve and points list;
		*/
		public function clear():void{
			if(graphics)graphics.clear();
			// clear points
			if(_points.length>0)_points.splice(0);
		}
		
		private function purify():void{
			if(_points.length<=0)return;

			_points = _points.filter(function(element,index,c){
				if(element == null)return false;
				else return true;
			})
		}
		
		private function getPointOnCurve(points:Array,step:uint):Point{
			if(points.length<2)
				return null;
			else if(points.length<3)
				return getPointOnLine(points[0],points[1],step);
			
			var tempArr:Array = points.slice();
			
			while(tempArr.length>1){
				var temp2Arr:Array = new Array();
				
				while(tempArr.length>1){
					var p1 = tempArr.shift();
					var p2 = tempArr[0];
					temp2Arr.push(getPointOnLine(p1,p2,step));
				}
				
				tempArr = temp2Arr;
				
			}
			return tempArr[0];
		}
		
		private function getPointOnLine(p1:Point,p2:Point,step:int=-1):Point{
			if(step<0)return p2;
			var pt = new Point();
			var vx:Number = Math.abs(p1.x-p2.x)/precision*step;
			var vy:Number = Math.abs(p1.y-p2.y)/precision*step;
			pt.x = p1.x-p2.x>0?p1.x - vx:p1.x + vx;
			pt.y = p1.y-p2.y>0? p1.y - vy : p1.y + vy;
			return pt;
		
		}
		
		/*
		** to string;
		*/
		public function toString():String{
			return "(起始点:"+_points[0] + "\n终结点:"+_points[_points.length-1]+"\n参照点:"+_points.slice(1,-2)+")";
		}
	}
}