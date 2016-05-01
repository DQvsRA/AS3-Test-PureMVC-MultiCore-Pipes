package app.main.controller
{
	import flash.events.EventDispatcher;
	
	import app.main.MainFacade;
	import app.main.view.MainJunctionMediator;
	import app.main.view.MainMediator;
	import app.main.view.modules.CalculatorModuleMediator;
	import app.main.view.modules.LoggerModuleMediator;
	import app.modules.CalculatorModule;
	
	import nest.services.worker.events.WorkerEvent;
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class MainStartupCommand extends SimpleCommand implements ICommand
    {
        override public function execute(note:INotification):void
        {
			facade.removeCommand(MainFacade.STARTUP);
			
			const app:Main = note.getBody() as Main;
			
			const calculatorWorkerModule:CalculatorModule = new CalculatorModule( app.loaderInfo.bytes );
			
			facade.registerMediator( new CalculatorModuleMediator(calculatorWorkerModule) );
			// Create and Register the Application and its Mediator
			facade.registerMediator( new MainMediator(app) );
			
			trace("> MainStartupCommand : workerModule.isSupported", calculatorWorkerModule.isSupported)
			
			if (calculatorWorkerModule.isSupported) 
				calculatorWorkerModule.addEventListener(WorkerEvent.READY, ContinueInitialize);
			else ContinueInitialize();
		}
		
		//==================================================================================================	
		private function ContinueInitialize(e:WorkerEvent = null):void {
		//==================================================================================================	
			trace("\n======================================\n> MainStartupCommand : ContinueInitialize", e);
			
			if (e) (e.currentTarget as EventDispatcher).removeEventListener(WorkerEvent.READY, ContinueInitialize);
			
			// Create and Register the Logger Module and its Mediator
			facade.registerMediator( new LoggerModuleMediator() );
			// Create and Register the Shell Junction and its Mediator
			facade.registerMediator( new MainJunctionMediator() );
		
			// Request the Log UI from the Logger Module   
			facade.sendNotification( MainFacade.GET_MODULE_LOGGER );
			facade.sendNotification( MainFacade.WORKER_GET_MAIN_COLOR );
		}
    }
}