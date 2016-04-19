/**
 * ...
 * @author Vladimir Minkin
 */

package app.modules.logger.view 
{
	import app.common.LogMessage;
	import app.modules.logger.view.components.LoggerView;
	import app.modules.logger.LoggerFacade;
	import app.modules.LoggerModule;
	import flash.display.DisplayObject;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class LoggerMediator extends Mediator implements IMediator 
	{
		public static const NAME:String = "LoggerMediator";
		
		public function LoggerMediator( viewComponent:LoggerView ) 
		{
			super( NAME, viewComponent );
		}
        
		override public function listNotificationInterests():Array 
		{
			return [
				LoggerModule.GET_LOG_UI,
				LoggerFacade.LOG_MSG
			];
		}
		
		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{           
				case LoggerModule.GET_LOG_UI:
					//trace("\n> LoggerMediator > LoggerModule.GET_LOG_UI");
					sendNotification(LoggerFacade.EXPORT_LOG_UI, DisplayObject(this.viewComponent));
					break;
				case LoggerFacade.LOG_MSG:
					logger.addText((note.getBody() as LogMessage).message);
					break;
			}
		}
		
		private function get logger():LoggerView {
			return this.viewComponent as LoggerView;
		}
	}
}