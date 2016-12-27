package com.tencent.fge.utils
{
	public class PathUtil
	{
		public static function getDirFromPath(path:String):String
		{
			path = StringUtil.replace(path, "\\", "/");
			var i:int = path.lastIndexOf("/");
			if(i <= 0)
			{
				return "";
			}
			
			path = path.substr(0, i + 1);
			return path;
		}
		
		public static function getFileNameWithoutExt(path:String):String
		{
			var ret:String = StringUtil.replace(path, "\\", "/");
			var tmp:Array = ret.split("/");
			
			ret = tmp[tmp.length - 1];
			tmp = ret.split(".");
			ret = tmp[0];
			
			return ret;
		}
		
		public static function isFullPath(path:String):Boolean
		{
			var tag:String = path.substr(0, 7).toLocaleLowerCase();
			return (tag == "http://" || tag == "file://");
		}
		
		public static function makeFullPath(basePath:String, subPath:String, checkSubPath:Boolean):String
		{
			if(subPath == null) 
			{
				subPath = "";
			}
			
			if(basePath == null)
			{
				basePath = "";
			}
			
			if(subPath.length == 0)
			{
				if(checkSubPath) return "";
				else return basePath;
			}
			
			if(basePath.length == 0)
			{
				return subPath;
			}
			
			if(isFullPath(subPath))
			{
				return subPath;
			}
			
			var i:int = 0;
			var c:String = subPath.charAt(i);
			
			while(c == "/" || c == "\\")
			{
				++i;
				c = subPath.charAt(i);
			}
			
			subPath = subPath.substr(i);
			
			
			i = basePath.length - 1;
			c = basePath.charAt(i);
			
			while(c == "/" || c == "\\")
			{
				--i;
				c = basePath.charAt(i);
			}
			
			basePath = basePath.substring(0, i + 1);
			
			return basePath + "/" + subPath;
		}
		
		public static function makePath(dirPath:String, subPath:String, checkSubPath:Boolean):String
		{
			if(subPath == null) 
			{
				subPath = "";
			}
			
			if(dirPath == null)
			{
				dirPath = "";
			}
			
			if(subPath.length == 0)
			{
				if(checkSubPath) return "";
				else return dirPath;
			}
			
			
			if(subPath.charAt(0) == "/" || subPath.charAt(0) == "\\")
			{
				return subPath;
			}
			else
			{
				//Trim掉//..//
				var bNeedTrimPath:Boolean = false;
				if(subPath.substr(0,3) == "..\\" || subPath.substr(0,3) == "../")
				{
					var newDirPath:String = "";
					var i:int = dirPath.lastIndexOf("\\");
					var j:int = dirPath.lastIndexOf("/");
					i = Math.max(i,j);
					if(i > 0)
					{
						if( i == dirPath.length - 1)
						{
							var k:int = i - 1;
							i = dirPath.lastIndexOf("\\", k);
							j = dirPath.lastIndexOf("/", k);
							i = Math.max(i,j);
							if(i >= 0)
							{
								newDirPath = dirPath.substring(0,i + 1);
							}
							else
							{
								newDirPath = "";
							}
						}
						else
						{
							newDirPath = dirPath.substring(0,i + 1);
						}
						
						bNeedTrimPath = true;
					}
					else if(i == 0)
					{
						bNeedTrimPath = false;
					}
					else
					{
						newDirPath = "";
						
						if(dirPath.length == 0)
						{
							bNeedTrimPath = false;
						}
						else
						{
							bNeedTrimPath = true;
						}
					}
					
					if(bNeedTrimPath)
					{
						var newSubPath:String = subPath.substr(3);
						return newDirPath + newSubPath;
					}
					
				}
				return dirPath + subPath;
			}
		}

	}
}