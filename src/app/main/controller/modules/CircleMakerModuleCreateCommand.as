package app.main.controller.modules
{
	import app.modules.CircleMakerModule;
	import app.main.MainFacade;
	import app.main.view.modules.CircleMakerModuleMediator;
    import org.puremvc.as3.multicore.interfaces.ICommand;
    import org.puremvc.as3.multicore.interfaces.INotification;
    import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CircleMakerModuleCreateCommand extends SimpleCommand implements ICommand
    {
        override public function execute(note:INotification):void
        {
			trace("\n> CircleMaker : ModuleCreateCommand");
			var circleMaker:CircleMakerModule = new CircleMakerModule();
   			sendNotification(MainFacade.CONNECT_MODULE_TO_LOGGER, 	circleMaker );
   			sendNotification(MainFacade.CONNECT_MODULE_TO_MAIN, 	circleMaker );
   			sendNotification(MainFacade.CONNECT_MODULE_TO_WORKER, 	circleMaker );
       		facade.registerMediator( new CircleMakerModuleMediator( circleMaker ) );
		}
    }
}