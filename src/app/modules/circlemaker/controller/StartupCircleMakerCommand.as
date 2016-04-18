/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.modules.circlemaker.controller
{
	import app.modules.circlemaker.model.CircleMakerProxy;
	import app.modules.circlemaker.view.CircleMakerJunction;
	import app.modules.circlemaker.view.CircleMakerMediator;
	import app.modules.circlemaker.view.components.CircleButton;
    import org.puremvc.as3.multicore.interfaces.ICommand;
    import org.puremvc.as3.multicore.interfaces.INotification;
    import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * Startup the Logger Module.
	 * <P>
	 * Register's a new LoggerProxy to keep the log, and a 
	 * LoggerJunctionMediator which will mediate communications
	 * over the pipes of the LoggerJunction.</P>
	 */
    public class StartupCircleMakerCommand extends SimpleCommand implements ICommand
    {
        override public function execute(note:INotification):void
        {
        	// NOTE: There is no need to register an 
        	// ApplicationMediator with the reference to the 
        	// module that was passed in. This module extends 
        	// PipeAwareModule, which simply uses the Facade 
        	// to send Notifications to accept input pipes and 
        	// output pipes and therefore does not need a Mediator.
        	trace("StartupCircleMakerCommand");
       		facade.registerProxy( new CircleMakerProxy( ) );
       		facade.registerMediator( new CircleMakerJunction( ) );
       		facade.registerMediator( new CircleMakerMediator( new CircleButton() ) );
        }
        
    }
}