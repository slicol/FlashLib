package com.tencent.fge.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author DonaldWu
	 */
	
	public class SWFUtil
	{
		public static function clearChildren(doc:DisplayObjectContainer,startIndex:int = 0):Boolean
		{
			if(!doc)
			{
				return false;
			}
			
			var num:int = doc.numChildren;
			for(var i:int = num - 1; i >= startIndex; --i)
			{
				doc.removeChildAt(i);
			}
			
			return doc.numChildren == 0;
		}
		
		
		
		/*---------------------------------------------------------
		* 	Func:	duplicateDisplayObject
		* 	Desc:	duplicate an DisplayObject by its constructor,
		*			and copy its several properties
		* 	Param:	
		*	Return:	
		* 	Remark:	
		*--------------------------------------------------------*/
		public static function duplicateDisplayObject(src:DisplayObject):DisplayObject
		{
			// duplicate an DisplayObject by its constructor,
			var targetClass:Class = Object(src).constructor;
			var duplicate:DisplayObject;
			
			duplicate = new targetClass();
			
			// and copy its several properties
			duplicate.transform = src.transform;
			duplicate.filters = src.filters;
			duplicate.cacheAsBitmap = src.cacheAsBitmap;
			duplicate.opaqueBackground = src.opaqueBackground;
			if(src.scale9Grid)
			{
				var rect:Rectangle = src.scale9Grid;
				// Flash 9 bug where returned scale9Grid is 20x larger than assigned
				rect.x /= 20, rect.y /= 20, rect.width /= 20, rect.height /= 20;
				duplicate.scale9Grid = rect;
			}
			
			return duplicate;
		}
		
		
		public static function replaceDisplayObject(srcDisplay:DisplayObject, destDisplay:DisplayObject, withSize:Boolean = false):void	
		{
			var displayIndex:int;
			var parent:DisplayObjectContainer;
			
			parent = srcDisplay.parent;
			
			displayIndex = parent.getChildIndex(srcDisplay);
			destDisplay.x = srcDisplay.x;
			destDisplay.y = srcDisplay.y;
			
			if(withSize)
			{
				destDisplay.width = srcDisplay.width;
				destDisplay.height = srcDisplay.height;
			}
			
			parent.removeChild(srcDisplay);
			parent.addChildAt(destDisplay, displayIndex);
		}
		
		public static function safeRemoveChild(container:DisplayObjectContainer, child:DisplayObject):void
		{
			if(null != container && null != child)
			{
				if(container.contains(child))
				{
					container.removeChild(child);
				}
			}
		}
		
		
		public static function getMovieClipChildren(target:MovieClip):Array
		{
			var retMcs:Array = new Array;
			retMcs.push(target);
			
			var nodeStack:Array = new Array;
			nodeStack.push(target);
			
			while(nodeStack.length > 0)
			{
				var curDoc:DisplayObjectContainer = nodeStack.pop();
				
				var i:int;
				var oneChildDoc:DisplayObjectContainer;
				var oneChildMc:MovieClip;
				
				for(i = 0; i < curDoc.numChildren; ++i)
				{
					oneChildDoc = curDoc.getChildAt(i) as DisplayObjectContainer;
					oneChildMc = curDoc.getChildAt(i) as MovieClip;
					
					if(oneChildDoc != null)
					{
						nodeStack.push(oneChildDoc);
					}
					if(oneChildMc != null)
					{
						retMcs.push(oneChildMc);
					}
				}
			}
			
			nodeStack.length = 0;
			
			return retMcs;
		}
		
		
		public static function killAllAnimation(target:MovieClip):void
		{
			var lst:Array = getMovieClipChildren(target);
			
			for(var i:int = 0; i < lst.length; ++i)
			{
				var mc:MovieClip = lst[i];
				mc.stop();
			}
			
		}
		/**
		 * 清除显示对象中所有对象 
		 * @param dis
		 * @param isClearDis
		 * 
		 */		
		public static function clearDisplayObject(dis:DisplayObjectContainer, isClearDis:Boolean = false):void
		{
			if (dis) {
				
				var num:int = dis.numChildren;
				for(var i:int = num - 1; i >= 0; --i)
				{
					dis.removeChildAt(i);
				}
				
				if (isClearDis && dis.parent) {
					dis.parent.removeChild(dis);
				}
			}
		}
		
		//	add useful functions here
	}
}