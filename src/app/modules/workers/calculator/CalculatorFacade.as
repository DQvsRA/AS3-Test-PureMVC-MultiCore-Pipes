/**
 * ...
 * @author Vladimir Minkin
 */
	
package app.modules.workers.calculator 
{
	import app.modules.workers.calculator.controller.CalculatorStartupCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class CalculatorFacade extends Facade implements IFacade 
	{
		// Notification name constants
		static public const STARTUP						: String = "startup";
		
		static public const CONNECT_MODULE_TO_WORKER	: String = "connectModuleToWorker";
		static public const SEND_RESULT_MAIN_COLOR		: String = "sendResultToStageColor";
		static public const SEND_RESULT_CIRCLE_BUTTON	: String = "sendResultToCircleButton";
		static public const SEND_RESULT_LOG_SIZE		: String = "sendResultToLogSize";

		static public const CMD_CALCULATE_MAIN_COLOR	: String = "commandCalculateMainColor";
		static public const CMD_CALCULATE_CIRCLE_BUTTON	: String = "commandCalculateCircleButton";
		static public const CMD_CALCULATE_LOG_SIZE		: String = "commandCalculateLogSize";
		
		public function CalculatorFacade( key:String )
        {
            super(key);
        }
		
		public static function getInstance(key:String):CalculatorFacade 
		{
			if ( instanceMap[ key ] == null ) instanceMap[ key ]  = new CalculatorFacade( key );
            return instanceMap[ key ] as CalculatorFacade;
		}
		
		override protected function initializeController():void 
		{
			super.initializeController();
			registerCommand(STARTUP, CalculatorStartupCommand);
		}
		
		public function startup( module:Object ):void 
		{
			sendNotification( STARTUP, module );
		}
	}
}