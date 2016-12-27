package slicol.tools.starling.jsfl
{
	import slicol.foundation.singleton.SingletonFactory;
	import slicol.tools.fl.common.JSFL;
	import slicol.tools.fl.common.Log;
	import slicol.tools.starling.data.ElementData;
	import slicol.tools.starling.data.ItemData;

	public class AssetManager
	{
		public static function get me():AssetManager
		{
			return SingletonFactory.getInstance(AssetManager);
		}
		
		private var m_jsfl:JSFL;
		
		public function AssetManager()
		{
			m_jsfl = new JSFL("StarlingTools/AssetManager.jsfl");
		}

		
		public function getSelectElementData():ElementData
		{
			var ret:String = m_jsfl.call("getSelectElementData");
			var data:ElementData = new ElementData;
			data.serialize = ret;
			return data;
		}
		
		public function getSelectItemDataByElement():ItemData
		{
			var ret:String = m_jsfl.call("getSelectItemDataByElement");
			var data:ItemData = new ItemData;
			data.serialize = ret;
			return data;
		}
		
		public function setSelectItemLinkageClass(className:String):void
		{
			m_jsfl.call("setSelectItemLinkageClass", className);
		}
		
		public function getCurrentDocumentPathURI():String
		{
			return m_jsfl.call("getCurrentDocumentPathURI");
		}
		
		public function getPreviewerPath():String
		{
			return m_jsfl.call("getPreviewerPath");
		}
		
		//---------------------------------------------------------------------------------
		
		
	}
}