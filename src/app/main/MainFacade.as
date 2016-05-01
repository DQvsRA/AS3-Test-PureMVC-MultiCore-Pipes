package app.main
{
	import app.main.controller.CreateCircleButtonModuleCommand;
	import app.main.controller.MainStartupCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	/**
	 * Concrete Facade for the Main App / Shell.
	 */
	public class MainFacade extends Facade
	{
        public static const STARTUP:String 					= 'startup';
        public static const NAME:String 					= 'shell';
		
		static public const CONNECT_MODULE_TO_MAIN		:String = "connectModuleToMain";
		static public const CONNECT_MODULE_TO_LOGGER	:String = "connectModuleToLogger";
		
		static public const CONNECT_MAIN_TO_LOGGER		:String = "connectMainToLogger";
		static public const CONNECT_MAIN_TO_WORKER		:String = "connectMainToWorker";
		
		/* JUNCTION NOTES */
		static public const CREATE_MODULE_CIRCLE_MAKER	:String = "cretateModuleCircleMaker";
		static public const APPEND_CIRCLE_BUTTON		:String = "appendCircleButton";
		static public const WORKER_GET_MAIN_COLOR		:String = "workerGetMainColor";
		
		/* MAIN MEDIATOR HANDLES */
		static public const GET_MODULE_LOGGER			:String = "getLogger";
		static public const APPEND_LOG_WINDOW			:String = "appendLogWindow";
		static public const APPLY_MAIN_COLOR			:String = "applyMainColor";
		
        public function MainFacade( key:String )
        {
            super(key);
        }

        /**
         * ApplicationFacade Factory Method
         */
        public static function getInstance( key:String ) : MainFacade 
        {
            if ( instanceMap[ key ] == null ) instanceMap[ key ]  = new MainFacade( key );
            return instanceMap[ key ] as MainFacade;
        }
        
        /**
         * Register Commands with the Controller 
         */
        override protected function initializeController( ) : void 
        {
            super.initializeController();            
            registerCommand( STARTUP, MainStartupCommand );
            registerCommand( CREATE_MODULE_CIRCLE_MAKER, CreateCircleButtonModuleCommand );
        }
        
        /**
         * Application startup
         * 
         * @param app a reference to the application component 
         */  
        public function startup( app:Main ):void
        {
            sendNotification( STARTUP, app );
        }
	}
}