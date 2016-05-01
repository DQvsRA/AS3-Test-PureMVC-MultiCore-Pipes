/**
 * ...
 * @author Vladimir Minkin
 */

package app.modules.workers.calculator.controller 
{
	import app.common.worker.WorkerStartupCommand;
	import app.modules.workers.calculator.CalculatorFacade;
	import app.modules.workers.calculator.CalculatorJunctionMediator;
	import app.modules.workers.calculator.controller.commands.CalculateCircleButtonCommand;
	import app.modules.workers.calculator.controller.commands.CalculateLogSizeCommand;
	import app.modules.workers.calculator.controller.commands.CalculateMainColorCommand;
	import app.modules.workers.calculator.model.CalculatorProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	
	public class CalculatorStartupCommand extends WorkerStartupCommand
	{
		override public function execute( note:INotification ):void 
		{
			super.execute( note );
			
			trace("> CalculatorStartupCommand", !isMaster || !isSupported);
			
			// Run only on worker or when it's not supported
			if(!isMaster || !isSupported) 
			{
				facade.registerCommand( CalculatorFacade.CMD_CALCULATE_MAIN_COLOR, 		CalculateMainColorCommand );
				facade.registerCommand( CalculatorFacade.CMD_CALCULATE_CIRCLE_BUTTON,	CalculateCircleButtonCommand );
				facade.registerCommand( CalculatorFacade.CMD_CALCULATE_LOG_SIZE,		CalculateLogSizeCommand );
			
				facade.registerProxy(new CalculatorProxy());
			}
			
			// Register pipes for communicate with the module
			facade.registerMediator(new CalculatorJunctionMediator(note.getBody()));
		}
	}
}