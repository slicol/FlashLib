/*************************************************************************
版权所有 (C), 1998-2010, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   SWFFile.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-4
#   Comment     :   一个SWF文件的解析类
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-4 文件创建 
#
*************************************************************************/


package com.tencent.fge.codec.swf
{
	//import flash.filesystem.File;
	//import flash.filesystem.FileMode;
	//import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	public class SWFFile
	{
		private var m_rawBuf:ByteArray = new ByteArray;
		private var m_header:SwfHeader = new SwfHeader;
		private var m_lstTag:Array = new Array;
		
		public function SWFFile()
		{
		}
		
		
		public static function uncompress(content:ByteArray):ByteArray
		{
			var ret:ByteArray = new ByteArray;
			var buf:ByteArray = new ByteArray;			
			content.readBytes(ret, 0, 8);
			content.readBytes(buf, 0);
			
			//0x53 F 
			//0x43 C 
			if( ret[0] == 0x43)
			{
				buf.uncompress();
			}
			
			ret.position = 8;
			ret.writeBytes(buf);
			
			ret.position = 0;
			
			buf.clear();
			
			return ret;
		}
		
		
		public function getRawBuf():ByteArray{return m_rawBuf;}
		
		
		public function open(content:ByteArray):Boolean
		{			
			var buf:ByteArray = new ByteArray;			
			content.readBytes(m_rawBuf, 0, 8);
			content.readBytes(buf, 0);
			
			//0x53 F 
			//0x43 C 
			if( m_rawBuf[0] == 0x43)
			{
				buf.uncompress();
			}
			
			m_rawBuf.position = 8;
			m_rawBuf.writeBytes(buf);
			
			m_rawBuf.position = 0;
			m_header.writeBytes(m_rawBuf);
			
			while(m_rawBuf.position < m_rawBuf.length)
			{
				var tag:SwfTag = new SwfTag();
				if(tag.writeBytes(m_rawBuf) > 0)
				{
					this.m_lstTag.push(tag);
				}
			}
		
			return true;
		}
		
		
		
		/*
		public function open(path:String):Boolean
		{
			var file:File;
			if(path.charAt(1) == ":")
			{
				file = new File(path);
			}
			else
			{
				file = File.applicationDirectory;
				file = file.resolvePath(path);
			}
			
			var buf:ByteArray = new ByteArray;
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			fs.readBytes(m_rawBuf,0,8);
			fs.readBytes(buf, 0);
			fs.close();
						
			//0x53 F 
			//0x43 C 
			if( m_rawBuf[0] == 0x43)
			{
				buf.uncompress();
			}
			
			m_rawBuf.position = 8;
			m_rawBuf.writeBytes(buf);
			
			m_rawBuf.position = 0;
			m_header.writeBytes(m_rawBuf);
			
			while(m_rawBuf.position < m_rawBuf.length)
			{
				var tag:SwfTag = new SwfTag();
				if(tag.writeBytes(m_rawBuf) > 0)
				{
					this.m_lstTag.push(tag);
				}
			}
			
			
			
			return true;
		}
		*/
		
		
		public function combineTags(type:uint, buf:ByteArray):int
		{
			var startPos:uint = buf.position;
			for(var i:int = m_lstTag.length - 1; i >= 0; --i)
			{
				var tag:SwfTag = m_lstTag[i];
				if(tag.header.tagType == type)
				{
					buf.writeBytes(tag.data);
				}
			}
			
			return buf.position - startPos;
		}
		
		
		/*
		public function saveTags(type:uint, path:String, combine:Boolean = false):int
		{	
			if(combine)		
			{
				var buff:ByteArray = new ByteArray;	
				var size:int = this.combineTags(type, buff);
				this.saveBytes(buff, path);
				return size;
			}
			else
			{
				var tag:SwfTag;
				var j:int = 0;
				for(var i:int = 0; i < m_lstTag.length; ++i)
				{
					tag = m_lstTag[i];
					if(tag.header.tagType == type)
					{
						++j;
						this.saveBytes(tag.data, 
							path + "_" + type.toString() + "_" + j.toString() + ".tag"); 
					}
				}
				return j;
			}
		}
		*/

		/*
		public function saveBytes(buf:ByteArray, path:String):int
		{
			var file:File;
			if(path.charAt(1) == ":")
			{
				file = new File(path);
			}
			else
			{
				file = File.applicationDirectory;
				file = file.resolvePath(path);
			}
			
			file = new File(file.nativePath);
			
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.WRITE);
			fs.writeBytes(buf);
			fs.close();	
			return buf.length;			
		}
		*/
		
		/*
		public function saveRawBytes(path:String):int
		{
			m_rawBuf.position = 0;
			return this.saveBytes(m_rawBuf, path);
		}
		*/
		
		
		
		
		public function getTagBytesList(type:uint):Array
		{
			var lstBytes:Array = new Array;
			var tag:SwfTag;
			for(var i:int = 0; i < m_lstTag.length; ++i)
			{
				tag = m_lstTag[i];
				if(tag.header.tagType == type)
				{
					lstBytes.push(tag.data);
				}
			}
			return lstBytes;
		}
		
		public function unShell(buf:ByteArray, key:Array):void
		{
			var lstTag:Array = new Array;
			var tag:SwfTag;
			for(var i:int = 0; i < m_lstTag.length; ++i)
			{
				tag = m_lstTag[i];
				if(tag.header.tagType == 87)
				{
					lstTag.push(tag);
				}
			}
			
			for(var j:int = 0; j < key.length; ++j)
			{
				var pwd:int = key[j];
				tag = lstTag[pwd - 1];
				buf.writeBytes(tag.data);
			}	
		}

		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	
	}
}


