/*************************************************************************
版权所有 (C), 1998-2009, 腾讯计算机系统有限公司
*************************************************************************/
/*************************************************************************
#   File Name   :   SDTDate.as
#   Version     :   1.0.0
#   Author      :   slicoltang
#   Date        :   2010-2-25
#   Comment     :   一个安全数据类型的String类。
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
	
	public class SDTString extends SDTBase
	{
		public function SDTString(data:String = "", 
			check:Boolean = false, 
			security:uint = 0, 
			listener:SDListenerInterface = null)
		{
			super(check, security, listener);
			value = data;
		}
		
		
        public function set value(data:String):void
        {
    		var bytes: Object = SDCore.string2bytes(data);
    		super.setValue(bytes);
			SDCore.freeBytes(bytes);
        }

        public function get value():String
        {
            var bytes:Object = super.getValue();
            var dat:String = SDCore.bytes2string(bytes);
			SDCore.freeBytes(bytes);
            return dat;
        } 
	}
}