package com.tencent.fge.utils
{
	public class NetworkUtil
	{
		public static function convertIpFromUintToString(uiIp:uint):String
		{
			var strRet:String;
			strRet = uint((uiIp >> 0) & 0x000000ff).toString() + ".";
			strRet += uint((uiIp >> 8) & 0x00000ff).toString() + ".";
			strRet += uint((uiIp >> 16) & 0x000000ff).toString() + ".";
			strRet += uint((uiIp >> 24) & 0x00000ff).toString();
			
			return strRet;
		}
	}
}