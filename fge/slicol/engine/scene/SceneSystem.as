package slicol.engine.scene
{

	import flash.utils.getTimer;
	
	import slicol.engine.Engine;
	import slicol.engine.object.GameObject;
	import slicol.engine.phys.PhysWorld;
	import slicol.engine.slicol_engine_internal;
	import slicol.foundation.singleton.SingletonFactory;
	
	import starling.core.RenderSupport;
	import starling.display.Sprite;
	
	use namespace slicol_engine_internal;

	public class SceneSystem extends Sprite
	{
		public static function get me():SceneSystem
		{
			return SingletonFactory.getInstance(SceneSystem);		
		}
		
		//-----------------------------------------------------------------
		private var m_scene:GameScene;
		private var m_phys:PhysWorld;
		
		private var m_sceneTime:int = 0;
		private var m_deltaTime:int = 0;
		private var m_playing:Boolean = false;
		
		
		
		public function get currentScene():GameScene{return m_scene;}
		
		
		//-----------------------------------------------------------------
		//-----------------------------------------------------------------
		
		public function SceneSystem()
		{
		}
		
		slicol_engine_internal function init(root:Sprite):void
		{
			root.addChild(this);
			
			m_phys = PhysWorld.me;
			m_phys.init(this);
		}
		
		
		public function start(clsScene:Class):void
		{
			m_scene = new clsScene;
			m_scene.load();
			m_scene.onLoadComplete.add(onSceneLoadComplete);
			
			m_playing = false;
		}
		
		public function stop():void
		{
			m_playing = false;
			
			if(m_scene)
			{
				m_scene.dispose();
				m_scene = null;
			}
		}
		
		
		private function onSceneLoadComplete():void
		{
			this.addChild(m_scene);
			
			m_scene.start();
			
			m_playing = true;
			
			m_sceneTime = getTimer();
			m_deltaTime = Engine.deltaTime;
		}
		
		
		
		slicol_engine_internal function update():void
		{
			if(!m_playing)
			{
				return;
			}
			
			//var dt:int = getTimer() - m_sceneTime;
			//if(dt >= m_deltaTime)
			{
				m_phys.update();
				m_scene.fixedUpdate();//phys->gameobject
				//m_sceneTime += m_deltaTime;
			}
			
			
			m_scene.update();
			m_scene.lateUpdate();//gameobject->phys
			
		}
		

		
		public function pause():void
		{
			m_playing = false;
		}
		
		public function resume():void
		{
			m_playing = true;
			
			m_sceneTime = getTimer();
			m_deltaTime = Engine.deltaTime;
		}
		
		

			
	}
}