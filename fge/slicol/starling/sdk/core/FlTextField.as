package slicol.starling.sdk.core
{
	import slicol.starling.sdk.core.i.FlItem;
	
	import starling.text.TextField;
	
	public class FlTextField extends TextField implements FlItem
	{
		protected var m_xmlFlDefine:XML;
		protected var m_lib:FlLibrary;
		
		public function FlTextField(xmlFlDefine:XML, lib:FlLibrary)
		{
			m_xmlFlDefine = xmlFlDefine;
			m_lib = lib;
			
			var w:Number = Number(m_xmlFlDefine.@width);
			var h:Number = Number(m_xmlFlDefine.@height);
			var text:String = String(m_xmlFlDefine.TextField.Text);
			
			super(w, h, text);
		}
		
		override public function dispose():void
		{
			this.removeFromParent();
			super.dispose();
		}
	}
}