package app.main.view
{
	import app.common.LogMessage;
	import app.common.LoggingJunction;
	import app.common.PipeAwareModule;
	import app.common.UIQueryMessage;
	import app.common.worker.WorkerRequestMessage;
	import app.common.worker.WorkerResponceMessage;
	import app.main.MainFacade;
	import app.modules.CalculatorModule;
	import app.modules.CircleButtonModule;
	import app.modules.LoggerModule;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;
	
	public class MainJunctionMediator extends LoggingJunction
	{
		public static const NAME:String = 'MainJunctionMediator';
		
		public function MainJunctionMediator()
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
			// The STDIN pipe to the shell from all modules 
			junction.registerPipe( 		PipeAwareModule.STDIN,  Junction.INPUT, new TeeMerge() );
			junction.addPipeListener( 	PipeAwareModule.STDIN, this, handlePipeMessage );

			junction.registerPipe( 		PipeAwareModule.FROMWRK, Junction.INPUT, new TeeMerge() );
			junction.addPipeListener( 	PipeAwareModule.FROMWRK, this, handleWorkerPipeMessage );
			
			// The STDLOG pipe from the shell to the logger
			junction.registerPipe( PipeAwareModule.STDLOG, 	Junction.OUTPUT, new Pipe(Pipe.newChannelID()) );
			junction.registerPipe( PipeAwareModule.TOWRK, 	Junction.OUTPUT, new Pipe(Pipe.newChannelID()) );
			// The STDOUT pipe from the shell to all modules 
			junction.registerPipe( PipeAwareModule.STDOUT,  Junction.OUTPUT, new TeeSplit() );
			
			sendNotification(MainFacade.CONNECT_MAIN_TO_LOGGER, junction );
			sendNotification(MainFacade.CONNECT_MAIN_TO_WORKER, junction );
		}
		
		private function handleWorkerPipeMessage(message:IPipeMessage):void
		{
			trace("> MainJunctionMediator.handleWorkerPipeMessage:\n" + JSON.stringify(message) + "\n");
			if ( message is WorkerResponceMessage ) 
			{
				switch ( WorkerResponceMessage(message).responce ) 
				{
					case CalculatorModule.MESSAGE_TO_MAIN_SET_COLOR:
					{	
						const color:uint = uint(WorkerResponceMessage(message).data);
						sendNotification(MainFacade.APPLY_MAIN_COLOR, color )
						junction.sendMessage(PipeAwareModule.STDLOG, new LogMessage(LogMessage.INFO, this.multitonKey, 'New color for main is recived: ' + color));
						break;
					}
				}
			}
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
			interests.push( MainFacade.WORKER_GET_MAIN_COLOR );
			interests.push( MainFacade.CONNECT_MODULE_TO_MAIN );
			return interests;
		}

		/**
		 * Handle ShellJunction related Notifications.
		 */
		override public function handleNotification( note:INotification ):void
		{
			trace("\n> MainJunctionMediator.handleNotification:", note.getName());
			switch( note.getName() )
			{
				case MainFacade.GET_MODULE_LOGGER: 
				{
					trace("\t\t : MainFacade.GET_MODULE_LOGGER")
					junction.sendMessage( PipeAwareModule.STDLOG, new UIQueryMessage(UIQueryMessage.GET, LoggerModule.GET_LOG_UI));
					break;
				}
				case MainFacade.WORKER_GET_MAIN_COLOR: 
				{
					trace("\t\t : MainFacade.WORKER_GET_MAIN_COLOR")
//					junction.sendMessage(PipeAwareModule.TOWRK, new WorkerRequestMessage( CalculatorModule.CALCULATE_MAIN_COLOR, null, WorkerModule.MESSAGE_TO_MAIN_SET_COLOR	));
					junction.sendMessage(PipeAwareModule.TOWRK, new WorkerRequestMessage( CalculatorModule.CALCULATE_MAIN_COLOR, null, function(data:WorkerResponceMessage):void{
						const color:uint = uint(data.data);
						sendNotification(MainFacade.APPLY_MAIN_COLOR, color )
						junction.sendMessage( PipeAwareModule.STDLOG, new LogMessage( 0, multitonKey , "Color received by main: " + color) );
					}));
					break;
				}
				case  MainFacade.CONNECT_MODULE_TO_MAIN: 
				{
					const module:IPipeAware = note.getBody() as IPipeAware;
					
					const moduleToMain	: Pipe = new Pipe(Pipe.newChannelID());
					const mainToModule	: Pipe = new Pipe(moduleToMain.channelID);
					
					const mainInTee		: TeeMerge 		= junction.retrievePipe(PipeAwareModule.STDIN) as TeeMerge;
					const mainOutTee	: IPipeFitting 	= junction.retrievePipe(PipeAwareModule.STDOUT) as IPipeFitting;
					
					module.acceptOutputPipe(PipeAwareModule.STDMAIN, moduleToMain);
					mainInTee.connectInput(moduleToMain);
					
					module.acceptInputPipe(PipeAwareModule.STDIN, mainToModule);
					mainOutTee.connect(mainToModule);
					
					sendNotification(LogMessage.SEND_TO_LOG,"Connected new module instance to Shell.", LogMessage.LEVELS[LogMessage.DEBUG]);
					
					break;
				}
				// Let super handle the rest (ACCEPT_OUTPUT_PIPE, ACCEPT_INPUT_PIPE, SEND_TO_LOG)								
				default:
					super.handleNotification(note);
					
			}
		}
		
		override public function handlePipeMessage( message:IPipeMessage ):void
		{
			trace("MainJunction.handlePipeMessage:", message);
			if ( message is UIQueryMessage )
			{
				switch ( UIQueryMessage(message).name )
				{
					case LoggerModule.MESSAGE_TO_MAIN_LOG_UI:
						sendNotification(MainFacade.APPEND_LOG_WINDOW, UIQueryMessage(message).component )
						junction.sendMessage(PipeAwareModule.STDLOG, new LogMessage(LogMessage.INFO, this.multitonKey, 'Recieved the Log Window on STDSHELL'));
						break;
					case CircleButtonModule.MESSAGE_TO_MAIN_CIRCLE_MAKER_BUTTON:
						sendNotification(MainFacade.APPEND_CIRCLE_BUTTON, UIQueryMessage(message).component, UIQueryMessage(message).name )
						break;
				}
			} 
		}
	}
}