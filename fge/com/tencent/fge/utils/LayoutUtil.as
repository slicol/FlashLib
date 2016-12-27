package com.tencent.fge.utils
{
	import flash.display.Sprite;
	
	public class LayoutUtil extends Sprite
	{
		private var target:Sprite;
		
		public function LayoutUtil(target:Sprite)
		{
			this.target = target;
			this.target.addChild(this);
		}
		
		
		public function showGrid(w:int, h:int, scale:int):void
		{
			var x:int;
			var y:int;
			
			if(scale < 5) scale = 5;
			
			this.graphics.beginFill(0x0011ff,0.5);
			for(x = 0; x < w; x+= (2 * scale))
			{
				this.graphics.drawRect(x,0,scale,h);
			}
			for(y = 0; y < h; y+= (2 * scale))
			{
				this.graphics.drawRect(0,y,w,scale);
			}
			this.graphics.endFill();
			
			
			this.graphics.beginFill(0x00ff11,0.5);
			for(x = scale; x < w; x+= (2 * scale))
			{
				this.graphics.drawRect(x,0,scale,h);
			}
			for(y = scale; y < h; y+= (2 * scale))
			{
				this.graphics.drawRect(0,y,w,scale);
			}
			this.graphics.endFill();
			
			this.graphics.lineStyle(2, 0xff0000, 0.5);
			
			for(x = 0; x < w; x += (10*scale))
			{
				this.graphics.moveTo(x, 0);
				this.graphics.lineTo(x, h);
			}
			
			for(y = 0; y < h; y += (10*scale))
			{
				this.graphics.moveTo(0, y);
				this.graphics.lineTo(w, y);
			}
		}

	}
}