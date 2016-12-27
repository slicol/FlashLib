package slicol.starling.ps.core
{

	
	import com.tencent.fge.codec.PNGDecoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import slicol.starling.ps.impl.PSBasic;
	import slicol.starling.ps.impl.PSLightning;
	
	import starling.textures.Texture;

	public class RPSFactory
	{
		
		public static var BasePath:String = "";
		private static var ms_me:RPSFactory;
		public static function get me():RPSFactory
		{
			if(!ms_me)
			{
				ms_me = new RPSFactory;
			}
			return ms_me;
		}
		public function RPSFactory()
		{
			m_mapPSType["PSBasic"] = PSBasic;
			m_mapPSType["PSLightning"] = PSLightning;
		}
		
		private var m_mapPSType:Dictionary = new Dictionary;
		private var m_mapTextureAssets:Dictionary = new Dictionary;
		private var m_mapTextures:Dictionary = new Dictionary();
		private var m_mapBitmapDatas:Dictionary = new Dictionary();
		
		//For Demo
		private var m_mapCurveCfg:Dictionary = new Dictionary();
		private var m_mapRPSCfg:Dictionary = new Dictionary();
		
		public function addCurveCfg(name:String, cfg:XML):void
		{
			m_mapCurveCfg[name] = cfg;
		}
		
		public function addRPSCfg(name:String, cfg:XML):void
		{
			m_mapRPSCfg[name] = cfg;
		}
		//End Of Demo 
		
		public static function makeRelativePath(path:String):String
		{
			if(!path)
			{
				return "";
			}
			
			if(path.substr(0, BasePath.length) == BasePath)
			{
				path = path.substr(BasePath.length);
			}
			
			var c:String = path.substr(0, 1);
			if(c == "/" || c == "\\")
			{
				path = path.substr(1);
			}
			
			return path;
		}
		
		public function addTextureAssets(name:String, asset:Class):void
		{
			m_mapTextureAssets[name] = asset;
		}
		
		public function getPSTypeList():Array
		{
			var lst:Array = [];
			for (var type:String in m_mapPSType)
			{
				lst.push(type);
			}
			return lst;
		}
		

		
		public function createParticleSystem(type:String, cfg:XML):ParticleSystemBase
		{
			if(!type)
			{
				if(cfg)
				{
					type = String(cfg.@type);
				}
			}
			
			
			if(m_mapPSType.hasOwnProperty(type))
			{
				var clazz:Class = m_mapPSType[type];
				return new clazz(cfg);
			}
			else
			{
				return new PSBasic(cfg);
			}
		}
		

		public function getTexture(name:String):Texture
		{
			if(!name)
			{
				return getTexture("DrugsParticle");
			}
			
			if (m_mapTextures[name] == undefined)
			{
				if(m_mapTextureAssets.hasOwnProperty(name))
				{
					var data:Object = new m_mapTextureAssets[name]();
					
					if (data is Bitmap)
					{
						m_mapTextures[name] = Texture.fromBitmap(data as Bitmap);
					}
					else if (data is ByteArray)
					{
						m_mapTextures[name] = Texture.fromAtfData(data as ByteArray);
					}
				}
				else
				{
					var tex:Texture = getTextureFromFile(name);
					if(tex)
					{
						return tex;
					}
					

					return getTexture("DrugsParticle");
					
					
				}
			}
			
			return m_mapTextures[name];
		}
		
		
		public function getTextureFromFile(name:String):Texture
		{
			var path:String = makeRelativePath(name);
			
			var f:File = new File(BasePath);
			f = f.resolvePath(path);
			
			if(f.exists && !f.isDirectory)
			{
				var fs:FileStream = new FileStream();
				fs.open(f, FileMode.READ);
				fs.position = 0;
				var bytes:ByteArray = new ByteArray;
				fs.readBytes(bytes);
				fs.close();
				
				//var png:PNGDecoder = new PNGDecoder();
				var bmd:BitmapData = PNGDecoder.decodeImage(bytes);
				
				var tex:Texture = Texture.fromBitmapData(bmd);
				
				return tex;
			}
			
			return null;

		}
		
		
		public function getRPSCfg(name:String):XML
		{
			if(!name)
			{
				return null;
			}
			
			var xml:XML;
			
			//For Demo
			xml = m_mapRPSCfg[name];
			if(xml)
			{
				return xml;
			}
			return null;
			//---
		}
		
		public function getCurve(name:String):XML
		{
			if(!name)
			{
				return null;
			}
			
			var xml:XML;
			
			//For Demo
			xml = m_mapCurveCfg[name];
			if(xml)
			{
				return xml;
			}
			//---
			
			var path:String = makeRelativePath(name);
			
			var f:File = new File(BasePath);
			f = f.resolvePath(path);
			
			if(!f.exists || f.isDirectory)
			{
				return null;
			}
			

			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.READ);
			fs.position = 0;
			var s:String = fs.readUTFBytes(fs.bytesAvailable);
			fs.close();
			
			
			try
			{
				xml = new XML(s);
			}
			catch(e:Error)
			{
				//Alert.show("曲线文件格式错误！");
				return xml;
			}

			return xml;
		}
	}
}