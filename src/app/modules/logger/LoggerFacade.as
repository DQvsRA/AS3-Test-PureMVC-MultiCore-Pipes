/**
 * ...
 * @author Vladimir Minkin
 */
	
package app.modules.logger 
{
	import app.modules.logger.controller.LoggerStartupCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class LoggerFacade extends Facade
	{
		// Notification name constants
		public static const NAME			: String 		= "loggerFacade";
		public static const STARTUP			: String 		= "startup";
		public static const LOG_MSG			: String 		= "logMessage";
		public static const CREATE_LOG		: String 		= "createLog";
		public static const EXPORT_LOG_UI		: String 		= "createLog";
		
		public function LoggerFacade( key:String )
        {
            super(key);    
        }
		
		/**
         * Singleton ApplicationFacade Factory Method
         */
		public static function getInstance(key:String):LoggerFacade 
		{
			if ( instanceMap[ key ] == null ) instanceMap[ key ]  = new LoggerFacade( key );
            return instanceMap[ key ] as LoggerFacade;
		}
		
		/**
         * Register Commands with the Controller 
         */
		override protected function initializeController():void 
		{
			super.initializeController();
			
			registerCommand(STARTUP, LoggerStartupCommand);
		}
		
		public function startup( stage:Object ):void 
		{
			sendNotification( STARTUP, stage );
		}
	}
}