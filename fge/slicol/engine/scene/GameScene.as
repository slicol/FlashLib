package slicol.engine.scene
{
	import com.tencent.fge.foundation.signals.Signal;
	
	import slicol.engine.object.GameObject;
	import slicol.engine.object.GameSprite;
	import slicol.engine.slicol_engine_internal;
	
	import starling.core.RenderSupport;
	import starling.display.Sprite;
	
	use namespace slicol_engine_internal;

	public class GameScene extends Sprite
	{
		private var m_lstGameSprite:Vector.<GameSprite> = new Vector.<GameSprite>;
		private var m_lstGameObject:Vector.<GameObject> = new Vector.<GameObject>;
		private var m_lstGameObjectNew:Vector.<GameObject> = new Vector.<GameObject>;
		
		private var m_loadComplete:Boolean = false;
		
		public var onLoadProgress:Signal = new Signal(Number);
		public var onLoadComplete:Signal = new Signal();
		

		//---------------------------------------------------------------
		
		public function GameScene()
		{
		}
		
		
		override public function dispose():void
		{
			this.onLoadComplete.removeAll();
			this.onLoadProgress.removeAll();
			
			for each(var obj:GameObject in m_lstGameObject)
			{
				obj.dispose();
			}
			m_lstGameObject.length = 0;
			
			super.dispose();
		}
		
		//---------------------------------------------------------------
		
		public function addGameObject(obj:GameObject):void
		{
			if(m_lstGameObject.indexOf(obj) < 0 && m_lstGameObjectNew.indexOf(obj) < 0)
			{
				m_lstGameObjectNew.push(obj);
				obj._awake();
			}
		}
		
		
		public function removeGameObject(obj:GameObject):void
		{
			var hasFound:Boolean = false;
			var i:int = m_lstGameObject.indexOf(obj);
			if(i >= 0)
			{
				hasFound = true;
				m_lstGameObject.splice(i,1);
			}
			else 
			{
				i = m_lstGameObjectNew.indexOf(obj);
				if(i >= 0)
				{
					hasFound = true;
					m_lstGameObjectNew.splice(i, 1);
				}
			}
			
			if(hasFound)
			{
				obj.dispose();
			}
		}
		
		
		public function addGameSprite(sprite:GameSprite):void
		{
			if(m_lstGameSprite.indexOf(sprite) < 0)
			{
				m_lstGameSprite.push(sprite);
				this.addChild(sprite);
				GameSprite.updateHierarchy(m_lstGameSprite);
			}
		}
		
		public function removeGameSprite(sprite:GameSprite):void
		{
			var i:int = m_lstGameSprite.indexOf(sprite);
			if(i >= 0)
			{
				m_lstGameSprite.splice(i,1);
				this.removeChild(sprite);
			}
		}
		
		//---------------------------------------------------------------
		
		public function load():void
		{
			//todo Loading
			this.onLoadComplete.dispatchAsy();
		}

		
		
		slicol_engine_internal function start():void
		{
			startNewGameObject();
		}
		
		private function startNewGameObject():void
		{
			if(m_lstGameObjectNew.length == 0)
			{
				return;
			}
			
			var lstTmp:Vector.<GameObject> = m_lstGameObjectNew.concat();
			m_lstGameObjectNew.length = 0;
			
			var obj:GameObject;

			for each(obj in lstTmp)
			{
				obj._start();
			}
			
			m_lstGameObject = m_lstGameObject.concat(lstTmp);
		}
		
		
		slicol_engine_internal function fixedUpdate():void
		{
			for each(var obj:GameObject in m_lstGameObject)
			{
				obj.fixedUpdate();
			}
		}
		
		slicol_engine_internal function update():void
		{
			for each(var obj:GameObject in m_lstGameObject)
			{
				obj.update();
			}
		}
		
		slicol_engine_internal function lateUpdate():void
		{
			for each(var obj:GameObject in m_lstGameObject)
			{
				obj.lateUpdate();
			}

			startNewGameObject();
		}
		
		//-----------------------------------------------------------------
		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			super.render(support, parentAlpha);
			
			for each(var obj:GameObject in m_lstGameObject)
			{
				obj.customRender(support, parentAlpha);
			}
		}
	}
}