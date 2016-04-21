package nest.services.worker.process.messages
{
	public final class DataWorkerMessage
	{
		private var _data:*;
		private var _name:String;
		
		public function DataWorkerMessage(name:String = "", data:* = null)
		{
			this._name = name;
			this._data = data;
		}
		public function get data():* { return _data; }
		public function get name():String { return _name; }

		public function set data(value:*):void { _data = value; }
		public function set name(value:String):void { _name = value; }


	}
}