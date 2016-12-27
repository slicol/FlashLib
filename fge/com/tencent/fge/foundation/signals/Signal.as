package com.tencent.fge.foundation.signals
{
	import com.tencent.fge.utils.AsyInvoke;
	
	import flash.utils.getQualifiedClassName;

	public class Signal implements ISignal
	{
		protected var m_valueClasses:Array;
		protected var m_lstSlot:Vector.<Function> = new Vector.<Function>;
		protected var m_lstSlotOnce:Vector.<Function> = new Vector.<Function>;
		
		public function Signal(...valueClasses)
		{
			m_valueClasses = (valueClasses.length == 1 && valueClasses[0] is Array) ? valueClasses[0] : valueClasses;
			
			for (var i:int = m_valueClasses.length; i--; )
			{
				if (!(m_valueClasses[i] is Class))
				{
					throw new ArgumentError('无效的 valueClasses 参数: ' +
						'第 ' + i + ' 个参数应该是一个Class, 而不应该是:<' +
						m_valueClasses[i] + '>.' + getQualifiedClassName(m_valueClasses[i]));
				}
			}
		}


		public function get numListeners():uint { return m_lstSlot.length; }
		
		
		public function addOnce(listener:Function):void
		{
			var i:int = m_lstSlotOnce.indexOf(listener);
			if(i < 0)
			{
				m_lstSlotOnce.push(listener);
			}
		}

		public function add(listener:Function):void
		{
			var i:int = m_lstSlot.indexOf(listener);
			if(i < 0)
			{
				m_lstSlot.push(listener);
			}
		}
		

		public function remove(listener:Function):void
		{
			var i:int = m_lstSlot.indexOf(listener);
			if(i >= 0)
			{
				m_lstSlot.splice(i, 1);
			}
			
			i = m_lstSlotOnce.indexOf(listener);
			if(i >= 0)
			{
				m_lstSlotOnce.splice(i, 1);
			}
			
		}
		

		public function removeAll():void
		{
			m_lstSlot.length = 0;
			m_lstSlotOnce.length = 0;
		}

		
		public function dispatchAsy(...ValueObjects):void
		{
			var asy:AsyInvoke = new AsyInvoke(dispatchWorker, ValueObjects);
			asy.execute();
		}
		
		
		public function dispatch(...valueObjects):void
		{
			dispatchWorker(valueObjects);
		}

		private function dispatchWorker(valueObjects:Array):void
		{
			
			var numValueClasses:int = m_valueClasses.length;
			var numValueObjects:int = valueObjects.length;
			
			if (numValueObjects < numValueClasses)
			{
				throw new ArgumentError('不正确的参数个数： ' +
					'应该至少有 '+numValueClasses+' 个参数，但只收到'+
					numValueObjects+'个.');
			}
			
			
			for (var i:int = 0; i < numValueClasses; i++)
			{
				if (valueObjects[i] is m_valueClasses[i] || valueObjects[i] === null) 
				{
					continue;
				}
				else
				{
					throw new ArgumentError('参数类型错误： object <'+valueObjects[i]
						+'> is not an instance of <'+m_valueClasses[i]+'>.');
				}
			}
			

			var copy:Vector.<Function> = m_lstSlot.concat();
			var j:int = 0;
			
			for(j = 0; j < copy.length; ++j)
			{
				execute(copy[j], valueObjects);
			}
			
			
			copy = m_lstSlotOnce.concat();
			m_lstSlotOnce.length = 0;
			
			for(j = 0; j < copy.length; ++j)
			{
				execute(copy[j], valueObjects);
			}
			
			
		}
		
		
		private function execute(listener:Function, valueObjects:Array):void
		{
			var numValueObjects:int = valueObjects.length;
			if (numValueObjects == 0)
			{
				listener();
			}
			else if (numValueObjects == 1)
			{
				listener(valueObjects[0]);
			}
			else if (numValueObjects == 2)
			{
				listener(valueObjects[0], valueObjects[1]);
			}
			else if (numValueObjects == 3)
			{
				listener(valueObjects[0], valueObjects[1], valueObjects[2]);
			}
			else
			{
				listener.apply(null, valueObjects);
			}
		}

	}
}