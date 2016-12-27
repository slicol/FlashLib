/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   VFile.as
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
 * 					该文件定义一个虚拟文件封装类
 * 					其中在封装过程中，对于Zip文件的封装使用了第3方库（FZip）
 * 					在对FZip的研究中发现，其对Zip文件的支持也并不完全。
 * 					但是由于对Zip文件格式的了解不是很深，无法列举出FZip支持和不支持哪些Zip格式
 * 					目前可以确定的是，FZip可以很好地支持未压缩的Zip文件格式。
 * 					但是，对于一个VFS来说，压缩文件并不是最关键的。
 * 					在本系统中，只是借Zip文件作为VFS的一种本地存储格式。 
 * 
 * 					请保留FZip本身的版权。如有疑问，请与FZip的作者，或者与我联系。
#  	Modify      :   2009-6 文件创建 
#
*************************************************************************/

package com.tencent.fge.foundation.fvfs
{
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="open", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	[Event(name="added", type="flash.events.Event")]
	
	public class VFile extends EventDispatcher
	{
		public static const TYPE_RAW:int = 0;
		public static const TYPE_ZIP:int = 1;
		public static const TYPE_ZIPFILE:int = 2;
		
		private var m_type:int = 0;
		
		private var m_content:ByteArray;
		private var m_zip:FZip;
		private var m_zipFile:FZipFile;
		private var m_name:String;
		private var m_ext:String;
		private var m_urlStream:URLStream;
		
		public function VFile(name:String, type:int = 0)
		{
			if(name)
			{
				m_name = name;
				var i:int = name.lastIndexOf(".");
				if(i > 0)
				{
					m_ext = name.substr(i + 1).toLowerCase();
				}
			}
			
			if(m_ext == "zip" && type == 0)
			{
				m_type = TYPE_ZIP;
			}
			else
			{
				m_type = type;
			}
			
			
		}
		
		public function get name():String
		{
			return m_name;
		}
		
		public function get type():int
		{
			return m_type;
		}
		
		public function get content():*
		{
			switch(m_type)
			{
			case TYPE_RAW:
				return m_content;
			case TYPE_ZIP:
				return m_zip;
			case TYPE_ZIPFILE:
				return m_zipFile;
			default:;
			}
			return null;
		}
		
		public function set content(value:*):void
		{
			if(value is ByteArray)
			{
				m_type = TYPE_RAW;
				if(m_content == null)
				{
					m_content = new ByteArray;
				}
				m_content.position = 0;
				m_content.length = 0;
				(value as ByteArray).readBytes(m_content);
			}
			else if(value is FZip)
			{
				m_zip = value as FZip;
				m_type = TYPE_ZIP;
			}
			else if(value is FZipFile)
			{
				m_zipFile = value as FZipFile;
				m_type = TYPE_ZIPFILE;
			}
		}
		
		public function get byteArray():ByteArray
		{
			switch(m_type)
			{
			case TYPE_RAW:
				return m_content;
			case TYPE_ZIP:
				return null;
			case TYPE_ZIPFILE:
				return m_zipFile.content;
			default:;
			}
			return null;
		}
		
		public function get isZip():Boolean
		{
			return m_type == TYPE_ZIP;
		}
		
		public function get isZipFile():Boolean
		{
			return m_type == TYPE_ZIPFILE;
		}
		
		public function get isRawFile():Boolean
		{
			return m_type == TYPE_RAW;
		}
		
		
		public function open():void
		{
			close();
			openStream();
			
			dispatchEvent(new Event(Event.OPEN));
		}
		
		public function close():void
		{
			closeStream();
			
			if(isZip)
			{
				closeZip();
			}
			
			if(isZipFile)
			{
				closeZipFile();
			}
			
			if(m_content)
			{
				m_content.length = 0;
				m_content.position = 0;
				m_content = null;
			}
		}

		
		/**
		 * 
		 */
		private var m_cacheZipFile:FZipFile;
		public function getZipFileByName(name:String):FZipFile 
		{
			if(isZip)
			{
				if(m_cacheZipFile == null || m_cacheZipFile.filename != name)
				{
					m_cacheZipFile = m_zip.getFileByName(name);
				}
				return m_cacheZipFile;
			}
			return null;
		}
		
		
		private function openZip(stream:IDataInput):void
		{
			m_zip = new FZip;
			
			//这个以后再处理。这是因为FZip的版本更新了。
			//m_zip.loadStream(stream);
			
		}
		
		private function closeZip():void
		{
			if(m_zip)
			{
				m_zip.close();
				
				while(m_zip.getFileCount() > 0)
				{
					var file:FZipFile = m_zip.removeFileAt(0);
					if(file)
					{
						file.content = null;
					}
				}
				
				m_zip = null;
			}
		}
		
		private function closeZipFile():void
		{
			if(m_zipFile)
			{
				m_zipFile.content = null;
				m_zipFile = null;
			}
		}
		
		
		private function openStream():void
		{
			m_urlStream = new URLStream();
			m_urlStream.endian = Endian.LITTLE_ENDIAN;
			addEventHandlers(m_urlStream);
			m_urlStream.load(new URLRequest(m_name));
		}
		
		private function closeStream():void
		{
			if(m_urlStream)
			{
				removeEventHandlers(m_urlStream);
				m_urlStream.close();
				m_urlStream = null;
			}
		}
			
		protected function progressHandler(evt:Event):void 
		{
			dispatchEvent(evt.clone());
		}
		
		
		protected function completeHandler(evt:Event):void
		{
			var urlStream:URLStream = evt.target as URLStream;
			if(urlStream)
			{
				if(urlStream == m_urlStream)
				{
					if(isZip)
					{
						openZip(urlStream);
					}
					else
					{
						if(m_content == null)
						{
							m_content = new ByteArray;
						}
						m_content.length = 0;
						m_content.position = 0;
						urlStream.readBytes(m_content);
					}
					closeStream();
					dispatchEvent(evt.clone());
					return;
				}
				else
				{
					urlStream.close();
				}
				removeEventHandlers(urlStream);
			}
		}
		
		protected function defaultHandler(evt:Event):void 
		{
			dispatchEvent(evt.clone());
		}
			
		protected function defaultErrorHandler(evt:Event):void 
		{
			close();
			dispatchEvent(evt.clone());
		}
					
		protected function addEventHandlers(target:IEventDispatcher):void 
		{
			target.addEventListener(Event.COMPLETE, completeHandler);
			target.addEventListener(Event.OPEN, defaultHandler);
			target.addEventListener(HTTPStatusEvent.HTTP_STATUS, defaultHandler);
			target.addEventListener(IOErrorEvent.IO_ERROR, defaultErrorHandler);
			target.addEventListener(IOErrorEvent.VERIFY_ERROR, defaultErrorHandler);
			target.addEventListener(SecurityErrorEvent.SECURITY_ERROR, defaultErrorHandler);
			target.addEventListener(ProgressEvent.PROGRESS, progressHandler);
		}
		
		protected function removeEventHandlers(target:IEventDispatcher):void 
		{
			target.removeEventListener(Event.COMPLETE, completeHandler);
			target.removeEventListener(Event.OPEN, defaultHandler);
			target.removeEventListener(HTTPStatusEvent.HTTP_STATUS, defaultHandler);
			target.removeEventListener(IOErrorEvent.IO_ERROR, defaultErrorHandler);
			target.removeEventListener(IOErrorEvent.VERIFY_ERROR, defaultErrorHandler);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, defaultErrorHandler);
			target.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
		}
		
		/**
		 * Returns a string representation of the VFile object.
		 */		
		override public function toString():String 
		{
			switch(m_type)
			{
			case TYPE_ZIP:
				return m_zip.toString();
				break;
			case TYPE_ZIPFILE:
				return m_zipFile.toString();
				break;
			default:;
			}
			
			return "[VRawFile]"
				+ "\n  name:" + m_name
				+ "\n  date:" + "NaN"
				+ "\n  sizeCompressed:" + "NaN"
				+ "\n  sizeUncompressed:" + "NaN"
				+ "\n  versionHost:" + "NaN"
				+ "\n  versionNumber:" + "NaN"
				+ "\n  compressionMethod:" + "NaN"
				+ "\n  encrypted:" + "NaN"
				+ "\n  hasDataDescriptor:" + "NaN"
				+ "\n  hasCompressedPatchedData:" + "NaN"
				+ "\n  filenameEncoding:" + "NaN"
				+ "\n  crc32:" + "NaN"
				+ "\n  adler32:" + "NaN"
				+ "\n  super:" + super.toString();
		}
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	  
	}
}