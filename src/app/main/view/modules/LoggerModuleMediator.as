/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.main.view.modules
{
	import app.common.PipeAwareModule;
	import app.main.MainFacade;
	import app.modules.LoggerModule;
	import app.common.worker.WorkerModule;
	
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
			facade.sendNotification( WorkerModule.CONNECT_MODULE_TO_WORKER, logger );
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
				{	
					const module	: IPipeAware = note.getBody() as IPipeAware;
					const pipe		: Pipe = new Pipe(Pipe.newChannelID());
					
					module.acceptOutputPipe( PipeAwareModule.STDLOG, pipe );
					logger.acceptInputPipe( PipeAwareModule.STDIN, pipe );
					
					break;
				}
				// Bidirectionally connect shell and logger on STDLOG/STDSHELL
				case  MainFacade.CONNECT_MAIN_TO_LOGGER: 
				{
					trace("\n> LoggerModuleMediator : MainFacade.CONNECT_MAIN_TO_LOGGER");
					// The junction was passed from MainJunctionMediator
					const mainJunction	: Junction 		= note.getBody() as Junction;
					const mainInputTee	: TeeMerge 		= mainJunction.retrievePipe(PipeAwareModule.STDIN) as TeeMerge;
					const mainToLogPipe	: IPipeFitting 	= mainJunction.retrievePipe(PipeAwareModule.STDLOG);
					
					const logToMainPipe	: Pipe = new Pipe(mainToLogPipe.channelID);
					
					logger.acceptInputPipe( PipeAwareModule.STDIN, mainToLogPipe );
					logger.acceptOutputPipe( PipeAwareModule.STDMAIN, logToMainPipe );
					
					mainInputTee.connectInput(logToMainPipe);
					
					break;
				}
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