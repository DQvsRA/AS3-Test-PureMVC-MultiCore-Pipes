package app.modules
{
	import flash.utils.ByteArray;
	
	import app.modules.workers.calculator.CalculatorFacade;
	import app.common.worker.WorkerModule;
	
	public final class CalculatorModule extends WorkerModule
	{
		static public const CALCULATE_CIRCLE_BUTTON		: String = "calculateCircleSize";
		static public const CALCULATE_MAIN_COLOR		: String = "calculateMainColor";
		static public const CALCULATE_LOG_SIZE			: String = "calculateLogSize";
		
		static public const MESSAGE_TO_MAIN_SET_COLOR 	: String = "messageToMainSetColor";
		
		public function CalculatorModule(bytes:ByteArray=null)
		{
			this.facade = CalculatorFacade.getInstance( WorkerModule.getNextID() );
			super(bytes);
		}
		
		override public function start():void 
		{
			CalculatorFacade(facade).startup(this);
		}
	}
}