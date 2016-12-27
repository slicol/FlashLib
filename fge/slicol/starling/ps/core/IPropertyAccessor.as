package slicol.starling.ps.core
{
	public interface IPropertyAccessor
	{
		function setProperty(name:String, value:*):void;
		function getProperty(name:String):*;
		function setConfig(xml:XML):void;
		function getConfig():XML;
		function getConfigTemplate():XML;
		function validateConfig():void;
	}
}