package app.modules.worker.controller.commands
{
	import app.modules.worker.WorkerFacade;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public final class CalculateLogSizeCommand extends SimpleCommand implements ICommand
	{
		override public function execute(note:INotification):void {
			var logFontSize:uint = 12;
			const responce:String = note.getType();
			trace("CalculateLogSizeCommand", responce);
			sendNotification(WorkerFacade.SEND_RESULT_LOG_SIZE, logFontSize, responce);
		}
	}
}