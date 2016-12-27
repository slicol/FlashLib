package slicol.starling.sdk.anim
{
	import flash.utils.Dictionary;
	
	import slicol.starling.sdk.core.FlLibrary;
	import slicol.starling.sdk.core.FlMovieClip;
	import slicol.starling.sdk.fsm.FSM;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class FlAnimator extends Sprite
	{
		private var m_lib:FlLibrary;
		private var m_fsm:FSM;
		private var m_current:FlMovieClip;
		private var m_mapMotion:Dictionary = new Dictionary;
		
		public function get fsm():FSM{return m_fsm;}
		public function get current():FlMovieClip{return m_current;}
		
		public function FlAnimator(xml:XML, lib:FlLibrary)
		{
			super();
			
			m_lib = lib;
			m_fsm = new FSM(FlAnimState, xml, this);
			
			FlLibrary.regItemClass(FlAnimation);
			
			this.addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		override public function dispose():void
		{
			this.removeEventListener(Event.ENTER_FRAME, onFrame);
			m_current = null;
			super.dispose();
		}
		
		
		private function onFrame(e:Event):void
		{
			m_fsm.update();
		}
		
		public function setCurrentState(name:String):void
		{
			m_fsm.setCurrentState(name);
		}
		
		public function setParam(name:String, value:String):void
		{
			m_fsm.setParam(name, value);
		}
		
		public function getParam(name:String):String
		{
			return m_fsm.getParam(name);
		}
		
		public function play(motion:String, bLoop:Boolean = true):FlMovieClip
		{
			var ani:FlMovieClip = m_mapMotion[motion];
			if(!ani && m_lib)
			{
				ani = m_lib.createItem(motion) as FlMovieClip;
				m_mapMotion[motion] = ani;
				
			}
			
			if(ani)
			{
				this.addChild(ani);
				ani.play(bLoop);
				ani.currentFrame = 0;
				m_current = ani;
			}
			return ani;
		}
		
		public function stop(motion:String):void
		{
			var ani:FlMovieClip = m_mapMotion[motion];
			if(ani)
			{
				ani.removeFromParent();
				
				if(m_current == ani)
				{
					m_current = null;
				}
			}
		}
		
	}
}