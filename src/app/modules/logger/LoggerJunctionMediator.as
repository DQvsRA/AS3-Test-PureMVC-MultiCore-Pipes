
package app.modules.logger
{
	import flash.display.DisplayObject;
	
	import app.common.LogFilterMessage;
	import app.common.LogMessage;
	import app.common.PipeAwareModule;
	import app.common.UIQueryMessage;
	import app.common.worker.WorkerRequestMessage;
	import app.modules.LoggerModule;
	import app.modules.WorkerModule;
	import app.modules.logger.LoggerFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Filter;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	
	public class LoggerJunctionMediator extends JunctionMediator
	{
		public static const NAME:String = 'LoggerJunctionMediator';

		public function LoggerJunctionMediator( )
		{
			super( NAME, new Junction() );
		}

		override public function onRegister():void
		{
			const teeMerge:TeeMerge = new TeeMerge();
			const filter:Filter = new Filter( 
				LogFilterMessage.LOG_FILTER_NAME,  null,
				LogFilterMessage.filterLogByLevel as Function
			);
			filter.connect(new PipeListener(this, handlePipeMessage));
			teeMerge.connect(filter);
			junction.registerPipe( PipeAwareModule.STDIN, Junction.INPUT, teeMerge );
			junction.registerPipe( PipeAwareModule.TOWRK, Junction.INPUT, new TeeMerge() );
		}
		
		override public function listNotificationInterests():Array
		{
			var interests:Array = super.listNotificationInterests();
			interests.push(LoggerFacade.EXPORT_LOG_UI);
			interests.push(LogMessage.SEND_TO_LOG);
			return interests;
		}
	
		override public function handleNotification( note:INotification ):void
		{
			
			switch( note.getName() )
			{
				// Send the LogWindow UI Component 
				case LoggerFacade.EXPORT_LOG_UI:
					trace("LoggerFacade.EXPORT_LOG_UI");
					const logWindowMessage:UIQueryMessage = new UIQueryMessage( UIQueryMessage.SET, LoggerModule.MESSAGE_TO_MAIN_LOG_UI, note.getBody() as DisplayObject);
//					junction.sendMessage( PipeAwareModule.TOWRK, new WorkerRequestMessage( WorkerModule.CALCULATE_LOG_SIZE, null, function(value:int):void {
						junction.sendMessage( PipeAwareModule.STDMAIN, logWindowMessage );
//					} ));
					break;
					
				// Add an input pipe (special handling for LoggerModule) 
				case JunctionMediator.ACCEPT_INPUT_PIPE:
					const name:String = note.getType();
					trace(name);
					// STDIN is a Merging Tee. Overriding super to handle this.
//					if (name == PipeAwareModule.STDIN) {
					const pipe:IPipeFitting = note.getBody() as IPipeFitting;
					const tee:TeeMerge = junction.retrievePipe(name) as TeeMerge;
					tee.connectInput(pipe);
//					} 
					// Use super for any other input pipe
//					else {
//						super.handleNotification(note); 
//					} 
					break;

				// And let super handle the rest (ACCEPT_OUTPUT_PIPE)								
				default:
					super.handleNotification(note);
					
			}
		}
		
		/**
		 * Handle incoming pipe messages.
		 */
		override public function handlePipeMessage( message:IPipeMessage ):void
		{
			if ( message is LogMessage ) 
			{
				sendNotification( LoggerFacade.LOG_MSG, message );
			} 
			else if ( message is UIQueryMessage )
			{
				switch ( UIQueryMessage(message).name )
				{
					case LoggerModule.GET_LOG_UI:
						sendNotification(LoggerModule.GET_LOG_UI)
						break;
				}
			}
		}
	}
}