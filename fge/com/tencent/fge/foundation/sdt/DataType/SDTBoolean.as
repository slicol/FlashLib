/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   SDTBoolean.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-2-25
#   Comment     :   一个安全数据类型的Bool类。
 * 
 * 					如有疑问，请与本人联系。
#  	Modify      :   2009-2 文件创建 
#
*************************************************************************/


package com.tencent.fge.foundation.sdt.DataType
{
	import com.tencent.fge.foundation.sdt.Common.SDCore;
	import com.tencent.fge.foundation.sdt.Common.SDData;
	import com.tencent.fge.foundation.sdt.Common.SDListenerInterface;
	import com.tencent.fge.foundation.sdt.Common.SDTBase;
	
	public class SDTBoolean extends SDTBase
	{
		public function SDTBoolean(data:Boolean = false,
			check:Boolean = false, 
			security:uint = 0, 
			listener:SDListenerInterface = null)
		{
			super(check, security, listener);
			value = data;
		}
		
        public function set value(data:Boolean):void
        {
        	var tmp:int = int(Math.random() * 100);
        	if(data)
        	{
        		tmp = 255 - tmp;
         	}

    		var bytes: Object = SDCore.string2bytes(tmp.toString());
    		super.setValue(bytes);
			SDCore.freeBytes(bytes);
        }

        public function get value():Boolean
        {
            var bytes: Object = super.getValue();
            var tmp: int = int(SDCore.bytes2string(bytes));
            var data: Boolean = tmp > 100;
			SDCore.freeBytes(bytes);
            return data;
        }

        public function not():Boolean
        {
            var tmp:Boolean = !this.value;
            this.value = tmp;
            return tmp;
        }
	}	
}