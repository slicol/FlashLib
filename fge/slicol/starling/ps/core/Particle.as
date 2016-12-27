package slicol.starling.ps.core
{
	public class Particle
	{
		public var x:Number = 0;
		public var y:Number = 0;
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		public var rotation:Number = 0;
		public var color:uint;
		public var alpha:Number = 1;
		public var currentTime:Number = 0;
		public var totalTime:Number = 0;
		
		public function Particle()
		{
			x = y = rotation = currentTime = 0.0;
			totalTime = alpha = scaleX = scaleY = 1.0;
			color = 0xffffff;
		}
	}
}