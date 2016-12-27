package com.tencent.fge.air.file.utils
{
	import com.tencent.fge.utils.StringUtil;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	public class FileUtil
	{
		private static var ms_lastError:Error;
		public static function get lastError():Error{return ms_lastError;}
		
		public static function isPathExist(path:String):Boolean
		{
			var file:File = new File(path);
			return file.exists;
		}
		
		
		
		

		
		//-------------------------------

		
		public static function openTextFile(path:String):String
		{
			var file:File = new File(path);
			
			if(!file.exists)
			{
				ms_lastError = new Error("File is Not Exist : " + path);
				return "";
			}
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			
			var s:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			
			return s;
		}
		
		
		public static function saveTextFile(path:String, content:String):void
		{
			var file:File = new File(path);
			
			if(file.exists)
			{
				file.deleteFile();
			}
			
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.UPDATE);
			stream.writeUTFBytes(content);
			stream.close();
			
		}
		
		
		//-------------------------------
		
		public static function openXmlFile(path:String):XML
		{
			var s:String = openTextFile(path);
			var xml:XML = null;
			if(!s)
			{
				return xml;
			}
			
			try
			{
				xml = new XML(s);
			}
			catch(e:Error)
			{
				ms_lastError = e;
				xml = null;
			}
			return xml;
		}
		
		//-------------------------------
		
		public static function openJsonFile(path:String):Object
		{
			var s:String = openTextFile(path);
			
			return JSON.parse(s);
		}
		
		public static function saveJsonFile(path:String, json:Object):void
		{
			var s:String = JSON.stringify(json);
			saveTextFile(path, s);
		}
		
		
		//-------------------------------
		
		public static function openDataFile(path:String):ByteArray
		{
			var file:File = new File(path);
			
			if(!file.exists)
			{
				ms_lastError = new Error("File is Not Exist : " + path);
				return null;
			}
			
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			
			var ret:ByteArray = new ByteArray;
			stream.readBytes(ret, 0, stream.bytesAvailable);
			
			stream.close();
			
			return ret;
		}
		
		
		public static function saveDataFile(path:String, content:ByteArray):void
		{
			var file:File = new File(path);
			
			if(file.exists)
			{
				file.deleteFile();
			}
			
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.UPDATE);
			
			stream.writeBytes(content);
			
			stream.close();
		}
	}
}