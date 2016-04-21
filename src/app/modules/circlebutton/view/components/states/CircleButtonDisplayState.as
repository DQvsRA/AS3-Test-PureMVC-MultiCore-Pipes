package app.modules.circlebutton.view.components.states
{
	import flash.display.Shape;
	
	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public class CircleButtonDisplayState extends Shape
	{
		private var _bgColor:uint;
		private var _size:uint;
		
		public function CircleButtonDisplayState(bgColor:uint, size:uint)
		{
			this._bgColor = bgColor;
			this._size = size;
			draw();
		}
		
		private function draw():void
		{
			graphics.beginFill(_bgColor);
			graphics.drawCircle(0, 0, _size);
			graphics.endFill();
		}
	}
}