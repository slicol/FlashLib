package slicol.foundation.singleton
{
	import com.tencent.fge.utils.ClassUtil;
	
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	
	public class SingletonFactory
	{
		private static var ms_me:SingletonFactory;
		
		private var m_mapProxy:Dictionary = new Dictionary;
		
		public function SingletonFactory()
		{
		}
		
		private static function get me():SingletonFactory
		{
			if(!ms_me)
			{
				ms_me = new SingletonFactory();
			}
			return ms_me;
		}
		
		//--------------------------------------------------
		
		public static function getFactory(name:Class):SingletonFactory
		{
			return getInstance(name) as SingletonFactory;
		}
		
		public static function getInstance(name:*):*
		{
			var instance:* = me.getInstance(name);
			if(!instance)
			{
				me.regSingleton(name, false);
				instance = me.getInstance(name);
			}
			
			return instance;
		}
		
		public static function regSingleton(item:*, validation:Boolean):Boolean
		{
			return me.regSingleton(item, validation);
		}
		
		
		public static function getAllSingletonInstanceList():Array
		{
			return me.getAllSingletonInstanceList();
		}
		
		public static function getAllSingletonNameList():Array
		{
			return me.getAllSingletonNameList();
		}
		
		//--------------------------------------------------
		
		protected function getAllSingletonInstanceList():Array
		{
			return getAllSingletonListWorker(false);
		}
		
		protected function getAllSingletonNameList():Array
		{
			return getAllSingletonListWorker(true);
		}
		
		
		/**
		 * 获取工厂（以及子工厂）内的所有单例。
		 * withName : 如果为True，则获取单例的类名列表。如果为False，则猎取单例的实例列表。
		 **/
		private function getAllSingletonListWorker(withName:Boolean):Array
		{
			var ret:Array = new Array;
			
			for each(var item:Proxy in m_mapProxy)
			{
				if(item.instance is SingletonFactory)
				{
					var children:Array = SingletonFactory(item.instance).getAllSingletonListWorker(withName);
					ret = ret.concat(children);
				}
				else
				{
					if(withName)
					{
						ret.push(ClassUtil.getFullName(item.type));
					}
					else if(item.instance)
					{
						ret.push(item.instance);
					}
				}
			}
			
			return ret;
		}
		
		
		/**
		 * 注册一个单例
		 * item : 可以是单例的类名、类定义、实例。
		 * validation:是否验证该单例是否已经被注册。如果为True，且已经被注册，则会抛出一个Error。
		 * return : 是否注册成功。
		 **/
		public function regSingleton(item:*, validation:Boolean = false):Boolean
		{
			if(item is String)
			{
				if(!ApplicationDomain.currentDomain.hasDefinition(item))
				{
					return false;
				}
				item = ApplicationDomain.currentDomain.getDefinition(item) as Class;
			}
			
			var type:Class = item as Class;
			var name:String = ClassUtil.getFullName(item);
			
			if(!type)
			{
				if(!ApplicationDomain.currentDomain.hasDefinition(name))
				{
					return false;
				}
				
				type = ApplicationDomain.currentDomain.getDefinition(name) as Class;
			}
			
			
			var proxy:Proxy = m_mapProxy[name];
			
			if(!proxy)
			{
				proxy = new Proxy;
				m_mapProxy[name] = proxy;
			}
			
			proxy.type = type;
			proxy.factory = this;
			
			if(!(item is Class))
			{
				if(!proxy.instance)
				{
					proxy.instance = item;
					return true;
				}
				else
				{
					if(proxy.instance != item)
					{
						if(!validation)
						{
							return false;
						}

						handleSingletonError(name);
					}
				}
			}
			
			return true;
		}
		

		/**
		 * 获取该单例的实例
		 * name : 可以是单例的类名、类定义;
		 * return : 如果单例被注册，则实例未创建，则创建并返回实例，如果已经创建，则直接返回其实例。如果单例未注册，则返回NULL。
		 **/
		public function getInstance(name:*):*
		{
			name = adjustName(name);
			var proxy:Proxy = m_mapProxy[name];
			if(proxy)
			{
				if(!proxy.instance)
				{
					proxy.instance = new proxy.type;
				}
				
				return proxy.instance;
			}
			return null;
		}
		
		
		private function adjustName(name:*):String
		{
			if(name is Class)
			{
				name = ClassUtil.getFullName(name);
			}
			
			if(!(name is String))
			{
				name = String(name);
			}
			
			return name;
		}
		
		
		protected function handleSingletonError(singletonName:String):void
		{
			throw Error("The Singleton [" + singletonName + "]'s Instance Has Existed!");
		}
	}
}
import slicol.foundation.singleton.SingletonFactory;

class Proxy
{
	public var factory:SingletonFactory;
	public var type:Class;
	public var instance:*;
}