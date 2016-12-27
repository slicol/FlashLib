/*************************************************************************
版权所有 (C), 1998-2010, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   BSON.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-3
#   Comment     :   一个BSON（已经申请专利）解析器。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2010-3 文件创建 
#
*************************************************************************/

package com.tencent.fge.codec.bson
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public final class BSON extends EventDispatcher
	{
		private static var ms_mapBSO:Dictionary = new Dictionary();
		
		public function BSON(target:IEventDispatcher=null)
		{
			super(target);
		}

		public static function addDocument(doc:XML):void
		{
			//
			var listBSO:XMLList = doc.children();
			var type:String;
			var itemtype:String;
			
			for(var i:int = 0; i < listBSO.length(); ++i)
			{
				var xmlBSO:XML = listBSO[i];
				type = xmlBSO.@type;
				
				if(ms_mapBSO[type] != null)
				{
					continue;
				}
				
				var bso:BSObject = new BSObject();
				if(!bso.create(xmlBSO))
				{
					continue;
				}
				
				ms_mapBSO[bso.type] = bso;
			}
			
		}
		
		public static function getBSO(type:String):BSObject
		{
			return ms_mapBSO[type];
		}
		
		public static function encode(type:String, o:Object, bytes:ByteArray):Boolean
		{
			var bso:BSObject = ms_mapBSO[type];
			if(bso == null) return false;
			var ref:RefObject = new RefObject(o);
			return bso.encode(ref, bytes);
		}
		
		public static function decode(type:String, bytes:ByteArray, o:Object):Boolean
		{
			var bso:BSObject = ms_mapBSO[type];
			if(bso == null) return false;
			var ref:RefObject = new RefObject(o);
			return bso.decode(bytes,ref);
		}
		
		public static var demo:XML = 
		<BSON>
			<BSO type="demo">
				<Notation type="Number" name="id" headsize="0" bodysize="4"/>
				<Notation type="String" name="name" headsize="0" bodysize="16"/>
				<Notation type="String" name="title" headsize="2" bodysize="0"/>
				<Notation type="Array" name="idlist" headsize="0" bodysize="10" itemtype="Notation">
					<Notation type="Number" name="id" headsize="0" bodysize="4"/>
				</Notation>
				<Notation type="Array" name="friendlist" headsize="2" bodysize="0" itemtype="BSO">
					<BSO type="friend"/>
				</Notation>
			</BSO>
			
			<BSO type="friend">
				<Notation type="Number" name="id" headsize="0" bodysize="4"/>
				<Notation type="String" name="name" headsize="0" bodysize="16"/>
			</BSO>	
		</BSON>		
		
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";			
		
	}
	
	

}


