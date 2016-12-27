package slicol.starling.ps.core
{
	import flash.utils.Dictionary;
	
	import slicol.starling.ps.cfg.PSConfigData;
	import slicol.starling.ps.cfg.RPSConfig;
	
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	
	public class RichParticleSystem extends Sprite implements IAnimatable
	{
		private var m_isEmitting:Boolean = true;
		private var m_cfg:RPSConfig = new RPSConfig();
		protected var m_lstSubPS:Vector.<ParticleSystemBase> = new Vector.<ParticleSystemBase>;
		
		public function RichParticleSystem()
		{
			super();
			
		}
		

		//-------------------------------------------------------------------------
		public function getSubPS(id:String):ParticleSystemBase
		{
			for(var i:int = 0; i < m_lstSubPS.length; ++i)
			{
				if(m_lstSubPS[i].id == id)
				{
					return m_lstSubPS[i];
				}
			}
			return null;
		}
		
		public function getSubPSList():Vector.<ParticleSystemBase>
		{
			return m_lstSubPS.concat();
		}
		
		
		public function addSubPS(ps:ParticleSystemBase):void
		{
			if(!ps)
			{
				return;
			}
			
			var i:int = m_lstSubPS.indexOf(ps);
			if(i < 0)
			{
				m_lstSubPS.push(ps);
				if(m_isEmitting)
				{
					ps.start();
				}
				else
				{
					ps.stop();
				}
				this.addChild(ps as DisplayObject);
			}
			
			m_lstSubPS.sort(compare);
			
			function compare(a:ParticleSystemBase, b:ParticleSystemBase):int
			{
				return a.z - b.z;
			}
			
			for(i = 0; i < m_lstSubPS.length; ++i)
			{
				ps = m_lstSubPS[i];
				this.addChildAt(ps as DisplayObject, i);
			}
			
		}
		
		public function addSubPSByConfig(type:String, cfg:XML):void
		{
			var ps:ParticleSystemBase = RPSFactory.me.createParticleSystem(type, cfg);
			if(ps)
			{
				this.addSubPS(ps);
			}
		}
		
		public function delSubPS(ps:ParticleSystemBase, dispose:Boolean = true):void
		{
			if(ps)
			{
				this.removeChild(ps as DisplayObject, dispose);
				var i:int = m_lstSubPS.indexOf(ps);
				m_lstSubPS.splice(i, 1);
			}
		}
		
		public function delSubPSById(id:String, dispose:Boolean = true):void
		{
			var ps:IParticleSystem = getSubPS(id);
			if(ps)
			{
				this.removeChild(ps as DisplayObject, dispose);
				var i:int = m_lstSubPS.indexOf(ps);
				m_lstSubPS.splice(i, 1);
			}
		}
		

		


		
		//-------------------------------------------------------------------------

		public function start(duration:Number=Number.MAX_VALUE):void
		{
			for(var i:int = 0; i < m_lstSubPS.length; ++i)
			{
				m_lstSubPS[i].start(duration);
			}
		}
		
		public function stop(bClearParticles:Boolean=false):void
		{
			for(var i:int = 0; i < m_lstSubPS.length; ++i)
			{
				m_lstSubPS[i].stop(bClearParticles);
			}
		}
		
		
		public function reset():void
		{
			m_lstSubPS.length = 0;
			this.removeChildren(0,-1,true);
		}
		
		
		//-------------------------------------------------------------------------

		
		public function getConfig():XML
		{
			m_cfg.reset();
			
			for(var i:int = 0; i < m_lstSubPS.length; ++i)
			{
				var ps:ParticleSystemBase = m_lstSubPS[i];
				if(ps)
				{
					m_cfg.setSubPSConfig(ps.getConfig());
				}
			}
			
			return m_cfg.getValue();
		}
		
		public function setConfig(xml:XML):void
		{
			reset();
			
			m_cfg.setValue(xml);
			
			var lst:Vector.<PSConfigData> = m_cfg.getSubPSConfigList();
			for(var i:int = 0; i < lst.length; ++i)
			{
				var ps:ParticleSystemBase = RPSFactory.me.createParticleSystem(lst[i].type, lst[i].xml);
				if(ps)
				{
					this.addSubPS(ps);
				}
			}
		}
		

		
		public function advanceTime(time:Number):void
		{
			for(var i:int = 0; i < m_lstSubPS.length; ++i)
			{
				m_lstSubPS[i].advanceTime(time);
			}
		}
		
		//-------------------------------------------------------------------------
		public function get numParticles():int
		{
			var num:int = 0;
			for(var i:int = 0; i < m_lstSubPS.length; ++i)
			{
				num += m_lstSubPS[i].numParticles;
			}
			return num;
		}
	}
}