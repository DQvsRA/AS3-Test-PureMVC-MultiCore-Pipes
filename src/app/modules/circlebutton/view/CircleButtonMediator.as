/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks - Prattler Module
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>

 Parts originally from: 
 PureMVC AS3 Demo – AIR RSS Headlines 
 Copyright (c) 2007-08 Simon Bailey <simon.bailey@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.modules.circlebutton.view
{
	import flash.events.MouseEvent;
	
	import app.modules.circlebutton.CircleButtonFacade;
	import app.modules.circlebutton.view.components.CircleButton;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class CircleButtonMediator extends Mediator
	{
		public static const NAME:String = "CircleButtonMediator";
		
		public function CircleButtonMediator( viewComponent:CircleButton )
		{
			super( NAME, viewComponent );
		}
		
		override public function onRegister():void
		{
			circleButton.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		//==================================================================================================
		private function onClick(e:MouseEvent):void {
		//==================================================================================================
			trace("\n");
			trace("CircleMakerMediator > onClick Handle");
			sendNotification(CircleButtonFacade.CIRCLE_BUTTON_CLICKED);
		}

		private function get circleButton():CircleButton
		{
			return viewComponent as CircleButton;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				CircleButtonFacade.GET_CIRCLE_BUTTON,
				CircleButtonFacade.SETUP_CIRCLE_BUTTON_PARAMETERS,
			];
		}

		override public function handleNotification( note:INotification ):void
		{
			switch ( note.getName() )
			{
				case CircleButtonFacade.GET_CIRCLE_BUTTON:
					sendNotification( CircleButtonFacade.ASK_FOR_CIRCLE_BUTTON_PARAMERTS );
					break;
				case CircleButtonFacade.SETUP_CIRCLE_BUTTON_PARAMETERS:
					circleButton.setupParameters(note.getBody());
					sendNotification( CircleButtonFacade.EXPORT_CIRLE_BUTTON, circleButton );
					break;
			}
		}
	}
}