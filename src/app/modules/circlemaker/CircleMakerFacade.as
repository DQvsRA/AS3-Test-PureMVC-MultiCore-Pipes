/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.modules.circlemaker
{
	import app.modules.circlemaker.controller.CircleButtonClickedCommand;
	import app.modules.circlemaker.controller.StartupCircleMakerCommand;
	import app.modules.CircleMakerModule;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	/**
	 * Application Facade for Logger Module.
	 */ 
	public class CircleMakerFacade extends Facade
	{
		public static const STARTUP:String 				= 'startup';
		public static const NAME:String 				= 'circlemaker';
		
        static public const GET_CIRCLE_BUTTON:String 	= "getCircleButton";
		static public const EXPORT_CIRLE_BUTTON:String 	= "exportCircleButton";
		static public const CLICK_COUNT_CHANGED:String 	= "clickCountChanged";
		static public const CIRCLE_BUTTON_CLICKED:String = "buttonClicked";
                
        public function CircleMakerFacade( key:String )
        {
            super(key);    
        }

        /**
         * ApplicationFacade Factory Method
         */
        public static function getInstance( key:String ) : CircleMakerFacade 
        {
            if ( instanceMap[ key ] == null ) instanceMap[ key ]  = new CircleMakerFacade( key );
            return instanceMap[ key ] as CircleMakerFacade;
        }
        
        /**
         * Register Commands with the Controller 
         */
        override protected function initializeController( ) : void 
        {
            super.initializeController();            
            registerCommand( STARTUP, StartupCircleMakerCommand );
            registerCommand( CIRCLE_BUTTON_CLICKED, CircleButtonClickedCommand );
        }
        
        /**
         * Application startup
         * 
         * @param app a reference to the application component 
         */  
        public function startup( app:CircleMakerModule ):void
        {
            sendNotification( STARTUP, app );
        }
	}
}