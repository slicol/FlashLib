package slicol.tools.starling.jsfl
{
	import slicol.foundation.singleton.SingletonFactory;
	import slicol.tools.fl.common.JSFL;

	public class AssetConverter
	{
		public static function get me():AssetConverter
		{
			return SingletonFactory.getInstance(AssetConverter);
		}
		
		private var m_jsfl:JSFL;
		
		public function AssetConverter()
		{
			m_jsfl = new JSFL("StarlingTools/AssetConverter.jsfl");
		}
		
		
		public function convert():String
		{
			var ret:String = m_jsfl.call("convert");
			return ret;
		}
		
		public function cleanTempFolder():void
		{
			m_jsfl.call("cleanTempFolder");
		}
		
		//---------------------------------------------------------------------------------
		
	}
}