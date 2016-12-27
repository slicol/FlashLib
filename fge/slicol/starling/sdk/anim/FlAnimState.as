package slicol.starling.sdk.anim
{
	import slicol.starling.sdk.core.FlMovieClip;
	import slicol.starling.sdk.fsm.FSM;
	import slicol.starling.sdk.fsm.FSMState;
	import slicol.starling.sdk.fsm.FSMValue;
	
	public class FlAnimState extends FSMState
	{
		private var m_motion:String = "";
		private var m_bLoop:Boolean = true;
		private var m_mirror:Boolean = false;
		
		private var m_animator:FlAnimator;
		private var m_animation:FlMovieClip;
		
		public function FlAnimState(fsm:FSM, xml:XML, animator:FlAnimator)
		{
			super(fsm, xml);
			
			m_animator = animator;
			
			this.propertys.checkValue("motion", FSMValue.TYPE_String);
			this.propertys.checkValue("loop",  FSMValue.TYPE_Bool,"true");
			this.propertys.checkValue("mirror", FSMValue.TYPE_Bool,"false");
		}
		
		/*
		override public function get validXML():XML
		{
			this.propertys.setValue("motion", m_motion, FSMValue.TYPE_String);
			this.propertys.setValue("loop", m_bLoop.toString(), FSMValue.TYPE_Bool);
			this.propertys.setValue("mirror", m_mirror.toString(), FSMValue.TYPE_Bool);
			
			return super.validXML;
		}
		*/

		override public function enter():void
		{
			m_progress = 0;
			
			m_motion = this.propertys.getValue("motion");
			m_bLoop = this.propertys.getValue("loop") == "true";
			m_mirror = this.propertys.getValue("mirror") == "true";
			
			m_animation = m_animator.play(m_motion, m_bLoop);
			if(m_animation)
			{
				m_animation.scaleX = m_mirror?-1:1;
			}
			
		}
		
		override public function leave():void
		{
			super.leave();
			m_animator.stop(m_motion);
			m_animation = null;
		}
		
		
		override public function update():void
		{
			if(m_animation && m_animation.numFrames > 0)
			{
				m_progress = m_animation.currentTime/ m_animation.totalTime;
			}
		}
	}
}