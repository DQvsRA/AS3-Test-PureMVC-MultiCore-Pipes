package app.modules.worker.controller.commands
{
	import app.modules.worker.WorkerFacade;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public final class CalculateMainColorCommand extends SimpleCommand implements ICommand
	{
		override public function execute(note:INotification):void {
//			trace("CalculateMainColorCommand", note.getType());
			sendNotification(
				WorkerFacade.SEND_RESULT_MAIN_COLOR, 
				uint(Math.random()*0xFFFFFF), 
				note.getType()
			);
		}
	}
}