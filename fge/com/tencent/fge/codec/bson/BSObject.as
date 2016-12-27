/*************************************************************************
版权所有 (C), 1998-2010, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   BSObject.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-3
#   Comment     :   BSON里的每一个对象。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-3 文件创建 
#
*************************************************************************/

package com.tencent.fge.codec.bson
{
	import flash.utils.ByteArray;
	
	public class BSObject
	{
		public var type:String = "";
		public var listChildren:Array = new Array();
		
		public function BSObject(type:String = "")
		{
			this.type = type;
		}
			
		public function create(doc:XML):Boolean
		{
			this.type = doc.@type;
			var listNota:XMLList = doc.children();
			for(var j:int = 0; j < listNota.length(); ++j)
			{
				var xmlNota:XML = listNota[j];
				var nota:Notation = Notation.createNotation(xmlNota);
				this.listChildren.push(nota);
			}
			return true;
		}
		
			
		public function encode(ref:RefObject, bytes:ByteArray):Boolean
		{
			for(var i:int = 0; i < listChildren.length; ++i)
			{
				var child:BSObject = listChildren[i];
				if(child == null) return false;
				if(!child.encode(ref, bytes)) return false;
			}
			return true;
		}
		
		public function decode(bytes:ByteArray, ref:RefObject):Boolean
		{
			for(var i:int = 0; i < listChildren.length; ++i)
			{
				var child:BSObject = listChildren[i];
				if(child == null) return false;
				if(!child.decode(bytes, ref)) return false;			
			}
			return true;
		}
	}	
}
