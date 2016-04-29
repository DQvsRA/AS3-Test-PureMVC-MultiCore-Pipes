
package app.modules.worker
{
	import app.common.worker.WorkerResponceMessage;
	import app.common.PipeAwareModule;
	import app.common.worker.WorkerRequestMessage;
	import app.common.worker.WorkerJunction;
	import app.modules.WorkerModule;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;
	
	public class WorkerJunctionMediator extends JunctionMediator
	{
		public static const NAME:String = 'WorkerJunctionMediator';

		public function WorkerJunctionMediator( workerJunction:WorkerJunction )
		{
			super( NAME, workerJunction );
		}

		override public function onRegister():void
		{
//			trace("> WorkerJunction : PipeAwareModule.WRKOUT =", junction.hasPipe(PipeAwareModule.WRKOUT))
			if (!junction.hasPipe(PipeAwareModule.WRKOUT)) {
				// The WRKOUT pipe from the worker to all modules or main
				junction.registerPipe( PipeAwareModule.WRKOUT, Junction.OUTPUT, new TeeSplit() );
			}
//			trace("> WorkerJunction : PipeAwareModule.WRKIN =", junction.hasPipe(PipeAwareModule.WRKIN))
			if(!junction.hasPipe(PipeAwareModule.WRKIN)) {
				// The WRKIN pipe to the worker from all modules
				junction.registerPipe( PipeAwareModule.WRKIN,  Junction.INPUT, new TeeMerge() );
				junction.addPipeListener(PipeAwareModule.WRKIN, this, handlePipeMessage);
			}
		}
		
		/**
		 * List Notification Interests.
		 * <P>
		 * Adds subclass interests to those of the JunctionMediator.</P>
		 */
		override public function listNotificationInterests():Array
		{
			var interests:Array = super.listNotificationInterests();
			interests.push(WorkerFacade.SEND_RESULT_MAIN_COLOR);
			interests.push(WorkerFacade.SEND_RESULT_CIRCLE_BUTTON);
			interests.push(WorkerFacade.SEND_RESULT_LOG_SIZE);
			return interests;
		}
	
		override public function handleNotification( note:INotification ):void
		{
			trace("\n> WorkerJunctionMediator.handleNotification : ", note.getName(), note.getType());
			const type:String = note.getType();
			switch( note.getName() )
			{
				case WorkerFacade.SEND_RESULT_MAIN_COLOR:
					trace("> \t\t : SEND_RESULT_MAIN_COLOR", junction.hasPipe(PipeAwareModule.WRKOUT));
					junction.sendMessage(PipeAwareModule.WRKOUT, new WorkerResponceMessage(note.getType(), note.getBody()));
					break;
				case WorkerFacade.SEND_RESULT_LOG_SIZE:
					trace("> \t\t : SEND_RESULT_LOG_SIZE", junction.hasPipe(PipeAwareModule.WRKOUT));
					junction.sendMessage(PipeAwareModule.WRKOUT, new WorkerResponceMessage(note.getType(), note.getBody()));
					break;
				case WorkerFacade.SEND_RESULT_CIRCLE_BUTTON:
					trace("> \t\t : SEND_RESULT_CIRCLE_BUTTON", junction.hasPipe(PipeAwareModule.WRKOUT));
					junction.sendMessage(PipeAwareModule.WRKOUT, new WorkerResponceMessage(note.getType(), note.getBody()));
					break;
				
				// Add an input pipe (special handling for WorkerModule) 
				case JunctionMediator.ACCEPT_INPUT_PIPE:
					// STDIN is a Merging Tee. Overriding super to handle this.
					trace("> \t\t : ACCEPT_INPUT_PIPE Type:", type);
					if (type == PipeAwareModule.WRKIN && junction.hasInputPipe(type)) {
						const pipeIn:IPipeFitting = note.getBody() as IPipeFitting;
						const teeIn:TeeMerge = junction.retrievePipe(type) as TeeMerge;
						trace("> \t\t : connectInput", teeIn, pipeIn);
						teeIn.connectInput(pipeIn);
					} 
					// Use super for any other input pipe
					else {
						super.handleNotification(note); 
					}
					break;
				case JunctionMediator.ACCEPT_OUTPUT_PIPE:
					trace("> \t\t : ACCEPT_OUTPUT_PIPE Type:", type);
					if (type == PipeAwareModule.WRKOUT && junction.hasOutputPipe(type)) {
						const pipeOut:IPipeFitting = note.getBody() as IPipeFitting;
						const teeOut:TeeSplit = junction.retrievePipe(type) as TeeSplit;
						trace("> \t\t : connect", teeOut, pipeOut);
						teeOut.connect(pipeOut);
					} 
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
			trace("\nWorkerJunctionMediator.handlePipeMessage : ", message.getType());
			
			if(message is WorkerRequestMessage) {
				
				const workerMessage:WorkerRequestMessage = message as WorkerRequestMessage
				var commandToExecute:String;
				switch(workerMessage.request)
				{
					case WorkerModule.CALCULATE_LOG_SIZE: 
					{
						commandToExecute = WorkerFacade.CMD_CALCULATE_LOG_SIZE; 
						break;	
					}
					case WorkerModule.CALCULATE_MAIN_COLOR:
					{
						commandToExecute = WorkerFacade.CMD_CALCULATE_MAIN_COLOR;
						break;
					}
					case WorkerModule.CALCULATE_CIRCLE_BUTTON:
					{
						commandToExecute = WorkerFacade.CMD_CALCULATE_CIRCLE_BUTTON;
						break;
					}	
				}
				if(commandToExecute) sendNotification(commandToExecute, workerMessage.data, workerMessage.responce)
			}
		}
	}
}