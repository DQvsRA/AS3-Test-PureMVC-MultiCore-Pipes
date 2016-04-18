/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks - Prattler Module
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>

 Parts originally from: 
 PureMVC AS3 Demo – AIR RSS Headlines 
 Copyright (c) 2007-08 Simon Bailey <simon.bailey@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.modules.circlemaker.view
{
	import app.modules.circlemaker.CircleMakerFacade;
	import app.modules.circlemaker.view.components.CircleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class CircleMakerMediator extends Mediator
	{
		public static const NAME:String = "CircleButtonMediator";
		
		public function CircleMakerMediator( viewComponent:CircleButton )
		{
			super( NAME, viewComponent );
		}
		
		/**
		 * Register event listeners with the FeedWindow and its controls.
		 */
		override public function onRegister():void
		{
			circleButton.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		//==================================================================================================
		private function onClick(e:MouseEvent):void {
		//==================================================================================================
			trace("\n");
			trace("CircleMakerMediator > onClick Handle");
			sendNotification(CircleMakerFacade.CIRCLE_BUTTON_CLICKED);
		}
		
		/**
		 * The viewComponent cast to type FeedWindow.
		 */
		private function get circleButton():CircleButton
		{
			return viewComponent as CircleButton;
		}
		
		/**
		 * FeedWindow related Notification list.
		 */ 
		override public function listNotificationInterests():Array
		{
			return [
				CircleMakerFacade.GET_CIRCLE_BUTTON,
			];
		}
		
		/**
		 * Handle FeedWindow related Notifications.
		 * <P>
		 * Responds to Notifications from the Proxy containing
		 * feed data. 
		 * <P>
		 * Exports the FeedWindow when requested by sending
		 * a Notification with the FeedWindow as the body. 
		 * This will be captured by the PrattlerJunctionMediator
		 * which will send it to the shell via a pipe message.</P>
		 */
		override public function handleNotification( note:INotification ):void
		{
			switch ( note.getName() )
			{
				case CircleMakerFacade.GET_CIRCLE_BUTTON:
					sendNotification( CircleMakerFacade.EXPORT_CIRLE_BUTTON, circleButton );
					break;
			}
		}
	}
}