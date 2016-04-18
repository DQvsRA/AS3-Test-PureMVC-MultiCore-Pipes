
package app.modules.logger.view
{
	import app.common.LogFilterMessage;
	import app.common.LogMessage;
	import app.common.PipeAwareModule;
	import app.common.UIQueryMessage;
	import app.modules.logger.LoggerFacade;
	import app.modules.LoggerModule;
	import flash.display.DisplayObject;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Filter;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	
	public class LoggerJunction extends JunctionMediator
	{
		public static const NAME:String = 'LoggerJunctionMediator';

		public function LoggerJunction( )
		{
			super( NAME, new Junction() );
		}

		override public function onRegister():void
		{
			var teeMerge:TeeMerge = new TeeMerge();
			var filter:Filter = new Filter( 
				LogFilterMessage.LOG_FILTER_NAME,  null,
				LogFilterMessage.filterLogByLevel as Function
			);
			filter.connect(new PipeListener(this, handlePipeMessage));
			teeMerge.connect(filter);
			junction.registerPipe( PipeAwareModule.STDIN, Junction.INPUT, teeMerge );
		}
		
		/**
		 * List Notification Interests.
		 * <P>
		 * Adds subclass interests to those of the JunctionMediator.</P>
		 */
		override public function listNotificationInterests():Array
		{
			var interests:Array = super.listNotificationInterests();
			interests.push(LoggerFacade.EXPORT_LOG_UI);
			interests.push(LogMessage.SEND_TO_LOG);
			//interests.push(LoggerFacade.EXPORT_LOG_UI);
			return interests;
		}
	
		override public function handleNotification( note:INotification ):void
		{
			
			switch( note.getName() )
			{
				// Send the LogWindow UI Component 
				case LoggerFacade.EXPORT_LOG_UI:
					trace("LoggerFacade.EXPORT_LOG_UI");
					var logWindowMessage:UIQueryMessage = new UIQueryMessage( UIQueryMessage.SET, LoggerModule.MESSAGE_TO_SHELL_LOG_UI, note.getBody() as DisplayObject);
					junction.sendMessage( PipeAwareModule.STDSHELL, logWindowMessage );
					break;
					
				// Add an input pipe (special handling for LoggerModule) 
				case JunctionMediator.ACCEPT_INPUT_PIPE:
					var name:String = note.getType();
					// STDIN is a Merging Tee. Overriding super to handle this.
					if (name == PipeAwareModule.STDIN) {
						var pipe:IPipeFitting = note.getBody() as IPipeFitting;
						var tee:TeeMerge = junction.retrievePipe(PipeAwareModule.STDIN) as TeeMerge;
						tee.connectInput(pipe);
					} 
					// Use super for any other input pipe
					else {
						super.handleNotification(note); 
					} 
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