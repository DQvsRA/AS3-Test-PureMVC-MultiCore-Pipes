package nest.services.worker.process
{
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;

	public final class WorkerTask
	{
		public function WorkerTask(id:int, data:Message = null)
		{
			this._data = data;
			this._id = id;
		}
		
		public static const 
			READY 			: int = 0
		,	SIGNAL	 		: int = 11
		,	MESSAGE	 		: int = 12
		,	REQUEST 		: int = 13
		,	PROGRESS 		: int = 14
		,	COMPLETE 		: int = 15
		;

		private var _id:int;
		private var _data:Message;

		public function get id():int { return _id; }
		public function get data():Message { return _data; }
	}
}