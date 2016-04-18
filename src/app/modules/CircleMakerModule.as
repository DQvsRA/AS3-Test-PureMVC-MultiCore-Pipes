/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.modules
{
	import app.common.PipeAwareModule;
	import app.modules.circlemaker.CircleMakerFacade;
	import app.shell.MainFacade;

	public class CircleMakerModule extends PipeAwareModule
	{
		static public const MESSAGE_TO_SHELL_CIRCLE_MAKER_BUTTON:String = "appendCircleButton";
		
		public function CircleMakerModule()
		{
			super(CircleMakerFacade.getInstance( moduleID ));
			CircleMakerFacade(facade).startup( this );
		}
		
		public function getID():String
		{
			return moduleID;
		}
		
		public function exportToMain():void
		{
			trace("CircleMakerModule.exportToMain");
			facade.sendNotification(CircleMakerFacade.GET_CIRCLE_BUTTON);
		}
		
		/**
		 * Get the next unique id.
		 * <P>
		 * This module can be instantiated multiple times, 
		 * so each instance needs to have it's own unique
		 * id for use as a multiton key.
		 */
		private static function getNextID():String
		{
			return CircleMakerFacade.NAME + '/' + serial++;
		}
		
		private static var serial:Number = 0;
		private var moduleID:String = CircleMakerModule.getNextID();
		
	}
}