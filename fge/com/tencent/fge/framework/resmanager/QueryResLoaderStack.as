package com.tencent.fge.framework.resmanager
{
	import com.tencent.fge.foundation.log.client.Log;
	import com.tencent.fge.framework.resmanager.loader.ResLoader;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	/**
	 * 查询resloader信息 
	 * @author rlinhe
	 * 
	 */	
	public class QueryResLoaderStack
	{
		public static const FORMAT_STACK:uint = 0x1;
		public static const FORMAT_DEFAULT:uint = 0;
		
		private static var _instance:QueryResLoaderStack;
		public static var _isLock:Boolean;
		
		private var _msgTF:String;
		private var _msgFormatFlag:uint = FORMAT_DEFAULT;
		
		private var _ignoreURL:Array;
		
		
		private var _lstQueryHelper:Vector.<QueryHelper>;
		
		private var log:Log = new Log(this);
		
		public function QueryResLoaderStack()
		{
		}
		
		public static function getInstance():QueryResLoaderStack
		{
			if(_instance == null)
			{
				_instance = new QueryResLoaderStack();
			}
			return _instance;
		}
		
		public function initialize(isLock:Boolean = false):void {
			_isLock = isLock;
			if (_isLock) run()
		}
		
		private function run():void {
			loadConfig();
			
			_ignoreURL = new Array(); 
			
			_lstQueryHelper = new Vector.<QueryHelper>;
		}
		/**
		 * 加载配置文件 可以忽略不析构的资源 
		 */		
		private function loadConfig():void {
			var urlRequest:URLRequest = new URLRequest("../../bin/resLoaderIgnore.txt");
			var urlLoaderIgnoreList:URLLoader = new URLLoader();
			urlLoaderIgnoreList.dataFormat = URLLoaderDataFormat.TEXT;
			urlLoaderIgnoreList.addEventListener(Event.COMPLETE, onLoaderEvent);
			urlLoaderIgnoreList.addEventListener(IOErrorEvent.IO_ERROR, onLoaderEvent);
			urlLoaderIgnoreList.load(urlRequest);
		}
		private function onLoaderEvent(e:Event):void {
			
			var urlLoaderIgnoreList:URLLoader = e.currentTarget as URLLoader;
			if(null != urlLoaderIgnoreList)
			{
				urlLoaderIgnoreList.removeEventListener(Event.COMPLETE, onLoaderEvent);
				urlLoaderIgnoreList.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderEvent);
			}
			
			switch(e.type)
			{
			case Event.COMPLETE:
				_ignoreURL = String(e.currentTarget["data"]).split('\r\n');
				break;
			
			case IOErrorEvent.IO_ERROR:
				log.warn("onLoaderEvent", "can NOT load the resLoaderIgnore.txt!!!");
				break;
			
			default:
				break;
			}
		}
		
		public function setFortmatFlag(flag:uint):void
		{
			_msgFormatFlag = flag;
		}
		
		/**
		 * 拷贝信息到剪贴板
		 * @param text
		 */		
		public function copyForClipboard():void {
			setupMsg();
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, _msgTF);
		}
		
		/**
		 * 处理信息
		 */		
		private function setupMsg():void {
			var _existArr:Vector.<QueryHelper>  = new Vector.<QueryHelper>;
			var _ignoreArr:Vector.<QueryHelper>  = new Vector.<QueryHelper>;
			
			var oneQueryHelper:QueryHelper;
			var oneStackInfo:String;
			
			
			for each(oneQueryHelper in _lstQueryHelper)
			{
				if(null != oneQueryHelper)
				{
					if(true == filterIgnoreURL(oneQueryHelper.url, _ignoreURL))
					{
						_existArr.push(oneQueryHelper);
					}
					else
					{
						_ignoreArr.push(oneQueryHelper);
					}
				}
			}
			
			_existArr.sort(QueryHelper.compareLoadCountDescending);
			_ignoreArr.sort(QueryHelper.compareLoadCountDescending);
			
			var existLeakFileCount:int = 0;
			var existLeakFileSize:int = 0;
			var existLeakLoadSize:int = 0;
			var ignoreLeakFileCount:int = 0;
			var ignoreLeakFileSize:int = 0;
			var ignoreLeakLoadSize:int = 0;
			for each(oneQueryHelper in _existArr)
			{
				if(null != oneQueryHelper)
				{
					if(true == oneQueryHelper.isLeak)
					{
						existLeakFileCount += 1;
						existLeakFileSize += oneQueryHelper.size;
						existLeakLoadSize += oneQueryHelper.currCount * oneQueryHelper.size;
					}
				}
			}
			for each(oneQueryHelper in _ignoreArr)
			{
				if(null != oneQueryHelper)
				{
					if(true == oneQueryHelper.isLeak)
					{
						ignoreLeakFileCount += 1;
						ignoreLeakFileSize += oneQueryHelper.size;
						ignoreLeakLoadSize += oneQueryHelper.currCount * oneQueryHelper.size;
					}
				}
			}
			
			_msgTF = "";
			_msgTF += "*********************************************************************************************************************************************\n";
			_msgTF += "**********************************************  查询ResLoader的load和unload的情况   *********************************************************\n";
			_msgTF += "*********************************************************************************************************************************************\n";
			
			
			
			
			
			_msgTF += "\n\n############################################################ 概况  ############################################################\n";
			_msgTF +=
				"load过的资源数目："+ _lstQueryHelper.length + "\n" +
				"------------------------------\n" +
				"load次数大于unload次数，且不可忽略的资源：\n" +
				"   累计文件数目为"+ existLeakFileCount + "\n" +
				"   累计文件大小为" + Math.round(Number(existLeakFileSize)/1024.0) + "KB\n" +
				"   累计加载大小为" + Math.round(Number(existLeakLoadSize)/1024.0) + "KB\n" +
				"------------------------------\n" +
				"load次数大于unload次数，可以忽略的资源：\n" +
				"   累计文件数目为"+ ignoreLeakFileCount + "\n" +
				"   累计文件大小为" + Math.round(Number(ignoreLeakFileSize)/1024.0) + "KB\n" +
				"   累计加载大小为" + Math.round(Number(ignoreLeakLoadSize)/1024.0) + "KB\n";
			_msgTF += "#################################################################################################################################\n\n";
			
			
			
			
			_msgTF += "\n\n#################################### 不可忽略的资源（按当前加载累计泄漏次数从大到小排序） ############################################\n";
			for each(oneQueryHelper in _existArr)
			{
				_msgTF += "URL：" + oneQueryHelper.url + "\n";
				_msgTF += "文件大小："+ Math.round(Number(oneQueryHelper.size)/1024.0) + "KB\n";
				_msgTF += "当前泄漏累计加载大小："+ Math.round(Number(oneQueryHelper.size * oneQueryHelper.currCount)/1024.0) + "KB\n";
				_msgTF += "load的次数：" + oneQueryHelper.loadCount + "\n";
				_msgTF += "unload的次数：" + oneQueryHelper.unloadCount + "\n";
				
				if(0 != (_msgFormatFlag & FORMAT_STACK))
				{
					_msgTF += "栈信息：";
					for each(oneStackInfo in oneQueryHelper.lstLoadStack)
					{
						_msgTF += "\n" + oneStackInfo;
					}
				}
				_msgTF += "\n========================================================================================================================\n";
			}
			_msgTF += "\n#########################################################################################################################\n\n";
			
			
			
			
			_msgTF += "\n\n#################################### 可忽略的资源（按当前加载累计泄漏次数从大到小排序） ############################################\n";
			for each(oneQueryHelper in _ignoreArr)
			{
				_msgTF += "URL：" + oneQueryHelper.url + "\n";
				_msgTF += "文件大小："+ Math.round(Number(oneQueryHelper.size)/1024.0) + "KB\n";
				_msgTF += "当前泄漏累计加载大小："+ Math.round(Number(oneQueryHelper.size * oneQueryHelper.currCount)/1024.0) + "KB\n";
				_msgTF += "load的次数：" + oneQueryHelper.loadCount + "\n";
				_msgTF += "unload的次数：" + oneQueryHelper.unloadCount + "\n";
				
				if(0 != (_msgFormatFlag & FORMAT_STACK))
				{
					_msgTF += "栈信息：";
					for each(oneStackInfo in oneQueryHelper.lstLoadStack)
					{
						_msgTF += "\n" + oneStackInfo;
					}
				}
				_msgTF += "\n========================================================================================================================\n";
			}
			_msgTF += "\n#########################################################################################################################\n\n";
		}
		
		/**
		 * 过滤路径 
		 * @param url
		 * @return 
		 * 
		 */		
		private function filterIgnoreURL(url:String,urlList:Array):Boolean {
			var ret:Boolean = true;
			
			for each(var s:String in urlList) {
				if (url.indexOf(s) != -1) {
					ret = false;
					break;
				}
			}
			
			return ret;
		}
		
		/**
		 * 进入resloader类 load方法 
		 * @param resloader
		 * 
		 */		
		public function addResLoader(resloader:ResLoader):void {
			var url:String = resloader.url;
			
			var queryHelper:QueryHelper = getQueryHelper(url);
			if(null == queryHelper)
			{
				queryHelper = new QueryHelper;
				queryHelper.url = url;
				_lstQueryHelper.push(queryHelper);
			}
			++queryHelper.loadCount;
			
			try{
				throw new Error("print stack");
			}catch(err:Error){
				queryHelper.lstLoadStack.push(err.getStackTrace());
			}
		}
		/**
		 * 加载资源完毕后更新数据 
		 * @param resloader
		 * 
		 */		
		public function updateResLoader(resloader:ResLoader):void {
			var url:String = resloader.url;
			var queryHelper:QueryHelper = getQueryHelper(url);
			if(null != queryHelper)
			{
				queryHelper.size = resloader.size;
			}
		}
		
		/**
		 * 资源被释放 
		 * @param resloader
		 * 
		 */		
		public function unResLoader(resloader:ResLoader):void {
			var url:String = resloader.url;
			var queryHelper:QueryHelper = getQueryHelper(url);
			if(null != queryHelper)
			{
				++queryHelper.unloadCount;
			}
			
			
			
			
			try{
				throw new Error("print stack");
			}catch(err:Error){
				if(null != queryHelper)
				{
					//	TODO: enable it if neccessary
					//					queryHelper.lstUnloadStack.push(err.getStackTrace());
				}
			}
		}
		
		private function getQueryHelper(url:String):QueryHelper
		{
			for each(var queryHelper:QueryHelper in _lstQueryHelper)
			{
				if(null != queryHelper)
				{
					if(queryHelper.url == url)
					{
						return queryHelper;
					}
				}
			}
			
			return null;
		}
		
		public function destory ():void {
			_ignoreURL = null;
			_lstQueryHelper = null;
		}
		
	}
}

class QueryHelper
{
	public var url:String;
	public var size:int;
	
	public var loadCount:int;
	public var unloadCount:int;
	
	public var lstLoadStack:Vector.<String> = new Vector.<String>;
	public var lstUnloadStack:Vector.<String> = new Vector.<String>;
	
	public function get currCount():int { return loadCount - unloadCount; }
	
	public function get isLeak():Boolean { return currCount > 0; }
	
	
	public static function compareLoadCountDescending(a:QueryHelper, b:QueryHelper):int
	{
		if(a.currCount > b.currCount)
		{
			return -1;
		}
		else if(a.currCount < b.currCount)
		{
			return 1;
		}
		else
		{
			return compareLoadSizeDescending(a, b);
		}
	}
	
	public static function compareLoadSizeDescending(a:QueryHelper, b:QueryHelper):int
	{
		var aCurrLoadSize:int = a.size * a.currCount;
		var bCurrLoadSize:int = b.size * b.currCount;
		
		if(aCurrLoadSize > bCurrLoadSize)
		{
			return -1;
		}
		else if(aCurrLoadSize < bCurrLoadSize)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
}