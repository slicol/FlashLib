package slicol.starling.ps.cfg
{
	public class PSConfigData
	{
		public var type:String = "";
		public var xml:XML;
		
		public function PSConfigData(xmlValue:XML)
		{
			xml = xmlValue;
			type = xmlValue.@type;
		}
	}
}