package
{
	import app.shell.MainFacade;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public class Main extends Sprite 
	{
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			var shape:Shape = new Shape()
			shape.graphics.beginFill(0xf1f1f1);
			shape.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			//while (count--) shape.graphics.drawCircle(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight, (Math.random()*10 + 5));
			shape.graphics.endFill();
			this.addChild(shape);
			
			MainFacade.getInstance(MainFacade.NAME).startup(this);
		}
		
	}
	
}