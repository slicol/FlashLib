/*************************************************************************
版权所有 (C), 1998-2010, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   Notation.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-3
#   Comment     :   BSON里的每一个标识。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-3 文件创建 
#
*************************************************************************/

package com.tencent.fge.codec.bson
{
	import flash.utils.ByteArray;
	
	public class Notation extends BSObject
	{
		public var name:String = "";
		public var bodysize:int = 0;
		public var headsize:int = 0;
				
		public function Notation(type:String = "")
		{
			super(type);
		}
		
		
		static public function createNotation(doc:XML):Notation
		{
			var type:String = doc.@type;
			var nota:Notation;
			
			switch(type)
			{
			case "Array": nota = new ArrayNotation(); break;
			default: nota = new Notation(type); break;
			}
			
			nota.create(doc);
			return nota;
		}
		
		override public function create(doc:XML):Boolean
		{
			this.type = doc.@type;
			this.name = doc.@name;
			this.headsize = Number(doc.@headsize);
			this.bodysize = Number(doc.@bodysize);
			return true;	
		}


		
		override public function encode(ref:RefObject, bytes:ByteArray):Boolean
		{
			switch(type)
			{
			case "Number": return encodeNumber(ref, bytes);
			case "String": return encodeString(ref, bytes);
			default:
			}
			return false;
		}
		
		override public function decode(bytes:ByteArray, ref:RefObject):Boolean
		{
			switch(type)
			{
			case "Number": return decodeNumber(bytes, ref);
			case "String": return decodeString(bytes, ref);
			default:
			}
			return false;	
		}
		
		protected function encodeNumberWorker(value:int, size:int, bytes:ByteArray):Boolean
		{
			switch(size)
			{
			case 0: return true;
			case 1: bytes.writeByte(value); return true;
			case 2: bytes.writeShort(value);  return true;
			case 4: bytes.writeInt(value);  return true;
			default: return false;	
			}			
		}
		
		private function encodeNumber(ref:RefObject, bytes:ByteArray):Boolean
		{
			if(ref.value == null)
			{
				return encodeNumberWorker(0, bodysize, bytes);
			}
			
			if(name != "" && name != null)
			{
				return encodeNumberWorker(ref.value[name] , bodysize, bytes);		
			}
			else
			{
				return encodeNumberWorker(ref.value as int, bodysize, bytes);			
			}

			return false;
		}
		
		private function encodeString(ref:RefObject, bytes:ByteArray):Boolean
		{
			var actualsize:int = bodysize;
			var s:String = "";
			
			if(ref.value != null)
			{
				if(name == null || name == "")
				{
					s = ref.value as String;
				}
				else
				{
					s = ref.value[name];
				}
			}
			
			if(headsize > 0)
			{
				actualsize = s.length;
				if(!encodeNumberWorker(actualsize, headsize, bytes))
				{
					return false;
				}
			}
			
			var pos1:uint = bytes.position;
			bytes.writeUTFBytes(s);
			bytes.position = pos1 + actualsize;
			bytes.length = bytes.position;
			
			return true;
		}
		
		
		protected function decodeNumberWorker(bytes:ByteArray, size:int):*
		{
			switch(size)
			{
			case 0: return 0;
			case 1: return bytes.readByte();
			case 2: return bytes.readShort();
			case 4: return bytes.readInt();
			default: return null;
			}
		}
		
		private function decodeNumber(bytes:ByteArray, ref:RefObject):Boolean
		{
			var tmp:*;
			if(name != null && name != "")
			{
				tmp = decodeNumberWorker(bytes, bodysize);
				if(tmp == null) return false;
				ref.value[name] = tmp;
			}
			else
			{
				tmp = decodeNumberWorker(bytes, bodysize);
				if(tmp == null) return false;
				ref.value = tmp;
			}
			return true;
		}
		
		private function decodeString(bytes:ByteArray, ref:RefObject):Boolean
		{
			var actualsize:int = bodysize;
			if(headsize > 0)
			{
				var tmp:* = decodeNumberWorker(bytes, headsize);
				if(tmp == null) return false;
				actualsize = tmp;
			}
			
			if(name == null || name == "")
			{
				ref.value = bytes.readUTFBytes(actualsize);
			}
			else
			{
				ref.value[name] = bytes.readUTFBytes(actualsize);
			}

			return true;
		}
	}
}
	import com.tencent.fge.codec.bson.BSObject;
	import com.tencent.fge.codec.bson.BSON;
	import com.tencent.fge.codec.bson.Notation;
	import flash.utils.ByteArray;
	import com.tencent.fge.codec.bson.RefObject;
	


class ArrayNotation extends Notation
{
	public var itemtype:String = "";
	public var listChildrenType:Array = new Array;
	
	public function ArrayNotation()
	{
		super("Array");
	}
	
	override public function create(doc:XML):Boolean
	{
		super.create(doc);
		this.itemtype = doc.@itemtype;
		if(itemtype == "Notation")
		{
			var listNota:XMLList = doc.children();
			for(var i:int = 0; i < listNota.length(); ++i)
			{
				var xmlNota:XML = listNota[i];
				var nota:Notation = Notation.createNotation(xmlNota);
				this.listChildren.push(nota);
			}
			return true;
		}
		else
		{
			var listBSOType:XMLList = doc.children();
			for(var j:int = 0; j < listBSOType.length(); ++j)
			{
				var xmlBSOType:XML = listBSOType[j];
				this.listChildrenType.push(String(xmlBSOType.@type));
			}
			return true;
		}
	}
	
	private function precode():Boolean
	{
		if(this.listChildren.length >= this.listChildrenType.length)
		{
			return true;
		}

		listChildren.length = 0;
		for(var i:int = 0; i < this.listChildrenType.length; ++i)
		{
			var type:String = this.listChildrenType[i];
			var bso:BSObject = BSON.getBSO(type);
			if(bso == null)
			{
				listChildren.length = 0;
				return false;
			}
			listChildren.push(bso);
		}
		return true;
	}

	override public function encode(ref:RefObject, bytes:ByteArray):Boolean
	{
		if(!precode()) return false;
		
		var actualsize:int = bodysize;
		var a:Array = ref.value[name];
		if(headsize > 0)
		{
			actualsize = a.length;
			if(!encodeNumberWorker(actualsize, headsize, bytes))
			{
				return false;
			}
		}
		
		for(var i:int = 0; i < actualsize; ++i)
		{
			var item:RefObject = new RefObject;
			if(i < a.length)
			{
				item.value = a[i];
			}
			for(var j:int = 0; j < listChildren.length; ++j)
			{
				var bso:BSObject = listChildren[j];
				bso.encode(item, bytes);
			}
		}
		
		return true;
	}
	
	override public function decode(bytes:ByteArray, ref:RefObject):Boolean
	{
		if(!precode()) return false;
		
		var actualsize:int = bodysize;
		if(headsize > 0)
		{
			var tmp:* = decodeNumberWorker(bytes, headsize);
			if(tmp == null) return false;
			actualsize = tmp;
		}
		
		var a:Array = new Array(actualsize);
		ref.value[name] = a;

		for(var i:int = 0; i < actualsize; ++i)
		{
			var item:RefObject = new RefObject;
			item.value = new Object;
			for(var j:int = 0; j < listChildren.length; ++j)
			{
				var bso:BSObject = listChildren[j];
				bso.decode(bytes, item);
			}
			a[i] = item.value;
		}
		
		return true;
	}	
}

