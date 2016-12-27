package slicol.starling.sdk.core
{
	import com.tencent.fge.utils.ClassUtil;
	
	import flash.utils.Dictionary;
	
	import slicol.starling.sdk.anim.FlAnimator;
	import slicol.starling.sdk.core.i.FlItem;
	
	import starling.display.DisplayObject;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class FlLibrary
	{
		private var m_xml:XML;
		private var m_lstTextureAtlas:Vector.<TextureAtlas>
		private var m_mapTextures:Dictionary = new Dictionary;
		
		
		private var m_mapItemXml:Dictionary = new Dictionary;
		private var m_mapCfgAsset:Dictionary = new Dictionary;
		
		private static var ms_mapItemClass:Dictionary = new Dictionary;
		private static var ms_lstItemClassName:Array = [];
		
		public function FlLibrary(xml:XML, listTextureAtlas:Vector.<TextureAtlas>, mapCfgAsset:Dictionary)
		{
			m_xml = xml;
			m_lstTextureAtlas = listTextureAtlas;
			m_mapCfgAsset = mapCfgAsset;
		}
		
		public function get cfg():XML{return m_xml;}

		public static function regItemClass(cls:Class, useFullName:Boolean = false):void
		{
			var clsName:String = "";
			
			if(useFullName)
			{
				clsName = ClassUtil.getFullName(cls);
				ms_mapItemClass[clsName] = cls;
				
				clsName = clsName.replace("::",".");
				ms_mapItemClass[clsName] = cls;
			}
			else
			{
				clsName = ClassUtil.getName(cls);
				ms_mapItemClass[clsName] = cls;
			}
			
			if(ms_lstItemClassName.indexOf(clsName) < 0)
			{
				ms_lstItemClassName.push(clsName);
			}
		}
		
		public static function getItemClassNameList():Array
		{
			return ms_lstItemClassName;
		}
		
		
		private function getItemXml(name:String):XML
		{
			var xmlItem:XML = m_mapItemXml[name];
			if(xmlItem)
			{
				return xmlItem;
			}
			
			var xlItems:XMLList = m_xml.children();
			
			for(var i:int = 0; i < xlItems.length(); ++i)
			{
				xmlItem = xlItems[i];
				if(xmlItem.@name == name)
				{
					m_mapItemXml[name] = xmlItem;
					return xmlItem;
				}
			}
			
			return null;
		}
		
		
		public function getTexture(name:String):Texture
		{
			var tex:Texture = m_mapTextures[name];
			if(tex)
			{
				return tex;
			}
			
			for(var i:int = 0; i < m_lstTextureAtlas.length; ++i)
			{
				tex = m_lstTextureAtlas[i].getTexture(name);
				if(tex)
				{
					m_mapTextures[name] = tex;
					return tex;
				}
			}
			return null;
		}
		
		
		public function createItem(itemName:String):FlItem
		{
			var xml:XML = getItemXml(itemName);
			if(!xml)
			{
				return null;
			}
			
			var xlFrame:XMLList = xml..Frame;
			var totalFrames:int = xlFrame.length();
			var itemType:String = xml.@type;
			var clsName:String = xml["@class"];
			
			var cls:Class = ms_mapItemClass[clsName];
			if(cls)
			{
				return new cls(xml, this);
			}
			
			switch(itemType)
			{
				case "Stage": 
					return new FlStage(xml, this);
				case "movie clip":
					return totalFrames > 1 ? new FlMovieClip(xml, this) : new FlSprite(xml, this);
				case "button":
					return new FlButton(xml, this);
				case "bitmap":
					return new FlBitmap(xml, this);
			}
			
			return new FlSprite(xml, this);
		}
		
		
		

		public function createElement(xmlElement:XML):FlItem
		{
			var itemName:String = xmlElement.@item;
			var eltType:String = xmlElement.@type;
			var elt:FlItem;
			
			switch(eltType)
			{
				case "instance":
					elt = createItem(itemName);
					break;
				case "text":
					elt = new FlTextField(xmlElement, this);
					break;
			}
			
			if(elt)
			{
				setProperty(elt as DisplayObject, xmlElement);
			}
			
			return elt;
		}
		

		public function createAnimator(name:String):FlAnimator
		{
			var xml:XML = m_mapCfgAsset[name];
			var anim:FlAnimator = new FlAnimator(xml, this);
			
			return anim;
		}
		
		
		
		public static function setProperty(elt:DisplayObject, xmlProperty:XML):void
		{
			var xlArgs:XMLList = xmlProperty.attributes();
			
			
			for(var i:int = 0; i < xlArgs.length(); ++i)
			{
				var pname:String = xlArgs[i].name();
				var pvalue:String = xlArgs[i].toString();
				
				if(!elt.hasOwnProperty(pname))
				{
					continue;
				}
				
				if(elt[pname] is int || elt[pname] is uint || elt[pname] is Number)
				{
					elt[pname] = Number(pvalue);
				}
				else if(elt[pname] is Boolean)
				{
					elt[pname] = Boolean(pvalue);
				}
				else
				{
					elt[pname] = pvalue;
				}
			}
			
			elt.skewX = Math.PI * Number(xmlProperty.@skewX)/180;
			elt.skewY = Math.PI * Number(xmlProperty.@skewY)/180;
			elt.rotation = Math.PI * Number(xmlProperty.@rotation)/180;
		}
		
	}
}