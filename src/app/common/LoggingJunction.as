package app.common
{
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	
	public class LoggingJunction extends JunctionMediator
	{

		public function LoggingJunction( name:String, junction:Junction )
		{
			super( name, junction );
		}

		override public function listNotificationInterests():Array
		{
			var interests:Array = super.listNotificationInterests();
			interests.push(LogMessage.SEND_TO_LOG);
			return interests;
		}

		override public function handleNotification( note:INotification ):void
		{
			switch( note.getName() )
			{
                // Send messages to the Log
                case LogMessage.SEND_TO_LOG:
                    var level:int;
                    switch (note.getType())
                    {
                        case LogMessage.LEVELS[LogMessage.DEBUG]:
                            level = LogMessage.DEBUG;
                            break;

                        case LogMessage.LEVELS[LogMessage.ERROR]:
                            level = LogMessage.ERROR;
                            break;
                        
                        case LogMessage.LEVELS[LogMessage.FATAL]:
                            level = LogMessage.FATAL;
                            break;
                        
                        case LogMessage.LEVELS[LogMessage.INFO]:
                            level = LogMessage.INFO;
                            break;
                        
                        case LogMessage.LEVELS[LogMessage.WARN]:
                            level = LogMessage.WARN;
                            break;
                        
                        default:
                            level = LogMessage.DEBUG;
                            break;
                        
                    }
                    var logMessage:LogMessage = new LogMessage( level, this.multitonKey, note.getBody() as String);
                    junction.sendMessage( PipeAwareModule.STDLOG, logMessage );
                    break;
				
				// And let super handle the rest (ACCEPT_OUTPUT_PIPE, ACCEPT_INPUT_PIPE, SEND_TO_LOG)								
				default:
					super.handleNotification(note);
					
			}
		}
		
	}
}