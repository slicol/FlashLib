package slicol.starling.sdk.anim
{
	import slicol.starling.sdk.core.FlLibrary;
	import slicol.starling.sdk.core.FlMovieClip;
	
	public class FlAnimation extends FlMovieClip
	{
		public function FlAnimation(xmlFlDefine:XML, lib:FlLibrary, fps:Number=60)
		{
			super(xmlFlDefine, lib, fps);
		}
	}
}