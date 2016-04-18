/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.shell.controller.modules
{
	import app.modules.CircleMakerModule;
	import app.shell.MainFacade;
	import app.shell.view.modules.CircleMakerModuleMediator;
    import org.puremvc.as3.multicore.interfaces.ICommand;
    import org.puremvc.as3.multicore.interfaces.INotification;
    import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * Create a new PrattlerModule.
	 * <P>
	 * The new module is instantiated, and connected via pipes to the 
	 * logger and the shell. Finally a Mediator is registered for it.</P>
	 */
    public class CircleMakerModuleCreateCommand extends SimpleCommand implements ICommand
    {
        override public function execute(note:INotification):void
        {
			trace("CircleMakerModuleCreateCommand");
			var circleMaker:CircleMakerModule = new CircleMakerModule();
   			sendNotification(MainFacade.CONNECT_MODULE_TO_LOGGER, circleMaker );
   			sendNotification(MainFacade.CONNECT_MODULE_TO_SHELL, circleMaker );
       		facade.registerMediator( new CircleMakerModuleMediator( circleMaker ) );
		}
    }
}