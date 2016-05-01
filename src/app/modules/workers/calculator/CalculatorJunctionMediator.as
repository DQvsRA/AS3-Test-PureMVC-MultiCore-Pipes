
package app.modules.workers.calculator
{
	import app.common.PipeAwareModule;
	import app.common.worker.WorkerJunction;
	import app.common.worker.WorkerJunctionMediator;
	import app.common.worker.WorkerRequestMessage;
	import app.common.worker.WorkerResponceMessage;
	import app.modules.CalculatorModule;
	import app.modules.workers.calculator.model.CalculatorProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	
	public class CalculatorJunctionMediator extends WorkerJunctionMediator
	{
		public static const NAME:String = 'CalculatorJunctionMediator';

		public function CalculatorJunctionMediator( workerJunction:Object )
		{
			super( NAME, WorkerJunction(workerJunction) );
		}
		
		override public function onRegister():void
		{
			super.onRegister();
		}
		
		override public function listNotificationInterests():Array
		{
			const interests:Array = super.listNotificationInterests();
			interests.push(CalculatorFacade.SEND_RESULT_MAIN_COLOR);
			interests.push(CalculatorFacade.SEND_RESULT_CIRCLE_BUTTON);
			interests.push(CalculatorFacade.SEND_RESULT_LOG_SIZE);
			return interests;
		}
	
		override public function handleNotification( note:INotification ):void
		{
			trace("\n> WorkerJunctionMediator.handleNotification :", note.getName(), note.getType());
			const type:String = note.getType();
			var sendResponce:Boolean = false;
			switch( note.getName() )
			{
				case CalculatorFacade.SEND_RESULT_MAIN_COLOR:
//					trace("> \t\t : SEND_RESULT_MAIN_COLOR");
				case CalculatorFacade.SEND_RESULT_LOG_SIZE:
//					trace("> \t\t : SEND_RESULT_LOG_SIZE");
				case CalculatorFacade.SEND_RESULT_CIRCLE_BUTTON:
//					trace("> \t\t : SEND_RESULT_CIRCLE_BUTTON");
					sendResponce = true;
				break;
				// And let super handle the rest (ACCEPT_OUTPUT_PIPE)								
				default:
					super.handleNotification(note);
			}
			if(sendResponce) junction.sendMessage(PipeAwareModule.WRKOUT, new WorkerResponceMessage(note.getType(), note.getBody()));
		}
		
		/**
		 * Handle incoming pipe messages.
		 */
		override public function handlePipeMessage( message:IPipeMessage ):void
		{
			trace("WorkerJunctionMediator.handlePipeMessage:", JSON.stringify(message));
			
			if(message is WorkerRequestMessage) {
				
				const workerMessage:WorkerRequestMessage = message as WorkerRequestMessage
				const request:String = workerMessage.request;
				var commandToExecute:String;
				switch(request)
				{
					case CalculatorModule.CALCULATE_LOG_SIZE: 		commandToExecute = CalculatorFacade.CMD_CALCULATE_LOG_SIZE; break;	
					case CalculatorModule.CALCULATE_MAIN_COLOR: 	commandToExecute = CalculatorFacade.CMD_CALCULATE_MAIN_COLOR; break;
					case CalculatorModule.CALCULATE_CIRCLE_BUTTON: 	commandToExecute = CalculatorFacade.CMD_CALCULATE_CIRCLE_BUTTON; break;
				}
				if(commandToExecute) {
					const calculatorProxy:CalculatorProxy = facade.retrieveProxy(CalculatorProxy.NAME) as CalculatorProxy;
					calculatorProxy.callHappend();
					sendNotification(commandToExecute, workerMessage.data, workerMessage.responce)
				}
			}
		}
	}
}