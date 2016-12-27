package yellmer.engine.ps
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.controls.Text;
	
	import spark.primitives.Rect;
	
	import starling.display.Image;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;

	public class ParticleSprite extends Image
	{
		private var m_brush:Image;
		private var m_texture:RenderTexture;
		private var m_col:uint
		private var m_rcSrc:Rectangle = new Rectangle;
		private var m_mat:Matrix = new Matrix;
		private var m_ct:ColorTransform = new ColorTransform(1,1,1,1);
		private var m_ptDst:Point = new Point;
		
		public function ParticleSprite(w:Number, h:Number)
		{
			m_texture = new RenderTexture(w,h);
			super(m_texture);
		}
		
		public function GetColor():uint
		{
			return this.m_col;
		}
		
		
		public function SetColor(col:uint):void
		{
			this.m_col = col;
		}
		
		public function SetColorA(a:uint):void
		{
			m_col = (((m_col) & 0x00FFFFFF) + (uint(a)<<24));
		}
		
		
		public function setTextureData(value:BitmapData):void
		{
			if(value != null)
			{
				m_rcSrc.width = value.width;
				m_rcSrc.height = value.height;
				
				var tex:Texture = Texture.fromBitmapData(value);
				
				if(!m_brush)
				{
					m_brush = new Image(tex);
				}
				else
				{
					m_brush.texture = tex;
				}
				m_brush.pivotX = m_brush.width / 2;
				m_brush.pivotY = m_brush.height / 2;
			}
		}
		

		
		public function BeginRender():void
		{
			m_texture.clear();
			
			//var rect:Rectangle = new Rectangle(0,0,bitmapData.width,bitmapData.height);
			//this.bitmapData.fillRect(rect, 0x00000000);
		}
		
		
		public function RenderBundled(drawingBlock:Function):void
		{
			m_texture.drawBundled(drawingBlock,0);
		}
		
		
		public function Render(x:Number, y:Number, rot:Number, hscale:Number = 1.0, vscale:Number = 0.0):void
		{
			if(m_texture)
			{
				m_mat.a = 1;
				m_mat.b = 0;
				m_mat.c = 0;
				m_mat.d = 1;
				m_mat.tx = 0;
				m_mat.ty = 0;
	
				m_mat.rotate(rot);
				m_mat.scale(hscale, vscale == 0 ? hscale : vscale);
				
				m_mat.tx = x;
				m_mat.ty = y;
				
				
				/*
				m_ct.alphaMultiplier = 	(((m_col)>>24) & 0xFF) / 255.0;
				m_ct.redMultiplier = 	(((m_col)>>16) & 0xFF) / 255.0;
				m_ct.greenMultiplier = 	(((m_col)>>08) & 0xFF) / 255.0;
				m_ct.blueMultiplier = 	(((m_col)>>00) & 0xFF) / 255.0;
				*/
				
				
				
				m_ct.alphaMultiplier = 	(((m_col)>>24) & 0xFF) / 255.0;
				m_ct.redMultiplier = 	(((m_col)>>16) & 0xFF) / 255.0;
				m_ct.greenMultiplier = 	(((m_col)>>08) & 0xFF) / 255.0;
				m_ct.blueMultiplier = 	(((m_col)>>00) & 0xFF) / 255.0;
				
				m_brush.x = x;
				m_brush.y = y;
				m_brush.rotation = rot;
				m_brush.alpha = m_ct.alphaMultiplier;
				m_brush.color = m_col;
				//m_brush.scaleX = hscale;
				//m_brush.scaleY = vscale;
				
				
				m_texture.draw(m_brush,0);
				

				
				//this.bitmapData.draw(m_texture, m_mat, m_ct, BlendMode.ADD,null, true);
			}
			
		}
		
		
		public function EndRender():void
		{
			
		}
	}
}