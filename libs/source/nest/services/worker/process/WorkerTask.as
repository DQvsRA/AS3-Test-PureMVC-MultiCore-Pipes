package nest.services.worker.process
{
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;

	public final class WorkerTask
	{
		public function WorkerTask(id:int, data:IPipeMessage = null)
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
		private var _data:IPipeMessage;

		public function get id():int { return _id; }
		public function get data():IPipeMessage { return _data; }
	}
}