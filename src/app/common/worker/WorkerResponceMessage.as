package app.common.worker
{
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;

	[RemoteClass]
	public final class WorkerResponceMessage extends Message
	{
		public function WorkerResponceMessage(responce:String = "", data:Object = null)
		{
			super(responce, null, data);
		}
		
		public function get data():Object
		{
			return body;
		}
		
		public function get responce():String
		{
			return type;
		}
	}
}