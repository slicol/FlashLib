package com.tencent.fge.utils.SWFProxy.interfaces
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.system.ApplicationDomain;

	/*=============================================================================
	*	Interface:	ISWFProxy
	*	Desc:	give access to one SWF asset file
	*============================================================================*/
	public interface ISWFProxy
	{
		function setSWF(swf:MovieClip):void;
		function getSWF():MovieClip;
		
		function setApplicationDomain(appDomain:ApplicationDomain):void
		
		/**
		 * get a specific symbol from the swf
		 * @param enumComp the enum of the component
		 * @param index it allows you to access an array of similar components
		 * @param mc it allows you to access the component within this mc
		 * @return DisplayObject the component in the swf file
		 * @example 
		 * <listing version="3.0">
		 * </listing>
		 * 
		 */	
		function getComponent(enumComp:String, index:int = -1, mc:MovieClip = null):DisplayObject;
		
		
		/**
		 * get a class from the swf
		 * @param enumCla the name of the class
		 * @return Class the class in the swf
		 * @example 
		 * <listing version="3.0">
		 * </listing>
		 * 
		 */	
		function getClass(enumCla:String):Class;
	}
}