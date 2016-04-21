package app.modules.logger.controller 
{
	import app.modules.logger.view.components.LoggerView;
	import app.modules.logger.LoggerJunctionMediator;
	import app.modules.logger.view.LoggerMediator;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public final class LoggerStartupCommand extends SimpleCommand implements ICommand
	{
		//==================================================================================================	
		override public function execute(note:INotification):void {
		//==================================================================================================	
			facade.registerMediator(new LoggerMediator(new LoggerView()));
			facade.registerMediator(new LoggerJunctionMediator());
		}
	}
}