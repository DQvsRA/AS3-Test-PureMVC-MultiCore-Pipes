/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.shell.view.modules
{
	import app.modules.CircleMakerModule;
	import app.modules.circlemaker.CircleMakerFacade;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	/**
	 * Mediator for the PrattlerModule.
	 * <P>
	 * Instantiates and manages the LoggerModule for the application.</P>
	 * <P>
	 * Listens for Notifications to connect things to the 
	 * LoggerModule, which implements IPipeAware, an interface that
	 * requires methods for accepting input and output pipes.</P>
	 */
	public class CircleMakerModuleMediator extends Mediator
	{
		public static const NAME:String = 'CircleMakerModuleMediator';
		
		public function CircleMakerModuleMediator( viewComponent:CircleMakerModule )
		{
			super( viewComponent.getID(), viewComponent);
		}
		
		/**
		 * Called when the Mediator is succesfully registered.
		 * <P>
		 * Here we want to request via a method call on our
		 * view component that it export its feed window,
		 * which it will do by sending a message to its
		 * STDSHELL output pipe.</P>
		 */ 
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
		
		/**
		 * Handle PrattlerModule related Notifications.
		 * </P>
		 * Remove the application-level references to the module instance.
		 * Note that the module itself will also be listening for the 
		 * window close and will do it's own internal cleanup to ensure
		 * that the instance can be garbage collected.</P>
		 */
		override public function handleNotification( note:INotification ):void
		{
			switch( note.getName() )
			{
				
			}
		}
		
		private function get circleMakerModule():CircleMakerModule
		{
			return viewComponent as CircleMakerModule;
		}
		
	
	}
}