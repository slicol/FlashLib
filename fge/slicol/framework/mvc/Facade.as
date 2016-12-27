package slicol.framework.mvc
{
	import flash.display.Sprite;
	
	import slicol.foundation.singleton.SingletonFactory;
	
	public class Facade
	{
		public function Facade()
		{
			SingletonFactory.regSingleton(this, true);
			
			initializeFacade();
		}
		
		protected function initializeFacade():void
		{
			initializeController();
			initializeModel();
			initializeView();
		}
		
		protected function initializeController():void
		{
			
		}
		
		protected function initializeModel():void
		{
			
		}
		
		protected function initializeView():void
		{
			
		}
	}
}