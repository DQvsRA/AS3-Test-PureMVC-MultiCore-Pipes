/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.modules.circlebutton
{
	import app.modules.circlebutton.controller.commands.CircleButtonClickedCommand;
	import app.modules.circlebutton.controller.StartupCircleButtonCommand;
	import app.modules.CircleButtonModule;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	/**
	 * Application Facade for Logger Module.
	 */ 
	public class CircleButtonFacade extends Facade
	{
		public static const STARTUP:String 				= 'startup';
		public static const NAME:String 				= 'circlemaker';
		
        static public const GET_CIRCLE_BUTTON		:String 	= "getCircleButton";
		static public const EXPORT_CIRLE_BUTTON		:String 	= "exportCircleButton";
		
		static public const CLICK_COUNT_CHANGED		:String 	= "clickCountChanged";
		static public const CIRCLE_BUTTON_CLICKED	:String 	= "buttonClicked";
		
		static public const ASK_FOR_CIRCLE_BUTTON_PARAMERTS		:String = "askForCircleButtonParamets";
		static public const SETUP_CIRCLE_BUTTON_PARAMETERS		:String = "setupCircleButtonParameters";
                
        public function CircleButtonFacade( key:String )
        {
            super(key);    
        }

        /**
         * ApplicationFacade Factory Method
         */
        public static function getInstance( key:String ) : CircleButtonFacade 
        {
            if ( instanceMap[ key ] == null ) instanceMap[ key ]  = new CircleButtonFacade( key );
            return instanceMap[ key ] as CircleButtonFacade;
        }
        
        /**
         * Register Commands with the Controller 
         */
        override protected function initializeController( ) : void 
        {
            super.initializeController();            
            registerCommand( STARTUP, StartupCircleButtonCommand );
            registerCommand( CIRCLE_BUTTON_CLICKED, CircleButtonClickedCommand );
        }
        
        /**
         * Application startup
         * 
         * @param app a reference to the application component 
         */  
        public function startup( app:CircleButtonModule ):void
        {
            sendNotification( STARTUP, app );
        }
	}
}