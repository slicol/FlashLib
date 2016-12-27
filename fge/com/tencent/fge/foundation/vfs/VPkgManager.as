package com.tencent.fge.foundation.vfs
{
	import flash.events.Event;
	import flash.utils.Dictionary;

	public class VPkgManager
	{
		private var m_mapPkg:Dictionary = new Dictionary;
		private var m_mapDir:Dictionary = new Dictionary;
		
		public function VPkgManager()
		{
		}
		
		
		
		//-----------------------------------------------------------------
		
		public function create(url:String):VFSPackage
		{
			var pkg:VFSPackage = new VFSPackage(url);
			pkg.create();
			this.add(pkg);
			return pkg;
		}
		
		public function release(url:String):void
		{
			var pkg:VFSPackage = remove(url);
			if(pkg)
			{
				pkg.release();
			}
		}

		
		
		//-----------------------------------------------------------------
		
		private function add(pkg:VFSPackage):void
		{
			m_mapPkg[pkg.url] = pkg;
			
			if(pkg.state == VFile.STATE_COMPLETE)
			{
				addDirList(pkg.url, pkg.getDirList());
			}
			else
			{
				pkg.addEventListener(Event.COMPLETE, onPkgComplete);
			}
		}
		
		private function onPkgComplete(e:Event):void
		{
			var pkg:VFSPackage = e.target as VFSPackage;
			pkg.removeEventListener(Event.COMPLETE, onPkgComplete);
			addDirList(pkg.url, pkg.getDirList());
		}
		
		private function remove(url:String):VFSPackage
		{
			var pkg:VFSPackage = m_mapPkg[url];
			
			if(pkg != null)
			{
				pkg.removeEventListener(Event.COMPLETE, onPkgComplete);
				removeDirList(pkg.url);
				delete m_mapPkg[url];
			}
			
			return pkg;
		}
		
		
		//-----------------------------------------------------------------
		
		public function addDirList(pkgUrl:String, listFileUrl:Vector.<String>):void
		{
			for(var i:int = 0; i < listFileUrl.length; ++i)
			{
				m_mapDir[listFileUrl[i]] = pkgUrl;
			}
		}
		
		public function removeDirList(pkgUrl:String):void
		{
			var list:Vector.<String> = new Vector.<String>;
			
			for(var url:String in m_mapDir)
			{
				if(m_mapDir[url] == pkgUrl)
				{
					list.push(url);
				}
			}
			
			for(var i:int = 0; i < list.length; ++i)
			{
				delete m_mapDir[list[i]];
			}
		}
		
		
		//-----------------------------------------------------------------
		
		public function getFile(url:String):VFile
		{
			var urlpkg:String = m_mapDir[url];
			if(!urlpkg)
			{
				return null;
			}
			
			var pkg:VFSPackage = m_mapPkg[urlpkg];
			if(!pkg)
			{
				pkg = create(urlpkg);
			}
			
			return pkg.getFile(url);
		}
		
		//-----------------------------------------------------------------
		
	}
}