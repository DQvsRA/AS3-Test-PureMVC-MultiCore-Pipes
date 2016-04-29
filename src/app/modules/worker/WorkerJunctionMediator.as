
package app.modules.worker
{
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	
	import app.common.PipeAwareModule;
	import app.common.worker.WorkerJunction;
	import app.common.worker.WorkerRequestMessage;
	import app.common.worker.WorkerResponceMessage;
	import app.modules.WorkerModule;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Filter;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;
	
	public class WorkerJunctionMediator extends JunctionMediator
	{
		public static const NAME:String = 'WorkerJunctionMediator';

		public function WorkerJunctionMediator( workerJunction:WorkerJunction )
		{
			super( NAME, workerJunction );
		}

		public function get workerJunction():WorkerJunction {
			return junction as WorkerJunction;
		}
		
		override public function onRegister():void
		{
			const workerNotSupported:Boolean = !workerJunction.isSupported// || (WorkerDomain.isSupported && Worker.current.isPrimordial)
			
//			trace("> WorkerJunction : PipeAwareModule.WRKOUT =", junction.hasPipe(PipeAwareModule.WRKOUT))
			if (!junction.hasPipe(PipeAwareModule.WRKOUT)) {
				// The WRKOUT pipe from the worker to all modules or main
				const teeOut:TeeSplit = new TeeSplit();
				if(workerNotSupported) {
					const filter:Filter = new Filter( 
						WorkerJunction.FILTER_FOR_APPLY_RESPONCE_FUNCTION, null, 
						workerJunction.filter_ApplyResponceFunction as Function
					);
					teeOut.connect(filter);
				}
				junction.registerPipe( PipeAwareModule.WRKOUT, Junction.OUTPUT, teeOut );
			}

//			trace("> WorkerJunction : PipeAwareModule.WRKIN =", junction.hasPipe(PipeAwareModule.WRKIN))
			if(!junction.hasPipe(PipeAwareModule.WRKIN)) {
				// The WRKIN pipe to the worker from all modules
				const teeMerge:TeeMerge = new TeeMerge();
				const pipeListener:PipeListener = new PipeListener(this, handlePipeMessage);
				// This situation happend when no worker being accepted
				// Master already has PipeAwareModule.WRKIN it's only 
				if(workerNotSupported) 
				{
					const diconectFilter:Filter = new Filter(
						WorkerJunction.FILTER_FOR_DISCONNECT_MODULE, null, 
						workerJunction.filter_DisconnectModule
					);
					diconectFilter.connect(new PipeListener(this, handlePipeMessage));
					
					const responceFilter:Filter = new Filter( 
						WorkerJunction.FILTER_FOR_STORE_RESPONCE_FUNCTION, diconectFilter, 
						workerJunction.filter_KeepResponceFunction as Function
					);
					teeMerge.connect(responceFilter);
				} 
				else 
				{
					// This only happend on Worker because he do not need to know about filtering, this is done already in Master
					teeMerge.connect(pipeListener);
				}
				junction.registerPipe( PipeAwareModule.WRKIN,  Junction.INPUT, teeMerge );
			}
		}
		
		override public function listNotificationInterests():Array
		{
			const interests:Array = super.listNotificationInterests();
			interests.push(WorkerFacade.SEND_RESULT_MAIN_COLOR);
			interests.push(WorkerFacade.SEND_RESULT_CIRCLE_BUTTON);
			interests.push(WorkerFacade.SEND_RESULT_LOG_SIZE);
			return interests;
		}
	
		override public function handleNotification( note:INotification ):void
		{
//			trace("\n> WorkerJunctionMediator.handleNotification : ", note.getName(), note.getType());
			const type:String = note.getType();
			switch( note.getName() )
			{
				case WorkerFacade.SEND_RESULT_MAIN_COLOR:
//					trace("> \t\t : SEND_RESULT_MAIN_COLOR");
				break;	
				case WorkerFacade.SEND_RESULT_LOG_SIZE:
//					trace("> \t\t : SEND_RESULT_LOG_SIZE");
				break;	
				case WorkerFacade.SEND_RESULT_CIRCLE_BUTTON:
//					trace("> \t\t : SEND_RESULT_CIRCLE_BUTTON");
				break;
				// And let super handle the rest (ACCEPT_OUTPUT_PIPE)								
				default:
					super.handleNotification(note);
			}
			junction.sendMessage(PipeAwareModule.WRKOUT, new WorkerResponceMessage(note.getType(), note.getBody()));
		}
		
		/**
		 * Handle incoming pipe messages.
		 */
		override public function handlePipeMessage( message:IPipeMessage ):void
		{
			trace("\nWorkerJunctionMediator.handlePipeMessage:\n", JSON.stringify(message));
			
			if(message is WorkerRequestMessage) {
				
				const workerMessage:WorkerRequestMessage = message as WorkerRequestMessage
				const request:String = workerMessage.request;
				var commandToExecute:String;
				switch(request)
				{
					case WorkerModule.CALCULATE_LOG_SIZE: 		commandToExecute = WorkerFacade.CMD_CALCULATE_LOG_SIZE; break;	
					case WorkerModule.CALCULATE_MAIN_COLOR: 	commandToExecute = WorkerFacade.CMD_CALCULATE_MAIN_COLOR; break;
					case WorkerModule.CALCULATE_CIRCLE_BUTTON: 	commandToExecute = WorkerFacade.CMD_CALCULATE_CIRCLE_BUTTON; break;
				}
				if(commandToExecute) sendNotification(commandToExecute, workerMessage.data, workerMessage.responce)
			}
		}
	}
}