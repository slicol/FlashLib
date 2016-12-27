/**
 * Author Slicoltang
 * 
 * 
 */
package com.tencent.fge.engine.text
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	public class BitmapString extends Bitmap
	{
		public static const TextureIndex_DefaultLetter:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`1234567890-=[]\\;',./~!@#$%^&*()_+{}|:\"\"<>?";
		public static const TextureArrange_V:String = "v";
		public static const TextureArrange_H:String = "h";
		public static const DisplayArrange_V:String = "v";
		public static const DisplayArrange_H:String = "h";

		protected var m_texture:BitmapData;
		protected var m_texIndex:Dictionary;
		protected var m_texIndexLen:int;
		protected var m_texW:Number = 0;
		protected var m_texH:Number = 0;
		protected var m_texR:int;
		protected var m_texC:int;
		protected var m_gapW:int;
		protected var m_gapH:int;
		protected var m_smoothing:Boolean = false;
		protected var m_cloneTexture:Boolean = false;
		protected var m_value:String = "0";
		protected var m_valueList:Array = ["0"];
		protected var m_texArrange:String = TextureArrange_V;
		protected var m_dispArrange:String = DisplayArrange_H;
		protected var m_delim:String = "";
		
		public function BitmapString(value:String = null, 
									 smoothing:Boolean=false, 
									 cloneTexture:Boolean=false,
									 texIndexDelim:String = "")
		{
			m_smoothing = smoothing;
			m_cloneTexture = cloneTexture;
			m_delim = texIndexDelim;
			this.value = value;
		}
		
		public function get cellWidth():Number{return m_texW;}
		public function get cellHeight():Number{return m_texH;}
		
		public function setGap(w:int,h:int):void
		{
			m_gapW = w;
			m_gapH = h;
			updateLayout();
		}
		
		public function setDisplayArrange(value:String):void
		{
			m_dispArrange = value;
			updateLayout();
		}
		
		public function setTextureIndexDelim(delim:String):void
		{
			m_delim = delim;
		}
		
		public function getTextureIndexDelim():String
		{
			return m_delim;
		}
		
		
		//设置纹理
		public function getTexture():BitmapData{return m_texture;}
		public function setTexture(tex:BitmapData, texIndex:String,
								   row:int, col:int,
								   texArrangement:String = null):void
		{
			if(createTexIndex(texIndex) <= 0)
			{
				throw Error("setTexture() 参数错误！");
				return;
			}
			
			if(texArrangement == TextureArrange_H)
			{
				m_texArrange = TextureArrange_H;
			}
			else
			{
				m_texArrange = TextureArrange_V;
			}
			
			m_texture = tex;
			if(m_cloneTexture && m_texture)
			{
				m_texture = m_texture.clone();
			}
			
			var tmp:Number = 0;
			
			if(m_texture)
			{
				if(m_texArrange == TextureArrange_H)
				{
					if(col == 0)
					{
						if(row == 1)
						{
							m_texC = m_texIndexLen;
							m_texR = row;
						}
						else
						{
							throw Error("setTexture() 参数错误！");
							return;
						}
					}
					else if(col > 0)
					{
						m_texC = col;
						if(row > 0)
						{
							m_texR = row;
						}
						else
						{
							tmp = m_texIndexLen;
							tmp = tmp / row;
							if(tmp > int(tmp)) tmp = int(tmp) + 1;
							m_texR = int(tmp);
						}
					}
					else
					{
						throw Error("setTexture() 参数错误！");
						return;
					}
				}
				else
				{

					if(row == 0)
					{
						if(col == 1)
						{
							m_texR = m_texIndexLen;
							m_texC = col;
						}
						else
						{
							throw Error("setTexture() 参数错误！");
							return;
						}
					}
					else if(row > 0)
					{
						m_texR = row;
						if(col > 0)
						{
							m_texC = col;
						}
						else
						{
							tmp = m_texIndexLen;
							tmp = tmp / col;
							if(tmp > int(tmp)) tmp = int(tmp) + 1;
							m_texC = int(tmp);
						}
					}
					else
					{
						throw Error("setTexture() 参数错误！");
						return;
					}
				}
				
				
				m_texW = m_texture.width / m_texC;
				m_texH = m_texture.height / m_texR;				
			}
			
			updateLayout();
		}
		
		//Clon纹理
		public function get cloneTexture():Boolean{return m_cloneTexture;}
		public function set cloneTexture(value:Boolean):void
		{
			if(value == true)
			{
				if(m_cloneTexture != true && m_texture != null)
				{
					m_texture = m_texture.clone();
					m_cloneTexture = true;
				}
			}
			else
			{
				if(m_texture == null)
				{
					m_cloneTexture = value;
				}
			}
		}
		
		 
		public function dispose():void
		{
			
			if(m_cloneTexture && m_texture)
			{
				m_texture.dispose();
				m_texture = null;
			}
			
			if(null != this.bitmapData)
			{
				this.bitmapData.dispose();
				this.bitmapData = null;
			}
		}
		
		//设置值
		public function get value():String{return m_value;}
		public function set value(v:String):void
		{
			if(m_value != v)
			{
				m_value = v;
				if(m_value == null || m_value.length == 0)
				{
					m_value = " ";
				}
				
				if(m_delim == "")
				{
					m_valueList = new Array;
					for(var i:int = 0; i < m_value.length; ++i)
					{
						m_valueList.push(m_value.charAt(i));
					}
				}
				else
				{
					m_valueList = m_value.split(m_delim);
				}
				
				updateLayout();
			}
		}
		
		public function get text():String{return m_value;}
		public function set text(v:String):void
		{
			value = v;
		}
		
		public function setTextFormat(tf:TextFormat):void{}
		public function set defaultTextFormat(tf:TextFormat):void{}
		
		//设置颜色过滤
		public function set textColor(clr:uint):void
		{
			var r:Number = ((clr >>16) & 0xff) / 255.0;
			var g:Number = ((clr >> 8) & 0xff) / 255.0;
			var b:Number = ((clr >> 0) & 0xff) / 255.0;
			var mat:Array = [r,0,0,0,0,
							 0,g,0,0,0,
							 0,0,b,0,0,
							 0,0,0,1,0];
			var cmf:ColorMatrixFilter = new ColorMatrixFilter(mat);
			var f:Array = this.filters;
			for(var i:int = 0; i < f.length; ++i)
			{
				if(f[i] is ColorMatrixFilter)
				{
					f.splice(i,1);
				}
			}
			f.push(cmf);
			this.filters = f;
		}


		protected function updateLayout():void
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
			
			
			for(var i:int = 0; i < m_valueList.length; ++i)
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
				
				
				
				
				
				
				this.bitmapData.draw(this.m_texture, mat, null, null, rc); 
			}
		}
		
		
		//更新容器
		protected function updateContainer():Boolean
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
			
			if(	this.bitmapData == null || 
				w != this.bitmapData.width || 
				h != this.bitmapData.height)
			{
				if(this.bitmapData)
				{
					this.bitmapData.dispose();
				}
				this.bitmapData = new BitmapData(w, h, true, 0);
			}
			else
			{
				this.bitmapData.fillRect(this.bitmapData.rect, 0);
			}
			
			
			return true;
		}
		
		
		//返回索引个数
		protected function createTexIndex(index:String):int
		{
			m_texIndex = new Dictionary;
			m_texIndexLen = 0;
			
			if(index == null || index.length == 0)
			{
				return 0;
			}
			
			var i:int;
			var c:String;
			
			if(m_delim == "")
			{
				for(i = 0; i < index.length; ++i)
				{
					c = index.charAt(i);
					m_texIndex[c] = i + 1;
				}
				
				m_texIndexLen = index.length;				
			}
			else
			{
				var tempArray:Array = index.split(m_delim);
				
				for(i = 0; i < tempArray.length; ++i)
				{
					c = tempArray[i];
					m_texIndex[c] = i + 1;
				}
				m_texIndexLen = tempArray.length;
			}
			
			return m_texIndexLen;
		}

		
	}
}