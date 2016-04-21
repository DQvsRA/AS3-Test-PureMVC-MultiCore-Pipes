package nest.services.worker.events 
{
	import flash.events.Event;

	public class WorkerEvent extends Event
	{
		public static const 
			READY			:String = "WORKER_READY"
		,	TERMINATED		:String = "WORKER_TERMINATED"

		public function WorkerEvent(type:String)
		{
			super(type);
		}
		
	}
}