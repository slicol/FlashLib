package slicol.engine
{

	import slicol.engine.scene.SceneSystem;
	import slicol.engine.ui.UISystem;
	import slicol.foundation.singleton.SingletonFactory;
	
	import starling.display.Sprite;
	import starling.events.Event;

	
	use namespace slicol_engine_internal;
	
	public class Engine
	{
		public static function get me():Engine
		{
			return SingletonFactory.getInstance(Engine);		
		}
		
		//-----------------------------------------------------------------
		
		
		public static var deltaTime:int = 1000/60;
		
		private var m_stage:Sprite;
		private var m_sysScene:SceneSystem;
		private var m_sysUI:UISystem;

		
		
		
		public function Engine()
		{
		}
		
		public function init(stage:Sprite):void
		{
			m_stage = stage;
				
			m_sysScene = SceneSystem.me;
			m_sysUI = UISystem.me;
			
			m_sysScene.init(stage);
			m_sysUI.init(stage);
			
			
			m_stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);

		}

		private function onEnterFrame(e:Event):void
		{
			m_sysScene.update();
			m_sysUI.update();
		}

		
	
	}
}