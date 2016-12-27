package slicol.tools.starling.jsfl
{
	import slicol.foundation.singleton.SingletonFactory;
	import slicol.tools.fl.common.JSFL;
	
	public class LibraryExporter
	{
		public static function get me():LibraryExporter
		{
			return SingletonFactory.getInstance(LibraryExporter);
		}
		
		private var m_jsfl:JSFL;
		
		public function LibraryExporter()
		{
			m_jsfl = new JSFL("StarlingTools/LibraryExporter.jsfl");
		}
		
		
		public function exportAsset(targetPathURI:String):String
		{
			var ret:String = m_jsfl.call("exportAsset", targetPathURI);
			return ret;
		}
		
		//---------------------------------------------------------------------------------
		
	}
}