package com.tencent.fge.foundation.vfs
{
	import com.tencent.fge.foundation.log.client.Log;
	
	public class VFS
	{
		private var m_mgrPkg:VPkgManager;
		private var m_mgrFile:VFileManager;
		
		private var log:Log = new Log(this);
		
		public function VFS()
		{
			m_mgrPkg = new VPkgManager();
			m_mgrFile = new VFileManager();
		}
		
		//-----------------------------------------------------------------
		
		public function addPackage(url:String):VFSPackage
		{
			return m_mgrPkg.create(url);
		}
		
		public function removePackage(url:String):void
		{
			m_mgrPkg.release(url);
		}
		
		
		//-----------------------------------------------------------------
		
		public function addDirList(pkgUrl:String, listFileUrl:Vector.<String>):void
		{
			m_mgrPkg.addDirList(pkgUrl, listFileUrl);
		}
		
		public function removeDirList(pkgUrl:String):void
		{
			m_mgrPkg.removeDirList(pkgUrl);
		}
		
		//-----------------------------------------------------------------
		
		
		public function getFile(url:String):VFile
		{
			var f:VFile;
			
			f = m_mgrFile.getFile(url);
			if(f)
			{
				return f;
			}
			
			f = m_mgrPkg.getFile(url);
			if(f)
			{
				m_mgrFile.add(f);
				return f;
			}
			
			f = m_mgrFile.create(url);
			return f;
		}
		
		
		//-----------------------------------------------------------------
		
		
	}
}