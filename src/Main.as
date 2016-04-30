package
{
	import app.main.MainFacade;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public class Main extends Sprite 
	{
		private var _back:Graphics;
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			_back = this.graphics;
			this.changeColor(0xf1f1f1)
			
			stage.frameRate = 60;	
				
			MainFacade.getInstance(MainFacade.NAME).startup(this);
		}
		
		//==================================================================================================	
		public function changeColor(value:uint):void {
		//==================================================================================================	
			_back.beginFill(value);
			_back.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_back.endFill();
		}
		
	}
	
}