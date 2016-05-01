package app.main.view.modules
{
	import app.modules.CircleButtonModule;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class CircleButtonModuleMediator extends Mediator
	{
		public static const NAME:String = 'CircleMakerModuleMediator';
		
		public function CircleButtonModuleMediator( viewComponent:CircleButtonModule )
		{
			super( viewComponent.getID(), viewComponent);
		}
		
		override public function onRegister():void
		{
			circleMakerModule.exportToMain();
		}
		
		/**
		 * PrattlerModule related Notification list.
		 */
		override public function listNotificationInterests():Array
		{
			return [ 
			
			];
		}
		
		override public function handleNotification( note:INotification ):void
		{
			switch( note.getName() )
			{
				
			}
		}
		
		private function get circleMakerModule():CircleButtonModule
		{
			return viewComponent as CircleButtonModule;
		}
		
	
	}
}