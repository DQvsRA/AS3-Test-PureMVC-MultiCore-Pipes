package app.main.view
{
	import flash.display.SimpleButton;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	import app.main.MainFacade;
	
	import nest.services.worker.thread.Thread;
	
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
		}
		
		//==================================================================================================
		private function onKeyUp(e:KeyboardEvent):void {
		//==================================================================================================
			switch(e.keyCode)
			{
				case Keyboard.SPACE: {
					sendNotification(MainFacade.CREATE_MODULE_CIRCLE_MAKER);
					break;
				}
				case Keyboard.NUMBER_0: {
					facade.sendNotification( MainFacade.WORKER_GET_MAIN_COLOR );
					break;	
				}
				case Keyboard.S: {
					var thread:Thread = new Thread(100);
					
					for (var i:int = 0; i < 1000; i++) 
					{
						thread.add(function():void{
							facade.sendNotification( MainFacade.CREATE_MODULE_CIRCLE_MAKER );
							facade.sendNotification( MainFacade.WORKER_GET_MAIN_COLOR );
						});
					}
					thread.execute();
											
					break;	
				}
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [ 
				MainFacade.APPEND_CIRCLE_BUTTON,
				MainFacade.APPEND_LOG_WINDOW,
				MainFacade.APPLY_MAIN_COLOR
			];	
		}

		override public function handleNotification( note:INotification ):void
		{
			switch( note.getName() )
			{
				case MainFacade.APPEND_CIRCLE_BUTTON:
					const button:SimpleButton = note.getBody() as SimpleButton;
					button.x = app.stage.stageWidth * Math.random();
					button.y = app.stage.stageHeight * Math.random();
					app.addChild(button);
					break;
				case MainFacade.APPEND_LOG_WINDOW:
					const log:TextField = note.getBody() as TextField;
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