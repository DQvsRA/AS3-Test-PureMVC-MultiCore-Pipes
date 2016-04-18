/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.shell.view
{
	import app.common.LoggingJunction;
	import app.common.LogMessage;
	import app.common.PipeAwareModule;
	import app.common.UIQueryMessage;
	import app.modules.CircleMakerModule;
	import app.modules.LoggerModule;
	import app.shell.MainFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	
	public class MainJunction extends LoggingJunction
	{
		public static const NAME:String = 'MainJunctionMediator';
		
		public function MainJunction()
		{
			super( NAME, new Junction() );
		}

		/**
		 * Called when the Mediator is registered.
		 * <P>
		 * Registers a Merging Tee for STDIN, 
		 * and sets this as the Pipe Listener.</P>
		 * <P>
		 * Registers a Pipe for STDLOG and 
		 * connects it to LoggerModule.</P>
		 */
		override public function onRegister():void
		{
			// The STDOUT pipe from the shell to all modules 
			junction.registerPipe( PipeAwareModule.STDOUT,  Junction.OUTPUT, new TeeSplit() );
			
			// The STDIN pipe to the shell from all modules 
			junction.registerPipe( PipeAwareModule.STDIN,  Junction.INPUT, new TeeMerge() );
			junction.addPipeListener( PipeAwareModule.STDIN, this, handlePipeMessage );
			
			// The STDLOG pipe from the shell to the logger
			junction.registerPipe( PipeAwareModule.STDLOG, Junction.OUTPUT, new Pipe() );
			
			sendNotification(MainFacade.CONNECT_MAIN_TO_LOGGER, junction );
		}
		
		/**
		 * ShellJunction related Notification list.
		 * <P>
		 * Adds subclass interests to JunctionMediator interests.</P>
		 */
		override public function listNotificationInterests():Array
		{
			var interests:Array = super.listNotificationInterests();
			interests.push( MainFacade.GET_MODULE_LOGGER );
			interests.push( MainFacade.CONNECT_MODULE_TO_SHELL );
			
			return interests;
		}

		/**
		 * Handle ShellJunction related Notifications.
		 */
		override public function handleNotification( note:INotification ):void
		{
			switch( note.getName() )
			{
				case MainFacade.GET_MODULE_LOGGER:
					junction.sendMessage(PipeAwareModule.STDLOG, new UIQueryMessage(UIQueryMessage.GET, LoggerModule.GET_LOG_UI));
					break;
//
				case  MainFacade.CONNECT_MODULE_TO_SHELL:
					
					// Connect a module's STDSHELL to the shell's STDIN
					const module:IPipeAware = note.getBody() as IPipeAware;
					
					const shellIn:TeeMerge = junction.retrievePipe(PipeAwareModule.STDIN) as TeeMerge;
					const moduleToShell:Pipe = new Pipe();
					
					module.acceptOutputPipe(PipeAwareModule.STDSHELL, moduleToShell);
					shellIn.connectInput(moduleToShell);
					
					// Connect the shell's STDOUT to the module's STDIN
					const shellToModule:Pipe = new Pipe();
					const shellOut:IPipeFitting = junction.retrievePipe(PipeAwareModule.STDOUT) as IPipeFitting;
					
					module.acceptInputPipe(PipeAwareModule.STDIN, shellToModule);
					shellOut.connect(shellToModule);
					
					sendNotification(LogMessage.SEND_TO_LOG,"Connected new module instance to Shell.", LogMessage.LEVELS[LogMessage.DEBUG]);
					
					break;

				// Let super handle the rest (ACCEPT_OUTPUT_PIPE, ACCEPT_INPUT_PIPE, SEND_TO_LOG)								
				default:
					super.handleNotification(note);
					
			}
		}
		
		/**
		 * Handle incoming pipe messages for the ShellJunction.
		 * <P>
		 * The LoggerModule sends its LogButton and LogWindow instances
		 * to the Shell for display management via an output Pipe it 
		 * knows as STDSHELL. The PrattlerModule instances also send
		 * their manufactured FeedWindow instances to the shell via
		 * their STDSHELL pipe. Those messages all show up and are
		 * handled here.</P>
		 * <P>
		 * Note that we are handling PipeMessages with the same idiom
		 * as Notifications. Conceptually they are the same, and the
		 * Mediator role doesn't change much. It takes these messages
		 * and turns them into notifications to be handled by other 
		 * actors in the main app / shell.</P> 
		 * <P>
		 * Also, it is logging its actions by sending INFO messages
		 * to the STDLOG output pipe.</P> 
		 */
		override public function handlePipeMessage( message:IPipeMessage ):void
		{
			if ( message is UIQueryMessage )
			{
				trace("MainJunction.handlePipeMessage:", UIQueryMessage(message).name);
				switch ( UIQueryMessage(message).name )
				{
					case LoggerModule.MESSAGE_TO_SHELL_LOG_UI:
						sendNotification(MainFacade.APPEND_LOG_WINDOW, UIQueryMessage(message).component )
						junction.sendMessage(PipeAwareModule.STDLOG, new LogMessage(LogMessage.INFO, this.multitonKey, 'Recieved the Log Window on STDSHELL'));
						break;
//
					case CircleMakerModule.MESSAGE_TO_SHELL_CIRCLE_MAKER_BUTTON:
						trace("\tcomponent:", UIQueryMessage(message).component)
						sendNotification(MainFacade.APPEND_CIRCLE_BUTTON, UIQueryMessage(message).component, UIQueryMessage(message).name )
						break;
				}
			}
		}
	}
}