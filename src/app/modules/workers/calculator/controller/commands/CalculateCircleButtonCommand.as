/**
 * ...
 * @author Vladimir Minkin
 */

package app.modules.workers.calculator.controller.commands 
{
	import app.modules.workers.calculator.CalculatorFacade;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CalculateCircleButtonCommand extends SimpleCommand implements ICommand 
	{
		override public function execute( note:INotification ):void 
		{
//			trace("CalculateCircleButtonCommand", note.getType());
			const outputParameters:Object = {
				size		: Math.random() * 20 + 20,
				upColor 	: Math.random()*0xffffff, 
				overColor 	: Math.random()*0xffffff, 
				downColor 	: Math.random()*0xffffff
			};
			sendNotification(CalculatorFacade.SEND_RESULT_CIRCLE_BUTTON, outputParameters, note.getType());
		}
	}
}