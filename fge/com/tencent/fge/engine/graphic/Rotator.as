package com.tencent.fge.engine.graphic
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	
	public class Rotator
	{

		/**********************************************
		*旋转时修改显示对象的注册点
		* @param targer:DisplayObject 要修改的显示对象
		 * 		 rotation:Number 旋转的弧度值
		*        x:Number 新注册点的x坐标
		*        y:Number 新注册点的y坐标
		* 
		************************************************/
		public static function rotate(target:DisplayObject, rotation:Number, 
			x:Number, y:Number):void
		{
			var newRegisterPoint:Point=new Point(x,y);
			var A:Point=target.localToGlobal(newRegisterPoint);
			target.rotation=rotation;
			var B:Point=target.localToGlobal(newRegisterPoint);
			target.x+=A.x-B.x;
			target.y+=A.y-B.y;
		}

	}
}


