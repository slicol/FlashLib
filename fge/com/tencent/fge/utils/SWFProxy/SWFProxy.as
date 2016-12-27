package com.tencent.fge.utils.SWFProxy
{
	
	import com.tencent.fge.utils.SWFProxy.interfaces.ISWFProxy;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;

	/**
	 * ...
	 * @author DonaldWu
	 */

	/**
	*=============================================================================
	*	Class:	SWFProxy
	*	Desc:	give access to one SWF asset file
	*=============================================================================
	*/
	public class SWFProxy extends EventDispatcher implements ISWFProxy
	{
		protected var m_mcSWF:MovieClip;
		protected var m_appDomain:ApplicationDomain;
		
		public function SWFProxy(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function setApplicationDomain(appDomain:ApplicationDomain):void
		{
			m_appDomain = appDomain;
		}
		
		public function setSWF(swf:MovieClip):void
		{
			m_mcSWF = swf;
		}
		
		public function getSWF():MovieClip
		{
			return m_mcSWF;
		}
		
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
		public function getComponent(enumComp:String, index:int = -1, mc:MovieClip = null):DisplayObject
		{
			switch(enumComp)
			{
			default:
				return null;
			}
		}
		
		
		/**
		 * get a class from the swf
		 * @param enumCla the name of the class
		 * @return Class the class in the swf
		 * @example 
		 * <listing version="3.0">
		 * </listing>
		 * 
		 */	
		public function getClass(enumCla:String):Class
		{
			if(m_appDomain.hasDefinition(enumCla))
			{
				return m_appDomain.getDefinition(enumCla) as Class;
			}
			else
			{
				return null;
			}
		}
	}
}