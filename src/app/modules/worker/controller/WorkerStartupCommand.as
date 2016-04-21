/**
 * ...
 * @author Vladimir Minkin
 */

package app.modules.worker.controller 
{
	import app.common.worker.WorkerJunction;
	import app.modules.WorkerModule;
	import app.modules.worker.WorkerFacade;
	import app.modules.worker.WorkerJunctionMediator;
	import app.modules.worker.controller.commands.CalculateCircleButtonCommand;
	import app.modules.worker.controller.commands.CalculateMainColorCommand;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class WorkerStartupCommand extends SimpleCommand implements ICommand 
	{
		override public function execute( note:INotification ):void 
		{
			const workerModule		: WorkerModule = WorkerModule(note.getBody());
			const workerProcessor	: WorkerJunction = new WorkerJunction(workerModule);
			
			if(!workerModule.isMaster || !workerModule.isSupported) {
				facade.registerCommand(WorkerFacade.CMD_CALCULATE_MAIN_COLOR, 		CalculateMainColorCommand);
				facade.registerCommand(WorkerFacade.CMD_CALCULATE_CIRCLE_BUTTON,	CalculateCircleButtonCommand);
			}
			
			facade.registerMediator( new WorkerJunctionMediator(workerProcessor) );
		}
	}
}