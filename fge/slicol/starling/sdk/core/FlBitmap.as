package slicol.starling.sdk.core
{
	import starling.display.Image;
	import starling.textures.Texture;
	import slicol.starling.sdk.core.i.FlItem;

	public class FlBitmap extends Image implements FlItem
	{
		protected var m_xmlFlDefine:XML;
		protected var m_xmlFlProperty:XML;
		protected var m_lib:FlLibrary;
		
		public function FlBitmap(xmlFlDefine:XML, lib:FlLibrary)
		{
			m_xmlFlDefine = xmlFlDefine;
			var tex:Texture = lib.getTexture(m_xmlFlDefine.@name);
			super(tex);
		}
		
		override public function dispose():void
		{
			this.removeFromParent();
			super.dispose();
		}
	}
}