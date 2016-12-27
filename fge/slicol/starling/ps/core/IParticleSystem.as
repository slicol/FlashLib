package slicol.starling.ps.core
{
	import starling.animation.IAnimatable;

	internal interface IParticleSystem extends IPropertyAccessor, IAnimatable
	{
		function dispose():void;
		function start(duration:Number=Number.MAX_VALUE):void;
		function stop(bClearParticles:Boolean=false):void;
		function clear():void;
		function get id():String;
		function get z():int;
		function set z(value:int):void;
		function get isEmitting():Boolean;
		function get capacity():int;
		function get numParticles():int;
		function get maxCapacity():int;
		function set maxCapacity(value:int):void;
		function get emitterX():Number;
		function set emitterX(value:Number):void;
		function get emitterY():Number;
		function set emitterY(value:Number):void ;
		function get smoothing():String;
		function set smoothing(value:String):void ;
		function get x():Number;
		function set x(value:Number):void;
		function get y():Number;
		function set y(value:Number):void;
		function get type():String;
	}
}