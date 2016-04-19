
package app.modules
{
	import app.common.PipeAwareModule;
	import app.modules.circlebutton.CircleButtonFacade;
	import app.modules.logger.LoggerFacade;

	public class LoggerModule extends PipeAwareModule
	{
		public static const GET_LOG_UI:String 	= 'getLogUI';
		static public const MESSAGE_TO_MAIN_LOG_UI:String = "messageToShellLogUi";
		
		public function LoggerModule()
		{
			super(LoggerFacade.getInstance( LoggerFacade.NAME ));
			LoggerFacade(facade).startup( this );
		}
	}
}