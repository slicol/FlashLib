package com.tencent.fge.unit
{
	internal class UITestItem
	{
		public function UITestItem()
		{
		}
		
		
		public var name:String = "";
		public var func:Function;
		public var argsValues:Array;
		public var owner:UITestCase;
		
		public function get id():String
		{
			var s:String = name;
			
			var args:String = "";
			
			if(argsValues.length > 0)
			{
				args = argsValues[0].toString();
			}
			
			for(var i:int = 1; i < argsValues.length; ++i)
			{
				var v:Object = argsValues[i];
				args += ", " + v.toString();
			}
			
			s += "("+args+")";
			
			return s;
		}
		
		public function begin():void
		{
			owner.beginItem(this);
		}
		
		public function end():void
		{
			owner.endItem();
		}
		
		public function execute():void
		{
			try
			{
				var numValueObjects:int = argsValues.length;
				if (numValueObjects == 0)
				{
					func();
				}
				else if (numValueObjects == 1)
				{
					func(argsValues[0]);
				}
				else if (numValueObjects == 2)
				{
					func(argsValues[0], argsValues[1]);
				}
				else if (numValueObjects == 3)
				{
					func(argsValues[0], argsValues[1], argsValues[2]);
				}
				else if (numValueObjects == 4)
				{
					func(argsValues[0], argsValues[1], argsValues[2], argsValues[3]);
				}
				else if (numValueObjects == 5)
				{
					func(argsValues[0], argsValues[1], argsValues[2], argsValues[3], argsValues[4]);
				}
				else if (numValueObjects == 6)
				{
					func(argsValues[0], argsValues[1], argsValues[2], argsValues[3], argsValues[4], argsValues[5]);
				}
				else if (numValueObjects == 7)
				{
					func(argsValues[0], argsValues[1], argsValues[2], argsValues[3], argsValues[4], argsValues[5], argsValues[6]);
				}
				else
				{
					func.apply(null, argsValues);
				}
			}
			catch(e:Error)
			{
				owner.log("系统错误: " + e.toString());
			}
			
		}
	}
}