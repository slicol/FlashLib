package slicol.starling.ps.cfg
{
	public class RPSConfig
	{
		private var m_xml:XML;
		
		public function RPSConfig()
		{
		}
		
		public function setValue(xml:XML):void
		{
			m_xml = xml;
		}
		
		public function getValue():XML
		{
			return m_xml;
		}
		
		public function reset():void
		{
			m_xml = new XML(Template);
			delete m_xml.particleEmitterConfig;
		}
		
		public function setSubPSConfig(xml:XML):void
		{
			m_xml.appendChild(xml);
		}
		
		public function getSubPSConfigList():Vector.<PSConfigData>
		{
			if(!m_xml)
			{
				return new Vector.<PSConfigData>;
			}
			
			var xlSubPS:XMLList = m_xml.children();
			var data:PSConfigData;
			var lst:Vector.<PSConfigData> = new Vector.<PSConfigData>;
			for(var i:int = 0; i < xlSubPS.length(); ++i)
			{
				var xmlSubPS:XML = xlSubPS[i];
				data = new PSConfigData(xlSubPS[i]);
				lst.push(data);
			}
			return lst;
		}
		
		
		public static const Template:XML = 
			<rps>
				<particleEmitterConfig id="%id" type="%type" x="%x" y="%y" z="%z">
					<property value="600" min="1" max="1000" step="1" title="Total Particles"/>
				</particleEmitterConfig>
			</rps>
		
	}
}

