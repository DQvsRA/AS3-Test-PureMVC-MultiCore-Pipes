package app.main.controller
{
	import app.main.MainFacade;
	import app.main.view.modules.CircleButtonModuleMediator;
	import app.modules.CircleButtonModule;
	import app.common.worker.WorkerModule;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateCircleButtonModuleCommand extends SimpleCommand implements ICommand
    {
        override public function execute(note:INotification):void
        {
//			trace("\n> CircleMaker : ModuleCreateCommand");
			const circleMaker:CircleButtonModule = new CircleButtonModule();
   			sendNotification(MainFacade.CONNECT_MODULE_TO_LOGGER, 	circleMaker );
   			sendNotification(MainFacade.CONNECT_MODULE_TO_MAIN, 	circleMaker );
   			sendNotification(WorkerModule.CONNECT_MODULE_TO_WORKER, circleMaker );
       		facade.registerMediator( new CircleButtonModuleMediator( circleMaker ) );
		}
    }
}