package slicol.engine.ui
{
	import com.tencent.fge.utils.ClassUtil;
	
	import flash.utils.Dictionary;
	
	import starling.display.Sprite;
	

	public class UISprite extends Sprite
	{
		private static var m_mapTypeCount:Dictionary = new Dictionary;
		
		private var m_type:String = "";
		private var m_id:String = "";
		
		public var z:Number = 0;
		
		public function get type():String{return m_type;}
		public function get id():String{return m_id;}
		
		public function UISprite(type:String = "", id:String = "", z:Number = 0)
		{
			m_type = type;
			this.z = z;
			
			if(!m_type)
			{
				m_type = ClassUtil.getName(this);
			}
			
			m_id = id;
			if(!m_id)
			{
				var cnt:int = m_mapTypeCount[m_type];
				cnt++;
				m_id = m_type + "#" + cnt;
				m_mapTypeCount[m_type] = cnt;
			}
			
		}
		

		public function show():void
		{
			this.visible = true;
		}
		
		public function hide():void
		{
			this.visible = false;
		}
		
		public function update():void
		{
			
		}
		
		//------------------------------------------------------------------------------
		
		//更新层叠关系
		internal static function updateHierarchy(lst:*):void
		{
			lst.sort(_compareZ);
			
			for(var i:int = lst.length - 1; i >= 0; --i)
			{
				var sprite:UISprite = lst[i];
				sprite.parent.setChildIndex(sprite, i); 
			}
		}
		
		private static function _compareZ(a:UISprite, b:UISprite):Number
		{
			return a.z - b.z;
		}
		
		
	}
}