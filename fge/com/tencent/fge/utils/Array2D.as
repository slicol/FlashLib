package com.tencent.fge.utils
{
	public class Array2D
	{
		private var m_rows:int;
		private var m_cols:int;
		private var m_arr:Array;
		public function Array2D(rows:int,cols:int,init:*)
		{
			this.m_cols = cols;
			this.m_rows = rows;
			this.m_arr = Array2D.create(rows,cols,init);
		}
		
		public function get value():Array
		{
			return this.m_arr;
		}
		
		public function get rows():int
		{
			return this.m_rows;
		}
		
		public function get cols():int
		{
			return this.m_cols;
		}
		
		public static function create(cols:int,rows:int, init:*):Array
		{
			var x:int;
			var y:int;
			var arr:Array = new Array(cols);
			for(x = 0; x < cols; ++x)
			{
				arr[x] = new Array(rows);
				for(y = 0; y < rows; ++y)
				{
					arr[x][y] = init;
				}	
			}
			return arr;	
		}
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	    		
	}
}