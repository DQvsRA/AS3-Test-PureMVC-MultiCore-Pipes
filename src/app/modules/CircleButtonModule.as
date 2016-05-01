package app.modules
{
	import app.common.PipeAwareModule;
	import app.modules.circlebutton.CircleButtonFacade;

	public class CircleButtonModule extends PipeAwareModule
	{
		static public const MESSAGE_TO_MAIN_CIRCLE_MAKER_BUTTON	: String = "appendCircleButton";
		
		static public const RECIEVE_CIRCLE_BUTTON_PARAMERTS		: String = "recieveCircleButtonParamets";
		
		public function CircleButtonModule()
		{
			super(CircleButtonFacade.getInstance( moduleID ));
			CircleButtonFacade(facade).startup( this );
		}
		
		public function exportToMain():void
		{
//			trace("> CircleMaker : Module.exportToMain");
			facade.sendNotification(CircleButtonFacade.GET_CIRCLE_BUTTON);
		}
		
		public function getID():String
		{
			return moduleID;
		}
		
		private static function getNextID():String
		{
			return CircleButtonFacade.NAME + '/' + serial++;
		}
		
		private static var serial:Number = 0;
		private var moduleID:String = CircleButtonModule.getNextID();
		
	}
}