/**
 * Author Slicoltang
 * 
 * Usage:
 * 		//1.创建一个BitmapNumber
		m_num = new BitmapNumber(0);
		//2.设置纹理，以及对应的数值。
		m_num.setTexture(bmp.bitmapData,"0123456789+-.");
		//3.设置两个数码之间的间隔。正，表示间隔越远。负，表示间隔越近。
		m_num.setGap(20,0);
		//4.显示它。
		this.addChild(m_num);
		
		//5.显示数字
		m_num.valueString = "1+23";	
		m_num.value = -123.5;	
 * 
 */
package com.tencent.fge.engine.text
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class BitmapNumber extends Bitmap
	{
		public static const TextureArrange_V:String = "v";
		public static const TextureArrange_H:String = "h";
		
		private var m_w:int;
		private var m_h:int;
		private var m_texture:BitmapData;
		private var m_texIndex:Dictionary;
		private var m_texW:int;
		private var m_texH:int;
		private var m_gapW:int;
		private var m_gapH:int;
		private var m_smoothing:Boolean = false;
		private var m_cloneTexture:Boolean = false;
		private var m_value:String = "0";
		private var m_texArrange:String = TextureArrange_V;
		
		public function BitmapNumber(value:Number, 
									 smoothing:Boolean=false, 
									 cloneTexture:Boolean=false)
		{
			m_smoothing = smoothing;
			m_cloneTexture = cloneTexture;
			this.value = value;
		}
		
		public function setGap(w:int,h:int):void
		{
			m_gapW = w;
			m_gapH = h;
			updateLayout();
		}
		
		public function getTexture():BitmapData{return m_texture;}
		public function setTexture(tex:BitmapData, texIndex:String="0123456789+-.", 
								   texArrangement:String = null):void
		{
			if(!createTexIndex(texIndex))
			{
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
			if(m_texture)
			{
				if(m_texArrange == TextureArrange_H)
				{
					m_texW = m_texture.width / texIndex.length;
					m_texH = m_texture.height;
				}
				else
				{
					m_texW = m_texture.width;
					m_texH = m_texture.height / texIndex.length;
				}
			}
			
			updateLayout();
		}
		
		
		public function get cloneTexture():Boolean{return m_cloneTexture;}
		public function set cloneTexture(value:Boolean):void
		{
			if(value == true)
			{
				if(m_cloneTexture != true && m_texture != null)
				{
					m_texture = m_texture.clone();
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
		
		
		public function get value():Number{return Number(m_value);}
		public function set value(v:Number):void
		{
			var tmp:String = v.toString();
			if(m_value != tmp)
			{
				m_value = tmp;
				updateLayout();
			}
		}
		
		public function set valueString(v:String):void
		{
			if(m_value != v)
			{
				m_value = v;
				if(m_value == null || m_value.length == 0)
				{
					m_value = "0";
				}
				updateLayout();
			}
		}

		
		private function updateLayout():void
		{
			if(!updateContainer())
			{
				return;
			}
			
			
			var rc:Rectangle = new Rectangle;
			var mat:Matrix = new Matrix;
			rc.width = m_texW;
			rc.height = m_texH;
			

			for(var i:int = 0; i < m_value.length; ++i)
			{
				var c:String = m_value.charAt(i);
				var index:int = m_texIndex[c];
				if(index == 0)
				{
					index = m_texIndex["."];
				}
				index -= 1;
				rc.x = (m_texW + m_gapW) * i;
				
				
				if(m_texArrange == TextureArrange_H)
				{
					mat.tx = -m_texW * (index - i);
				}
				else
				{
					mat.tx = rc.x;
					mat.ty = -m_texH * index;
				}
				
				this.bitmapData.draw(this.m_texture, mat, null, null, rc); 
			}
		}
		
		private function updateContainer():Boolean
		{
			if( m_texW == 0 || m_texH == 0)
			{
				return false;
			}
			
			var w:int = m_value.length * m_texW + (m_value.length - 1) * m_gapW;
			var h:int = m_texH;
			
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
		
		private function createTexIndex(index:String):Boolean
		{
			m_texIndex = new Dictionary;
			
			if(index == null || index.length == 0)
			{
				return false;
			}
			
			for(var i:int = 0; i < index.length; ++i)
			{
				var c:String = index.charAt(i);
				m_texIndex[c] = i + 1;
			}
			return true;
		}
		
		
		
	}
}