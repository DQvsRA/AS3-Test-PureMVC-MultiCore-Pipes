package app.modules.circlebutton.view.components 
{
	import flash.display.SimpleButton;
	
	import app.modules.circlebutton.view.components.states.CircleButtonDisplayState;
	
	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public class CircleButton extends SimpleButton 
	{
		public function CircleButton() 
		{
			super();
			
			setupParameters({
				size: Math.random() * 20 + 20,
				upColor : Math.random()*0xffffff, 
				overColor : Math.random()*0xffffff, 
				downColor : Math.random()*0xffffff
			})
			
			useHandCursor  = true;
		}
		
		public function setupParameters(data:Object):void {
			const size:uint = data.size;
			const upColor:uint = data.upColor;
			const overColor:uint = data.overColor;
			const downColor:uint = data.downColor;
			this.upState = new CircleButtonDisplayState(upColor, size);
			this.overState = new CircleButtonDisplayState(overColor, size);
			this.downState = new CircleButtonDisplayState(downColor, size);
			this.hitTestState   = this.upState;
		}
	}
}