/**
 * ...
 * @author Vladimir Minkin
 */
	
package app.modules.worker 
{
	import app.modules.worker.controller.WorkerStartupCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class WorkerFacade extends Facade implements IFacade 
	{
		// Notification name constants
		static public const STARTUP			: String = "startup";
		
		static public const CONNECT_MODULE_TO_WORKER	: String = "connectModuleToWorker";
		static public const SEND_RESULT_MAIN_COLOR		: String = "sendResultToStageColor";
		static public const SEND_RESULT_CIRCLE_BUTTON_PARAMETERS	: String = "sendResultToCircleButton";

		static public const CMD_CALCULATE_MAIN_COLOR	: String = "commandCalculateMainColor";
		static public const CMD_CALCULATE_CIRCLE_BUTTON	: String = "commandCalculateCircleButton";
		
		public var isMaster:Boolean;
		
		public function WorkerFacade( key:String )
        {
            super(key);
        }
		
		public static function getInstance(key:String):WorkerFacade 
		{
			if ( instanceMap[ key ] == null ) instanceMap[ key ]  = new WorkerFacade( key );
            return instanceMap[ key ] as WorkerFacade;
		}
		
		override protected function initializeController():void 
		{
			super.initializeController();
			registerCommand(STARTUP, WorkerStartupCommand);
		}
		
		public function startup( module:Object ):void 
		{
			sendNotification( STARTUP, module );
		}
	}
}