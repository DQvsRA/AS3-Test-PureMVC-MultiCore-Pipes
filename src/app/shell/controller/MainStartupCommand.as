/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.shell.controller
{
	import app.shell.MainFacade;
	import app.shell.view.MainJunction;
	import app.shell.view.MainMediator;
	import app.shell.view.modules.LoggerModuleMediator;
    import org.puremvc.as3.multicore.interfaces.ICommand;
    import org.puremvc.as3.multicore.interfaces.INotification;
    import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class MainStartupCommand extends SimpleCommand implements ICommand
    {
        override public function execute(note:INotification):void
        {
			// Create and Register the Logger Module and its Mediator
       		facade.registerMediator( new LoggerModuleMediator() );
			
			facade.removeCommand(MainFacade.STARTUP);
       		// Create and Register the Application and its Mediator
        	var app:Main = note.getBody() as Main;
			facade.registerMediator( new MainMediator(app) );
			// Create and Register the Shell Junction and its Mediator
			facade.registerMediator( new MainJunction() );
			// Request the Log UI from the Logger Module       		
			this.sendNotification( MainFacade.GET_MODULE_LOGGER );
        }
    }
}