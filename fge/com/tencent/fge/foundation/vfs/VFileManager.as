package com.tencent.fge.foundation.vfs
{
	import flash.events.Event;
	import flash.utils.Dictionary;

	public class VFileManager
	{
		private var m_mapFile:Dictionary = new Dictionary;
		
		public function VFileManager()
		{
		}
		
		
		//-----------------------------------------------------------------
		
		public function create(url:String):VFile
		{
			var f:VFile = new VFile(url);
			f.create();
			this.add(f);
			return f;
		}
		
		public function release(f:VFile):void
		{
			remove(f.url);
			f.release();
		}

		//-----------------------------------------------------------------
		
		public function add(f:VFile):void
		{
			m_mapFile[f.url] = f;
		}
		
		public function remove(url:String):void
		{
			if(m_mapFile[url] != null)
			{
				delete m_mapFile[url];
			}
		}
		
		//-----------------------------------------------------------------
		
		public function getFile(url:String):VFile
		{
			var f:VFile = m_mapFile[url];
			return f;
		}
		
		//-----------------------------------------------------------------
	}
}