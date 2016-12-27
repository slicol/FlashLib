package slicol.tools.starling.jsfl
{
	import slicol.foundation.singleton.SingletonFactory;
	import slicol.tools.fl.common.JSFL;

	public class TextureExporter
	{
		public static function get me():TextureExporter
		{
			return SingletonFactory.getInstance(TextureExporter);
		}
		
		private var m_jsfl:JSFL;
		
		public function TextureExporter()
		{
			m_jsfl = new JSFL("StarlingTools/TextureExporter.jsfl");
		}
		
		
		public function exportAsset(targetPathURI:String):String
		{
			var ret:String = m_jsfl.call("exportAsset", targetPathURI);
			return ret;
		}
		
		//---------------------------------------------------------------------------------
		
	}
}