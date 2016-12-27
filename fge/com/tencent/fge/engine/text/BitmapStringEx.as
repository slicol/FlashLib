package com.tencent.fge.engine.text
{
	import com.tencent.fge.utils.StringUtil;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	

	public class BitmapStringEx extends BitmapString
	{
		
		protected var m_mapTexWidth:Dictionary = new Dictionary();
		protected var m_mapTexAutoWidth:Dictionary = new Dictionary;
		protected var m_texAutoSize:Boolean = false;
		
		public function BitmapStringEx(value:String = null, 
									 smoothing:Boolean=false, 
									 cloneTexture:Boolean=false,
									 texIndexDelim:String = "")
		{
			super(value, smoothing, cloneTexture,texIndexDelim);
		}
		
		override public function setTexture(tex:BitmapData, texIndex:String, row:int, col:int, texArrangement:String=null):void
		{
			super.setTexture(tex, texIndex, row, col, texArrangement);
			m_mapTexAutoWidth = new Dictionary;
		}
		
		public function setTextureWidth(texIndex:String, w:int):void
		{
			var i:int;
			var c:String;
			if(m_delim == "")
			{
				for(i = 0; i < texIndex.length; ++i)
				{
					c = texIndex.charAt(i);
					m_mapTexWidth[c] = w;
				}
			}
			else
			{
				
				var arr:Array = texIndex.split(m_delim);
				
				for(i = 0; i < arr.length; ++i)
				{
					c = arr[i];
					m_mapTexWidth[c] = w;
				}
			}
		}
		
		public function setTextureAutoSize(value:Boolean):void
		{
			m_texAutoSize = value;
		}
		
		
		override protected function updateLayout():void
		{
			if(!updateContainer())
			{
				return;
			}
			
			var ir:int;
			var ic:int;
			var rc:Rectangle = new Rectangle;
			var mat:Matrix = new Matrix;
			rc.width = m_texW;
			rc.height = m_texH;
			
			var trimW:int;//累计裁剪的宽度
			var tempW:int;
			
			for(var i:int = 0; i < m_value.length; ++i)
			{
				var c:String = m_valueList[i];
				var index:int = m_texIndex[c];
				index -= 1;
				
				//这里是取出纹理
				if(m_texArrange == TextureArrange_H)
				{
					ic = index % m_texC;
					ir = index / m_texC;
				}
				else
				{
					ir = index % m_texR;
					ic = index / m_texR;
				}
				
				
				//这里是计算渲染布局
				if(m_dispArrange == DisplayArrange_V)
				{
					rc.y = (m_texH + m_gapH) * i;
					
					mat.tx = - m_texW * ic;
					mat.ty = - m_texH * ir + rc.y;
				}
				else
				{
					rc.x = (m_texW + m_gapW) * i;
					
					mat.tx = - m_texW * ic + rc.x;
					mat.ty = - m_texH * ir;
				}
				
				
				
				//----
				//裁剪计算 
				if(m_dispArrange != DisplayArrange_V)
				{					
					rc.x = rc.x - trimW;
					mat.tx = mat.tx - trimW;
					
					tempW = m_mapTexWidth[c];
					if(tempW > 0 && tempW < m_texW)
					{
						trimW = trimW + (m_texW - tempW);
					}
					else
					{
						if(m_texAutoSize)
						{
							var tempAutoWidth:* = m_mapTexAutoWidth[c];
							if(tempAutoWidth != null)
							{
								tempW = tempAutoWidth; 
							}
							
							if(!(tempAutoWidth != null && tempW <= m_texW))
							{
								tempW = 0;
								var bmd:BitmapData = getCharTextureAt(ir,ic);
								if(bmd)
								{
									var rcBmd:Rectangle = bmd.getColorBoundsRect(0xFF000000, 0x00000000, false);
									tempW = rcBmd.right;
									bmd.dispose();
								}

								m_mapTexAutoWidth[c] = tempW;
							}
							
							trimW = trimW + (m_texW - tempW);
						}
					}
				}
				//----
				
				//这咱方式的性能比较低
				//this.bitmapData.draw(this.m_texture, mat, null, null, rc);
				
				//这种方式的性能比较高
				var rcChar:Rectangle = new Rectangle(ic * m_texW, ir * m_texH, m_texW, m_texH);
				if(this.bitmapData)
				{
					this.bitmapData.copyPixels(this.m_texture, rcChar, new Point(rc.x, rc.y), null, null, true);
				}
			}
		}
		
		private function getCharTextureAt(r:int, c:int):BitmapData
		{
			var bmd:BitmapData = new BitmapData(m_texW, m_texH, true, 0);
			var rc:Rectangle = new Rectangle(c * m_texW, r * m_texH, m_texW, m_texH);
			bmd.copyPixels(this.m_texture, rc, new Point(0,0));
			return bmd;
		}
		
		override protected function updateContainer():Boolean
		{
			if( m_texW == 0 || m_texH == 0)
			{
				return false;
			}
			
			
			var w:int;
			var h:int;
			
			if(m_dispArrange == DisplayArrange_V)
			{
				w = m_texW;
				h = m_valueList.length * m_texH + (m_valueList.length - 1) * m_gapH;
			}
			else
			{
				w = m_valueList.length * m_texW + (m_valueList.length - 1) * m_gapW;
				h = m_texH;
			}

			
			
			if(w <= 0)
			{
				return false;
			}
			
			//进行剪裁
			if(m_dispArrange != DisplayArrange_V)
			{
				var trimW:int;
				var tempW:int;
				var ir:int;
				var ic:int;
				
				for(var i:int = 0; i < m_valueList.length; ++i)
				{
					var c:String = m_valueList[i];
					tempW = m_mapTexWidth[c];
					if(tempW > 0)
					{
						trimW = trimW + (m_texW - tempW);
					}
					else
					{
						if(m_texAutoSize)
						{
							var index:int = m_texIndex[c];
							index -= 1;
							ic = index % m_texC;
							ir = index / m_texC;
							
							var tempAutoWidth:* = m_mapTexAutoWidth[c];
							if(tempAutoWidth != null)
							{
								tempW = tempAutoWidth; 
							}
							
							if(!(tempAutoWidth != null && tempW <= m_texW))
							{
								tempW = 0;

								var bmd:BitmapData = getCharTextureAt(ir,ic);
								if(bmd)
								{
									var rcBmd:Rectangle = bmd.getColorBoundsRect(0xFF000000, 0x00000000, false);
									tempW = rcBmd.right;
									bmd.dispose();
								}
								
								m_mapTexAutoWidth[c] = tempW;
							}
							
							trimW = trimW + (m_texW - tempW);
						}
					}
				}
				
				w = w - trimW;
			}
			//剪裁结束

			
			if(	this.bitmapData == null || 
				w != this.bitmapData.width || 
				h != this.bitmapData.height)
			{
				if(this.bitmapData)
				{
					this.bitmapData.dispose();
				}
				
				if(w > 0 && h > 0)
				{
					this.bitmapData = new BitmapData(w, h, true, 0);
				}
				else
				{
					this.bitmapData = null;
				}
				
			}
			else
			{
				this.bitmapData.fillRect(this.bitmapData.rect, 0);
			}
			
			
			return true;
		}
		
	}
}