import com.tencent.fge.codec.swf.SWFUtil;

import flash.utils.ByteArray;
	
class SwfHeader
{
	public var sign:ByteArray = new ByteArray();//3
	public var version:uint;//1
	public var fileSize:uint;//4
	public var xMin:uint;//4
	public var xMax:uint;//4
	public var yMin:uint;//4
	public var yMax:uint;//4
	public var frameRate:uint;//2
	public var frameCount:uint;//2
	public var buffer:ByteArray = new ByteArray;
	
	public function signToString():String
	{
		return sign.toString();
	}
	
	public function writeBytes(buf:ByteArray):uint
	{
		var startOffset:uint = buf.position;
		var header_length:uint = 0;
	    buf.readBytes(sign, 0, 3);
	    header_length += 3;
	    version = buf.readUnsignedByte();
	    header_length += 1;
	    
	    var len1:uint, len2:uint, len3:uint, len0:uint;
	    len0 = buf.readUnsignedByte();
	    len1 = buf.readUnsignedByte();
	    len2 = buf.readUnsignedByte();
	    len3 = buf.readUnsignedByte();
	    fileSize = len3 << 24 | len2 << 16 | len1 << 8 | len0;
	    header_length += 4;
	    

	    var b:uint = buf.readUnsignedByte();
	    header_length += 1;
	    var bits:uint = (b >> 3) * 4 + 5;
	    var bytes:uint = (bits + 7) / 8;
	    bytes -= 1;
	    buf.position += bytes;
	    header_length += bytes;
	    
	    frameRate = buf.readUnsignedShort();
	    header_length += 2;
	    frameCount = buf.readUnsignedShort();
	    header_length += 2;
	    
	    buf.position = startOffset;
	    buf.readBytes(buffer, 0, header_length);

	    return header_length;			
	}
}

class TagHeader extends Object
{
	public var size:uint;
	public var tagType:uint;//2
	public var tagSize:uint;//4
	

	public function readBytes(buf:ByteArray):uint
	{
		var startPos:uint = buf.position;
    	var t:uint = 0;
    	if(tagSize >= 0x3F)
    	{
    		t = (tagType << 6) | 0x3F;//2
    		buf.writeShort(t);
    		buf.writeUnsignedInt(tagSize);
    	}
    	else
    	{
    		t = (tagType << 6) | tagSize;
    		buf.writeShort(t);
    	}
    	return buf.position - startPos;
	}
	
	public function writeBytes(buf:ByteArray):int
	{
		var startPos:uint = buf.position;
		var b0:uint = buf.readUnsignedByte();
		var b1:uint = buf.readUnsignedByte();
		var b2:uint;
		var b3:uint;
		var w:uint;//2
		w = SWFUtil.swapCombine2(b0,b1);
		tagType = w >> 6;
		tagSize = w & 0x3f;
		if(tagSize == 0x3f)
		{
			b0 = buf.readUnsignedByte();
			b1 = buf.readUnsignedByte();
			b2 = buf.readUnsignedByte();
			b3 = buf.readUnsignedByte();
			tagSize = SWFUtil.swapCombine4(b0,b1,b2,b3);
		}
		size = buf.position - startPos;
		tagSize += size;
		return size;
	}
}

class SwfTag
{
	public var header:TagHeader = new TagHeader;
	public var characterId:uint;//2
	public var reserved:ByteArray = new ByteArray;//4	
	public var data:ByteArray = new ByteArray();

	//从tag里读出字节
	public function readBytes(buf:ByteArray):uint
	{
    	return 0;	
	}
	
	//向Tag写入字节
	public function writeBytes(buf:ByteArray):uint
	{
		var startPos:uint = buf.position;
		if(header.writeBytes(buf) > 0)
		{
			var offset:uint = 0;
			if(header.tagType == 87)
			{
				var b0:uint = buf.readUnsignedByte();
				var b1:uint = buf.readUnsignedByte();
				characterId = SWFUtil.swapCombine2(b0, b1);
				buf.readBytes(reserved, 0, 4);
				offset = 6;
			}
			
			data.position = 0;
			buf.readBytes(data,0,header.tagSize - header.size - offset);
		}
		return buf.position - startPos;
	}
	
	
}

