
package app.modules.logger
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import app.common.LogFilterMessage;
	import app.common.LogMessage;
	import app.common.PipeAwareModule;
	import app.common.UIQueryMessage;
	import app.common.worker.WorkerRequestMessage;
	import app.common.worker.WorkerResponceMessage;
	import app.modules.LoggerModule;
	import app.modules.WorkerModule;
	import app.modules.logger.LoggerFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Filter;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;
	
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
				LogFilterMessage.LOG_FILTER_NAME, null,
				LogFilterMessage.filterLogByLevel as Function
			);
			filter.connect(new PipeListener(this, handlePipeMessage));
			teeMerge.connect(filter);
			
			junction.registerPipe( PipeAwareModule.STDIN, Junction.INPUT, teeMerge );
//			junction.addPipeListener( PipeAwareModule.STDIN, this, handlePipeMessage);
			
			junction.registerPipe( PipeAwareModule.FROMWRK, Junction.INPUT, new TeeMerge() );
			junction.addPipeListener(PipeAwareModule.FROMWRK, this, handleWorkerPipeMessage);
//
			junction.registerPipe( PipeAwareModule.TOWRK, Junction.OUTPUT, new TeeSplit() );
			junction.registerPipe( PipeAwareModule.STDMAIN, Junction.OUTPUT, new TeeSplit() );
		}
		
		private function handleWorkerPipeMessage(message:IPipeMessage):void
		{
			trace("> LoggerJunctionMediator.handleWorkerPipeMessage:\n" + JSON.stringify(message) + "\n");
		}
		
		override public function listNotificationInterests():Array
		{
			const interests:Array = super.listNotificationInterests();
			interests.push( LoggerFacade.EXPORT_LOG_UI );
			interests.push( LogMessage.SEND_TO_LOG );
			return interests;
		}
	
		override public function handleNotification( note:INotification ):void
		{
//			trace("\n> LoggerJunctionMediator.handleNotification", note.getName());
			const type:String = note.getType();
			switch( note.getName() )
			{
				// Send the LogWindow UI Component 
				case LoggerFacade.EXPORT_LOG_UI:
//					trace("\t\t : LoggerFacade.EXPORT_LOG_UI");
					const loggerTF:TextField = note.getBody() as TextField;
					const logWindowMessage:UIQueryMessage = new UIQueryMessage( UIQueryMessage.SET, LoggerModule.MESSAGE_TO_MAIN_LOG_UI, loggerTF);
					junction.sendMessage( PipeAwareModule.TOWRK, new WorkerRequestMessage( WorkerModule.CALCULATE_LOG_SIZE, null, function(result:WorkerResponceMessage):void {
						const fontSize:uint = uint(result.data);
//						trace("Message from worker received by logger", fontSize);
						const format:TextFormat = loggerTF.getTextFormat();
						format.size = fontSize;
						loggerTF.defaultTextFormat = format;
						junction.sendMessage( PipeAwareModule.STDMAIN, logWindowMessage );
					}));
					break;
				default:
					super.handleNotification(note);
					
			}
		}
		
		/**
		 * Handle incoming pipe messages.
		 */
		override public function handlePipeMessage( message:IPipeMessage ):void
		{
//			trace("> LoggerJunctionMediator: handlePipeMessage =", JSON.stringify(message));
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