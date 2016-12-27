package com.tencent.fge.foundation.vfs
{

	
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.utils.PathUtil;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class VFSPackage extends VFile
	{
		private var m_baseurl:String = "";
		private var m_mapFile:Dictionary = new Dictionary;
		private var m_lstDir:Vector.<String> = new Vector.<String>;
		private var m_zip:FZip = new FZip();
		
		private static var log:Log = new Log(VFSPackage);
		
		public function VFSPackage(url:String)
		{
			super(url);
			
			var i:int = 0;
			
			i = url.lastIndexOf("/");
			if(i < 0)
			{
				i = url.lastIndexOf("\\");
			}
			
			if(i < 0)
			{
				m_baseurl = "";
			}
			else
			{
				m_baseurl = url.substr(0, i);
			}
		}
		
		//-----------------------------------------------------------------
		
		override public function create(bytes:ByteArray=null):void
		{
			super.create(bytes);
			
			if(bytes)
			{
				m_zip.loadBytes(bytes);
				handleFileList();
			}
		}
		
		override public function release():void
		{
			super.release();
			m_zip.close();
		}
		
		//-----------------------------------------------------------------
		
		private function handleFileList():void
		{
			var n:int = m_zip.getFileCount();
			for(var i:int = 0; i < n; ++i)
			{
				var fzf:FZipFile = m_zip.getFileAt(i);
				var url:String = fzf.filename;
				
				if(url.charAt(url.length - 1) != "/")
				{
					if(fzf.content.length == 0)
					{
						log.warn("handleFileList", "文件的大小为0", url);
					}
					
					if(m_baseurl)
					{
						url = m_baseurl + "/" + url;
					}
					
					m_lstDir.push(url);
					
					var f:VFile = getFile(url);
					if(f.state != VFile.STATE_COMPLETE)
					{
						f.create(fzf.content);
						f.handleComplete();
					}				
				}
				
	
			}
		}
		
		public function getDirList():Vector.<String>
		{			
			return m_lstDir;
		}
		
		//-----------------------------------------------------------------
		
		public function getFile(url:String):VFile
		{
			var f:VFile = m_mapFile[url];
			if(!f)
			{
				f = new VFile(url);				
				m_mapFile[f.url] = f;
			}

			return f;
		}
	}
}