package app.modules.logger.view.components 
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Vladimir Minkin
	 */
	public class LoggerView extends TextField 
	{
		private var _rows:Array = new Array();
		private var _rcount:uint = 0;
		public function LoggerView() 
		{
			super();
			
			this.defaultTextFormat = new TextFormat("Lato", 14, 0x232323, true);
			this.alpha = 0.8;
			this.mouseEnabled = false;
		}
		
		public function addText(message:String):void 
		{
			var t:String = this.text;
			if (_rows.unshift(message) > 5) {
				_rows.pop();
			}			
			this.text = _rows.join("\n");
		}
	}
}