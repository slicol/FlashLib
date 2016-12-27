package com.tencent.fge.engine.bpe
{
	public class BpeGroup extends BpeAbstractCollection 
	{
		private var m_composites:Array;
		private var m_collisionList:Array;
		private var m_collideInternal:Boolean;
		
		public function BpeGroup(collideInternal:Boolean = false) 
		{
			m_composites = new Array();
			m_collisionList = new Array();
			this.collideInternal = collideInternal;
		}
		
		public override function initialize():void 
		{
			super.initialize();
			for (var i:int = 0; i < composites.length; i++) 
			{
				composites[i].initialize();	
			}
		}
		
		
		//----------------------------------------------------
		
		public function get composites():Array 
		{
			return m_composites;
		}
		
		public function addComposite(c:BpeComposite):void 
		{
			composites.push(c);
			c.isParented = true;
			if (isParented) c.initialize();
		}

		public function removeComposite(c:BpeComposite):void
		{
			var cpos:int = composites.indexOf(c);
			if (cpos == -1) return;
			composites.splice(cpos, 1);
			c.isParented = false;
			c.cleanup();
		}
		
		//----------------------------------------------------
		
		public override function paint():void 
		{
			super.paint();
			
			var len:int = m_composites.length;
			for (var i:int = 0; i < len; i++) 
			{
				var c:BpeComposite = m_composites[i];
				c.paint();
			}						
		}
		
		
		public function addCollidable(g:BpeGroup):void 
		{
			collisionList.push(g);
		}
		
		public function removeCollidable(g:BpeGroup):void 
		{
			var pos:int = collisionList.indexOf(g);
			if (pos == -1) return;
			collisionList.splice(pos, 1);
		}
		
		
		public function addCollidableList(list:Array):void 
		{
			for (var i:int = 0; i < list.length; i++) 
			{
				var g:BpeGroup = list[i];
				collisionList.push(g);
			}
		}
		
		public function get collisionList():Array 
		{
			return m_collisionList;
		}	
		
		public override function getAllChildren():Array 
		{
			return particles.concat(constraints).concat(composites);
		}	
		
		public function get collideInternal():Boolean 
		{
			return m_collideInternal;
		}
		
		public function set collideInternal(b:Boolean):void 
		{
			m_collideInternal = b;
		}
		
		public override function cleanup():void 
		{
			super.cleanup();
			for (var i:int = 0; i < composites.length; i++) 
			{
				composites[i].cleanup();	
			}
		}
		
		internal override function integrate(dt:Number, dt2:Number):void 
		{
			super.integrate(dt,dt2);
			
			var len:int = m_composites.length;
			for (var i:int = 0; i < len; i++) 
			{
				var cmp:BpeComposite = m_composites[i];
				cmp.integrate(dt,dt2);
			}						
		}
		
		
		internal function checkCollisions():void 
		{
			
			if (collideInternal) checkCollisionGroupInternal();
			
			var len:int = collisionList.length;
			for (var i:int = 0; i < len; i++) 
			{
				var g:BpeGroup = collisionList[i];
				checkCollisionVsGroup(g);
			}
		}
		
		
		private function checkCollisionGroupInternal():void 
		{
			checkInternalCollisions();
			
			var clen:int = m_composites.length;
			for (var j:int = 0; j < clen; j++) 
			{
				var ca:BpeComposite = m_composites[j];
				
				ca.checkCollisionsVsCollection(this);
				
				for (var i:int = j + 1; i < clen; i++) 
				{
					var cb:BpeComposite = m_composites[i];
					ca.checkCollisionsVsCollection(cb);
				}
			}
		}
		
		
		private function checkCollisionVsGroup(g:BpeGroup):void 
		{
			checkCollisionsVsCollection(g);
			
			var clen:int = m_composites.length;
			var gclen:int = g.composites.length;
			
			for (var i:int = 0; i < clen; i++) 
			{
				var c:BpeComposite = m_composites[i];
				c.checkCollisionsVsCollection(g);
				
				for (var j:int = 0; j < gclen; j++) 
				{
					var gc:BpeComposite = g.composites[j];
					c.checkCollisionsVsCollection(gc);
				}
			}

			for (j = 0; j < gclen; j++) 
			{
				gc = g.composites[j];	
				checkCollisionsVsCollection(gc);
			}
		}
	}
}