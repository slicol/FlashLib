package com.tencent.fge.foundation.network
{
	public final class ProtocolError
	{
		public static const SEND_ERROR:uint = 1;
		
		public static function getErrString(errCode:uint):String
		{
			switch(errCode)
			{
			case 1: return "协议发送错误！";
			default: return "未知错误码！"
			}
		}
	}
}