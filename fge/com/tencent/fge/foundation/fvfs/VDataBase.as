/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   VDataBase.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2009-6
#   Comment     :   一个基于AS3的虚拟文件系统的实现。
 * 					其实现的目的是为应用开发寻求一个时间与空间的平衡。
 * 					当应用需要一个文件时，可以先向VFS请求，然后再向本地文件系统请求。
 * 					这样可以减少IO读写操作，提供应用的效率。
 * 					由于对Flash来说，大部分文件原始大小都比较小，读取之后展开的大小比较大。
 * 					而VFS存储的是文件的原始字节，因为，在空间上的消耗并不大。
 * 
 * 					该文件定义一个数据存储类
#  	Modify      :   2009-6 文件创建 
#
*************************************************************************/


package com.tencent.fge.foundation.fvfs
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	public class VDataBase extends EventDispatcher
	{
		private var m_lstFiles:Array;
		private var m_mapFiles:Dictionary;
		
		public function VDataBase()
		{
			super();
			m_lstFiles = [];
			m_mapFiles = new Dictionary(true);
		}

		public function open(path:String = null):Boolean
		{
			close();
			if(path && path != "")
			{
				//暂时不支持打开一个专门的虚拟文件系统数据库
			}
			return true;
		}
		
		public function close():void
		{
			for(var i:int = 0; i < m_lstFiles.length; ++i)
			{
				var file:VFile = m_lstFiles[i];
				file.close();
				delete m_mapFiles[file.name];
			}
			
			m_lstFiles = [];
			m_mapFiles = new Dictionary(true);
		}
		
		
		public function save():Boolean{return true;}
		public function saveAs(path:String):Boolean{return true;}
		
		
		public function getFileCount():uint 
		{
			return m_lstFiles ? m_lstFiles.length : 0;
		}
		

		public function getFileByName(name:String):VFile 
		{
			var file:VFile = m_mapFiles[name];
			return file ? file : null;
		}

			
		public function addFile(file:VFile):VFile 
		{
			return addFileAt(m_lstFiles ? m_lstFiles.length : 0, file);
		}

		public function addFileAt(index:uint, file:VFile):VFile 
		{
			if(m_lstFiles == null) 
			{
				m_lstFiles = [];
			}
			if(m_mapFiles == null) 
			{
				m_mapFiles = new Dictionary(true);
			} 
			else if(m_mapFiles[file.name]) 
			{
				//throw(new Error("File already exists: " + file.name + ". Please remove first."));
				return null;
			}
						
			if(index >= m_lstFiles.length) 
			{
				m_lstFiles.push(file);
			} 
			else 
			{
				m_lstFiles.splice(index, 0, file);
			}
			m_mapFiles[file.name] = file;
			return file;
		}


		public function removeFileAt(index:uint):VFile 
		{
			if(m_lstFiles != null && m_mapFiles != null && index < m_lstFiles.length) 
			{
				var file:VFile = m_lstFiles[index] as VFile;
				if(file != null) 
				{
					m_lstFiles.splice(index, 1);
					delete m_mapFiles[file.name];
					return file;
				}
			}
			return null;
		}
		
		public function removeFile(name:String):VFile
		{
			if(m_lstFiles != null && m_mapFiles != null)
			{
				var file:VFile = m_mapFiles[name];
				if(file != null)
				{
					for(var i:int = 0; i < m_lstFiles.length; ++i)
					{
						if(m_lstFiles[i] == file)
						{
							m_lstFiles.splice(i, 1);
							delete m_mapFiles[file.name];
							return file;
						}
					}
				}
			}
			return null;
		}		
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	  
	}
}