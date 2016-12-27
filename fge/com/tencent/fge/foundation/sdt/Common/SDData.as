/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   SDData.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-2-25
#   Comment     :   一个安全数据类型的数据基础类。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-2 文件创建 
#
*************************************************************************/

package com.tencent.fge.foundation.sdt.Common
{
	import com.tencent.fge.codec.Base64;

	public class SDData
	{
		private static var maxlen:int = int.MAX_VALUE;
		private var m_listener:SDListenerInterface = null;
		private var m_store: Object = null;
		private var m_key: Object = null;
		private var m_len:int = 0;

        public function SDData(listener:SDListenerInterface = null)
        {
        	m_listener = listener;
        }
        
        public function refresh():Boolean
        {
        	var buf: Object = SDCore.decrypt(m_store, m_key);
        	if(buf == null || buf.length == 0)
        	{
        		return false;
        	}
        	
        	var key: Object = SDCore.randBytes(SDCore.keylen);
			
			var ret: Object = SDCore.encrypt(buf, key);
			if(ret == null || ret.length == 0)
			{
				return false;
			}
        	
			SDCore.freeBytes(buf);
			SDCore.freeBytes(m_key);
			SDCore.freeBytes(m_store);
			
        	this.m_key = key;
        	this.m_store = ret;
        	return true;
        }
		
		public function dispose(): void
		{
			SDCore.freeBytes(m_key);
			SDCore.freeBytes(m_store);
			
			m_listener = null;
			m_store = null;
			m_key = null;
			m_len = 0;
		}

        public function serialize():String
        {
            var bytes: Object = this.readStringBytes();
            var tmp:SDData = SDData.createByBytes(bytes, m_listener); 
            var ret: String = tmp.innerSerialize();
			SDCore.freeBytes(bytes);
			tmp.dispose();
			return ret;
        }

        private function innerSerialize():String
        {
            var nMagicNum:uint;
            var sMagicNum:String;
			var ret:String;
			
            nMagicNum = Math.random() * 0x00000fff + 0x000f000;//一定是16位
            ret = ((uint(this.m_len) ^ nMagicNum) + 0xf0000000).toString(16);//一定是32位
			
			/*
            if (ret.length < 2)
            {
                ret = "0" + ret;
            }
			*/
			
            sMagicNum = nMagicNum.toString(16);
			
			/*
            if (sMagicNum.length < 2)
            {
                sMagicNum = "0" + sMagicNum;
            }
			*/
			
            ret = ret + sMagicNum;
            ret = ret + Base64.encode_CharArray(SDCore.toArray(m_key));
            ret = ret + Base64.encode_CharArray(SDCore.toArray(m_store));
            return ret;
        }
        
        public function readStringBytes(): Object
        {
            var ret: Object = SDCore.decrypt(m_store, m_key);
            return ret;
        }
        
        
        public static function createByBytes(bytes: Object, listener:SDListenerInterface):SDData
        {
			var ret:SDData;
			if (bytes)
			{
				ret = new SDData(listener);//安全数据
				ret.m_len = bytes.length;
				
				var buf: Object = bytes;//SDCore.cloneBytes(bytes);
				ret.m_key = SDCore.randBytes(SDCore.keylen);
				ret.m_store = SDCore.encrypt(buf, ret.m_key);
			}
			return ret;
        }


        public static function createBySerialize(s:String, listener:SDListenerInterface):SDData
        {
			var ret:SDData = null;
			if (s)
			{
				ret = new SDData(listener);
	            
				var nMagicNum:uint = uint("0x" + s.slice(8, 12));
				var tmp:uint = uint("0x" + s.slice(0, 8));
				ret.m_len = nMagicNum ^ (tmp - 0xf0000000);
				
				/*
	            nMagicNum = int("0x" + s.slice(2, 4));
	            var tmp:int = int("0x" + s.slice(0, 2));
	            ret.m_len = nMagicNum ^ tmp;
				*/
	            
				var keyLen:int = Math.ceil(SDCore.keylen / 3) * 4 + 1;
				var datLen:int = Math.ceil(ret.m_len / 3) * 4 + 1;
	
	            ret.m_key = Base64.decode_CharArray(s.slice(12, keyLen + 12));
	            ret.m_store = Base64.decode_CharArray(s.slice(keyLen + 12));
			}     
            return ret;
        }
        
		protected static const version:String = "1.0.0";
		protected static const author:String = "slicoltang,slicol@qq.com";
		protected static const copyright:String = "腾讯计算机系统有限公司";	  
	}
}