package app.modules.circlemaker.view.components 
{
	import app.modules.circlemaker.view.components.states.CircleButtonDisplayState;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public class CircleButton extends SimpleButton 
	{
		public function CircleButton() 
		{
			super();
			const size:uint = Math.random() * 20 + 20;
			
			this.upState = new CircleButtonDisplayState(Math.random()*0xffffff, size);
			this.overState = new CircleButtonDisplayState(Math.random()*0xffffff, size);
			this.downState = new CircleButtonDisplayState(Math.random()*0xffffff, size);
			
			this.hitTestState   = this.upState;
			useHandCursor  = true;
		}
	}
}