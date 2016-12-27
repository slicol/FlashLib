package slicol.engine.swf
{
	import com.tencent.fge.utils.ClassUtil;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.text.StaticText;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class SwfLoader
	{
		private var m_container:Sprite;
		
		public function SwfLoader(container:Sprite)
		{
			m_container = container;
		}
		
		public function loadMovieClip(content:MovieClip):void
		{
			
			for(var i:int = 0; i < content.numChildren; ++i)
			{
				var child:DisplayObject = content.getChildAt(i);
				convertElement(m_container, child, 1);
			}
			
			
		}
		
		
		
		
		private function convertElement(container:Sprite, element:DisplayObject, deep:int):void
		{
			var className:String = ClassUtil.getName(element);
			
			if(element is MovieClip)
			{
				convertMovieClip(container, element as MovieClip, deep);
			}
			else if(element is Shape)
			{
				convertDisplayObject(container, element as Shape, deep);
			}
			else if(element is SimpleButton)
			{
				convertSimpleButton(container, element as SimpleButton, deep);
			}
			else if(element is StaticText)
			{
				convertDisplayObject(container, element as StaticText, deep);
			}
			else if(element is flash.text.TextField)
			{
				convertTextField(container, element as flash.text.TextField, deep);
			}
			else
			{
				trace(deep, element, className);
			}
			
		}

		
		private function convertMovieClip(container:Sprite, element:MovieClip, deep:int):void
		{
			var sprite:Sprite = new Sprite;
			container.addChild(sprite);
			
			copyDisplayObjectInfo(sprite, element);
			
			for(var i:int = 0; i < element.numChildren; ++i)
			{
				var child:DisplayObject = element.getChildAt(i);
				convertElement(sprite, child, deep + 1);
			}
		}
		
		
		private function convertDisplayObject(container:Sprite, element:DisplayObject, deep:int):void
		{
			var tex:Texture = createTextureFromDisplayObject(element);
			
			var disp:Image = new Image(tex);
			container.addChild(disp);
			
			copyDisplayObjectInfo(disp, element);
		}
		
		
		
		private function convertSimpleButton(container:Sprite, element:SimpleButton, deep:int):void
		{
			
			var upState:Texture = createTextureFromDisplayObject(element.upState);
			var downState:Texture = createTextureFromDisplayObject(element.downState);
			
			var btn:Button = new Button(upState, "", downState);
			btn.useHandCursor = true;
			container.addChild(btn);
			
			copyDisplayObjectInfo(btn, element);
		}
		
		
		
		private function convertTextField(container:Sprite, element:flash.text.TextField, deep:int):void
		{
			var fmt:TextFormat = element.getTextFormat();
			
			var tf:starling.text.TextField = new starling.text.TextField(element.width, element.height, element.text, 
				fmt.font, fmt.size as Number, fmt.color as uint, fmt.bold as Boolean);
			
			container.addChild(tf);
			
			copyDisplayObjectInfo(tf, element);
		}
		
		
		
		private function copyDisplayObjectInfo(dst:starling.display.DisplayObject, src:flash.display.DisplayObject):void
		{
			dst.x = src.x;
			dst.y = src.y;
			dst.rotation = src.rotation;
			dst.scaleX = src.scaleX;
			dst.scaleY = src.scaleY;
			dst.alpha = src.alpha;
			dst.visible = src.visible;
		}
		
		
		private function createTextureFromDisplayObject(disp:DisplayObject):Texture
		{
			disp.cacheAsBitmap = true;
			
			var bmd:BitmapData = new BitmapData(disp.width / disp.scaleX, disp.height / disp.scaleY, true, 0);
			var mat:Matrix = new Matrix();
			mat.translate(-disp.x, -disp.y);
			bmd.draw(disp, mat);
			//bmd.draw(disp, disp.transform.matrix, disp.transform.colorTransform, disp.blendMode, null, true);
			var tex:Texture = Texture.fromBitmapData(bmd);
			return tex;
		}
	}
}