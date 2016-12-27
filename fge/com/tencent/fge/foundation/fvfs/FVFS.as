/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   FVFS.as
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
 * 					该文件是定义了VFS的对外接口类
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-6 文件创建 
#
*************************************************************************/

package com.tencent.fge.foundation.fvfs
{
	import com.tencent.fge.foundation.serialize.SerializeOperateQueue;
	import com.tencent.fge.foundation.serialize.SerializeOperateQueueEvent;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	
	import flash.events.*;
	import flash.text.*;
	import flash.utils.*;

	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="status", type="flash.events.StatusEvent")]


	public class FVFS extends EventDispatcher
	{
		public static const STATUS_BUSY:String = "busy";
		public static const STATUS_IDLE:String = "idle";
		
		private var m_db:VDataBase;
		private var m_queSer:SerializeOperateQueue;
		private var m_queOpening:Array;
		private var m_curStatus:String = STATUS_IDLE;
		
		private var m_nTotalAddCnt:int;
		private var m_nCompleteCnt:int;
		
		public function FVFS() 
		{
			super();
			m_queSer = new SerializeOperateQueue("FVFS", "loadFile", 1000, 30000, 10);
			m_queSer.asyPumpWhenComplete = false;
			m_queSer.addEventListener(SerializeOperateQueueEvent.EXECUTE, onSerOpExecute);
		}


		/**
		 * 以一个本地存储文件打开VFS
		 * path 该参数指向该文件。可以为NULL。如果为NULL则在内存中打开一个空的VFS。
		 * 因为目前实际开发中未使用到该文件，所以未实现，目前该参数保留为NULL。
		 */
		public function open(path:String = null):Boolean
		{
			close();
			m_nTotalAddCnt = 0;
			m_nCompleteCnt = 0;
			m_queOpening = new Array;
			m_db = new VDataBase();
			return m_db.open(path);
		}
		
		/**
		 * 关闭打开的VFS。清除所占用的内存。
		 */
		public function close():void
		{
			m_queOpening = null;
			m_nTotalAddCnt = 0;
			m_nCompleteCnt = 0;
			m_queSer.reset();
			if(m_db)
			{
				m_db.close();
				m_db = null;
			}
		}
		
		
		/**
		 * 得到一个文件
		 */
		public function getFileByName(name:String):VFile
		{
			return m_db ? m_db.getFileByName(name) : null;
		}
		
		
		/**
		 * 得到文件个数
		 */
		public function getFileCount():uint 
		{
			return m_db ? m_db.getFileCount() : 0;
		}


		/**
		 * 向VFS中添加一个文件。
		 * 如果该文件已经存在于VFS中，则添加失败，返回NULL
		 * 否则添加成功，返回对该虚拟文件的封装VFile
		 * 这个将会异步返回
		 */
		public function addFile(name:String, immediate:Boolean = false):VFile 
		{
			if(m_db == null) return null;
			
			var file:VFile = m_db.getFileByName(name);
			
			if(file == null)
			{
				m_nTotalAddCnt++;
				
				file = new VFile(name);
				addEventHandlers(file);
				
				m_db.addFile(file);
				
				if(immediate)
				{
					m_queOpening.push(file);
					file.open();
				}
				else
				{
					//加入串行队列
					m_queSer.pushBack(name, file, 1);
				}
				return file;
			}
			else
			{
				return null;
			}

			
		}
		
		
		
		//这个将是立即返回
		public function addFileFromByteArray(name:String, content:ByteArray):VFile
		{
			if(m_db == null) return null;
			
			var file:VFile = m_db.getFileByName(name);
			
			if(file == null)
			{
				file = new VFile(name, VFile.TYPE_RAW);
				
				file.content = content;
				m_db.addFile(file);
				return file;
			}

			return null;
		}


		/**
		 * 从VFS中移出一个文件，但并不是删除文件内容。
		 * 返回一对该文件的封装VFile
		 * 立即移出一个文件
		 */
		public function removeFile(name:String):VFile
		{
			var file:VFile;
						
			for(var i:int = 0; i < m_queOpening.length; ++i)
			{
				file = m_queOpening[i];
				if(file.name == name)
				{
					m_queOpening.splice(i, 1);
					return null;
				}
			}
			
			//先从DB里找，然后，从加载队列里找．
			m_queSer.cancelOperate(name);

			if(m_db == null) return null;
			return m_db.removeFile(name);
		}
		
		/**
		 * 从VFS中删除一个文件
		 */
		public function deleteFile(name:String):void
		{
			var file:VFile = this.removeFile(name);
			if(file)
			{
				file.close();
			}
		}


		public function isStatus(code:String):Boolean
		{
			var isIdle:Boolean = m_queOpening ? m_queOpening.length == 0 : true;
			
			return ( ( isIdle && code == STATUS_IDLE) || 
				(!isIdle && code == STATUS_BUSY));
		}
		
		protected function onSerOpExecute(e:SerializeOperateQueueEvent):void
		{
			var file:VFile = e.opParam as VFile;
			if(file)
			{
				m_queOpening.push(file);
				file.open();
			}
			else
			{
				m_queSer.cancelOperate(e.opTarget);
			}
		}
		

		protected function completeHandler(evt:Event):void
		{
			var file:VFile = evt.target as VFile;
			var name:String;
			var i:int;
			
			if(file)
			{
				removeEventHandlers(file);
				
				++m_nCompleteCnt;
				
				name = file.name;
				m_queSer.completeOperate(name);
				
				for(i = 0; i < m_queOpening.length; ++i)
				{
					if(m_queOpening[i] == file)
					{
						m_queOpening.splice(i, 1);
						break;
					}
				}
				
				//对该文件作二次处理
				if(file.isZip)
				{
					m_db.removeFile(file.name);
					var lstTmpZip:Array = [];
					lstTmpZip.push(file);
					
					//模拟递归
					while(lstTmpZip.length > 0)
					{
						//取出栈顶的一个Zip
						var vFileForZip:VFile = lstTmpZip.pop();
						var zip:FZip = vFileForZip.content;
						var cnt:int = zip.getFileCount();
						
						//取出Zip里的每一个ZipFile
						for(i = 0; i < cnt; ++i)
						{
							var zipFile:FZipFile = zip.getFileAt(i);
							
							//判断该文件名是否已经存在于DB
							if(m_db.getFileByName(zipFile.filename) == null)
							{
								//为该ZipFile创建一个VFile封装
								var vFileInZip:VFile = new VFile(zipFile.filename);
								
								//判断该ZipFile是否为Zip
								if(vFileInZip.isZip)
								{
									//创建一个FZip来处理ZipFile里的数据
									var zipInZip:FZip = new FZip;
									zipInZip.loadBytes(zipFile.content);
									vFileInZip.content = zipInZip;
									//并且将FZip压入栈
									lstTmpZip.push(vFileInZip);
									//清空原ZipFile
									zipFile.content = null;
								}
								else
								{
									//该ZipFile不是Zip，于是就可以加入DB
									vFileInZip.content = zipFile;
									m_db.addFile(vFileInZip);
									vFileInZip.dispatchEvent(new Event(Event.ADDED));
								}
							}
							else
							{
								//该ZipFile已经存在于DB，则不再重复添加，且清空该ZipFile
								zipFile.content = null;
							}
						}
						
					}
				}
				
				file.dispatchEvent(new Event(Event.ADDED));
				
				//派发进度事件
				progressHandler();
				
				//派发状态事件
				statusHandler();
			}
		}
		
		protected function defaultErrorHandler(evt:Event):void 
		{
			var file:VFile = evt.target as VFile;
			var name:String;
			if(file)
			{
				removeEventHandlers(file);
				
				++m_nCompleteCnt;
				
				name = file.name;
				m_queSer.completeOperate(name);
				deleteFile(name);
				
				//派发进度事件
				progressHandler();
				
				//派发状态事件
				statusHandler();
				
			}
		}
		
		protected function progressHandler():void
		{
			//派发进度事件
			var eProgress:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
			eProgress.bytesTotal = this.m_nTotalAddCnt;
			eProgress.bytesLoaded = this.m_nCompleteCnt;
			this.dispatchEvent(eProgress);
		}
		
		protected function statusHandler():void
		{
			if(isStatus(STATUS_IDLE))
			{
				var eStatus:StatusEvent = new StatusEvent(StatusEvent.STATUS);
				eStatus.code = STATUS_IDLE;
				this.dispatchEvent(eStatus);
			}
		}


		protected function addEventHandlers(target:IEventDispatcher):void 
		{
			target.addEventListener(Event.COMPLETE, completeHandler);
			target.addEventListener(IOErrorEvent.IO_ERROR, defaultErrorHandler);
			target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, defaultErrorHandler);
		}
		
		protected function removeEventHandlers(target:IEventDispatcher):void 
		{
			target.removeEventListener(Event.COMPLETE, completeHandler);
			target.removeEventListener(IOErrorEvent.IO_ERROR, defaultErrorHandler);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, defaultErrorHandler);
		}
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	  			
	}
}

//╮(╯_╰)╭