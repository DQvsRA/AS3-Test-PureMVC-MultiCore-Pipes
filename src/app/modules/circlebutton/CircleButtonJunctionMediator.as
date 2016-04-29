package app.modules.circlebutton
{
	import flash.display.DisplayObject;
	
	import app.common.LogMessage;
	import app.common.LoggingJunction;
	import app.common.PipeAwareModule;
	import app.common.UIQueryMessage;
	import app.common.worker.WorkerRequestMessage;
	import app.common.worker.WorkerResponceMessage;
	import app.modules.CircleMakerModule;
	import app.modules.WorkerModule;
	import app.modules.circlebutton.CircleButtonFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	
	public class CircleButtonJunctionMediator extends LoggingJunction
	{
		static public const NAME:String = 'CircleMakerJunctionMediator';
		
		public function CircleButtonJunctionMediator( )
		{
			super( NAME, new Junction() );
		}

		override public function onRegister():void
		{
			
		}
		
		/**
		 * List Notification Interests.
		 * <P>
		 * Adds subclass interests to those of the JunctionMediator.</P>
		 */
		override public function listNotificationInterests():Array
		{
			const interests:Array = super.listNotificationInterests();
			interests.push(CircleButtonFacade.EXPORT_CIRLE_BUTTON);
			interests.push(CircleButtonFacade.CLICK_COUNT_CHANGED);
			
			interests.push(CircleButtonFacade.ASK_FOR_CIRCLE_BUTTON_PARAMERTS);
			
			return interests;
		}

		override public function handleNotification( note:INotification ):void
		{
			trace("> CircleMaker : Junction.handleNotification:", note.getName(), note.getType());
			switch( note.getName() )
			{
				// Send the LogWindow UI Component 
				case CircleButtonFacade.CLICK_COUNT_CHANGED:
					trace("\t\tCLICK_COUNT_CHANGED:", note.getBody());
					const moduleKey		: String = note.getType();
					const clickCount	: int = int(note.getBody());
					sendNotification(LogMessage.SEND_TO_LOG, moduleKey + " - Circle Button clicked: " + clickCount + " times", LogMessage.LEVELS[LogMessage.INFO]);
					break;
				case CircleButtonFacade.EXPORT_CIRLE_BUTTON:
					trace("\t\tEXPORT_CIRLE_BUTTON:", note.getBody());
					const circleMakerMessage:UIQueryMessage = new UIQueryMessage( UIQueryMessage.SET, CircleMakerModule.MESSAGE_TO_MAIN_CIRCLE_MAKER_BUTTON, note.getBody() as DisplayObject );
					junction.sendMessage( PipeAwareModule.STDMAIN, circleMakerMessage );
					break;
				
				case CircleButtonFacade.ASK_FOR_CIRCLE_BUTTON_PARAMERTS:
					sendNotification(LogMessage.SEND_TO_LOG, "Circle Button request parameters from worker: " + this.multitonKey, LogMessage.LEVELS[LogMessage.INFO]);
					junction.sendMessage( PipeAwareModule.TOWRK, new WorkerRequestMessage( WorkerModule.CALCULATE_CIRCLE_BUTTON, null, CircleMakerModule.RECIEVE_CIRCLE_BUTTON_PARAMERTS ) );
					break;
				
				// And let super handle the rest (ACCEPT_OUTPUT_PIPE)								
				default:
					super.handleNotification(note);
			}
		}
		
		/**
		 * Handle incoming pipe messages.
		 */
		override public function handlePipeMessage( message:IPipeMessage ):void
		{
			trace("> CircleMaker : Junction.handlePipeMessage:\n", JSON.stringify(message) + "\n");
			if(message is WorkerResponceMessage) {
				switch(message.getType())
				{
					case CircleMakerModule.RECIEVE_CIRCLE_BUTTON_PARAMERTS:
					{
						DisconnectFromWorker();
						sendNotification(CircleButtonFacade.SETUP_CIRCLE_BUTTON_PARAMETERS, WorkerResponceMessage(message).data);
						break;
					}
				}
			}
		}
		
		private function DisconnectFromWorker():void
		{
			const workerInputPipe:IPipeFitting = junction.retrievePipe( PipeAwareModule.FROMWRK );
//			trace("workerInputPipe", workerInputPipe);
			if(workerInputPipe) {
				workerInputPipe.disconnect();
				junction.removePipe( PipeAwareModule.FROMWRK );
			}
			const workerOutputPipe:IPipeFitting = junction.retrievePipe( PipeAwareModule.TOWRK );
//			trace("workerOutputPipe", workerOutputPipe);
			if(workerOutputPipe) {
				workerOutputPipe.disconnect();
				junction.removePipe( PipeAwareModule.TOWRK );
			}
		}
	}
}