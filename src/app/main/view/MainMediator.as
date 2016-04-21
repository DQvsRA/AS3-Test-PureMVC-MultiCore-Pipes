/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.main.view
{
	import app.main.MainFacade;
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class MainMediator extends Mediator
	{
		public static const NAME:String = 'MainMediator';
		
		public function MainMediator( viewComponent:Main )
		{
			super( NAME, viewComponent );
		}

		/**
		 * Register event listeners with the app and its fixed controls.
		 */
		override public function onRegister():void
		{
			app.stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp);		
			//app.addEventListener( PipeWorks.LOG_LEVEL, onLogLevel );		
		}
		
		//==================================================================================================
		private function onKeyUp(e:KeyboardEvent):void {
		//==================================================================================================
			if(e.keyCode == Keyboard.SPACE) sendNotification(MainFacade.CREATE_MODULE_CIRCLE_MAKER);
		}
		
		/**
		 * Application related Notification list.
		 */
		override public function listNotificationInterests():Array
		{
			return [ 
				MainFacade.APPEND_CIRCLE_BUTTON,
				MainFacade.APPEND_LOG_WINDOW,
				MainFacade.APPLY_MAIN_COLOR
			];	
		}
		
		/**
		 * Handle MainApp / Shell related notifications.
		 * <P>
		 * Display and/or remove the module-manufactured LogButton, 
		 * LogWindow, and FeedWindows.</P>
		 */
		override public function handleNotification( note:INotification ):void
		{
			switch( note.getName() )
			{
				case MainFacade.APPEND_CIRCLE_BUTTON:
					var button:SimpleButton = note.getBody() as SimpleButton;
					button.x = app.stage.stageWidth * Math.random();
					button.y = app.stage.stageHeight * Math.random();
					app.addChild(button);
					break;
//
				case MainFacade.APPEND_LOG_WINDOW:
					var log:TextField = note.getBody() as TextField;
					log.width = app.stage.stageWidth;
					log.x = 0;
					log.y = 0;
					app.stage.addChild(log);
					break;
				case MainFacade.APPLY_MAIN_COLOR:
					app.changeColor(uint(note.getBody()));
					break;
			}
		}
		
		/**
		 * The Application component.
		 */
		private function get app():Main
		{
			return viewComponent as Main;
		}
	}
}