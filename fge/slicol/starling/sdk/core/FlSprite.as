package slicol.starling.sdk.core
{
	import slicol.starling.sdk.core.i.FlItem;
	
	import starling.display.DisplayObject;
	import starling.display.Sprite;

	public class FlSprite extends Sprite implements FlItem
	{
		protected var m_xmlFlDefine:XML;
		protected var m_lib:FlLibrary;
		
		public function FlSprite(xmlFlDefine:XML, lib:FlLibrary)
		{
			super();
			
			m_xmlFlDefine = xmlFlDefine;
			m_lib = lib;
			
			var xlElt:XMLList = m_xmlFlDefine.Timeline.Frame.children();
			for(var i:int = xlElt.length() - 1; i >= 0; --i)
			{
				var xmlElt:XML = xlElt[i];
				var elt:FlItem = m_lib.createElement(xmlElt);
				
				if(elt)
				{
					this.addChild(elt as DisplayObject);
				}
			}
		}
		
		override public function dispose():void
		{
			this.removeFromParent();
			super.dispose();
		}
	}
}