/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.main.view.modules
{
	import app.common.PipeAwareModule;
	import app.modules.LoggerModule;
	import app.main.MainFacade;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	
	/**
	 * Mediator for the LoggerModule.
	 * <P>
	 * Instantiates and manages the LoggerModule for the application.</P>
	 * <P>
	 * Listens for Notifications to connect things to the 
	 * LoggerModule, which implements IPipeAware, an interface that
	 * requires methods for accepting input and output pipes.</P>
	 */
	public class LoggerModuleMediator extends Mediator
	{
		public static const NAME:String = 'LoggerModuleMediator';
		
		public function LoggerModuleMediator( )
		{
			super( NAME, new LoggerModule() );
		}

		override public function onRegister():void
		{
//			sendNotification( MainFacade.CONNECT_MODULE_TO_WORKER, logger );
		}
		
		override public function listNotificationInterests():Array
		{
			return [ 
				MainFacade.CONNECT_MODULE_TO_LOGGER,
				MainFacade.CONNECT_MAIN_TO_LOGGER
			];
		}
		
		override public function handleNotification( note:INotification ):void
		{
			switch( note.getName() )
			{
				// Connect any Module's STDLOG to the logger's STDIN
				case  MainFacade.CONNECT_MODULE_TO_LOGGER:
					
					const pipe:Pipe = new Pipe();
					const module:IPipeAware = note.getBody() as IPipeAware;
					module.acceptOutputPipe( PipeAwareModule.STDLOG, pipe );
					logger.acceptInputPipe( PipeAwareModule.STDIN, pipe );
					
					break;

				// Bidirectionally connect shell and logger on STDLOG/STDSHELL
				case  MainFacade.CONNECT_MAIN_TO_LOGGER:
					trace("> LoggerModuleMediator : MainFacade.CONNECT_MAIN_TO_LOGGER");
					// The junction was passed from ShellJunctionMediator
					var junction:Junction = note.getBody() as Junction;
					// Connect the shell's STDLOG to the logger's STDIN
					var shellToLog:IPipeFitting = junction.retrievePipe(PipeAwareModule.STDLOG);
					logger.acceptInputPipe(PipeAwareModule.STDIN, shellToLog);
					// Connect the logger's STDSHELL to the shell's STDIN
					var logToShell:Pipe = new Pipe();
					var shellIn:TeeMerge = junction.retrievePipe(PipeAwareModule.STDIN) as TeeMerge;
					shellIn.connectInput(logToShell);
					logger.acceptOutputPipe( PipeAwareModule.STDMAIN, logToShell );
					break;
			}
		}
		
		/**
		 * The Logger Module.
		 */
		private function get logger():LoggerModule
		{
			return viewComponent as LoggerModule;
		}
	}
}