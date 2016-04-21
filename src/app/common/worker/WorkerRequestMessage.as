package app.common.worker
{
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;

	[RemoteClass]
	public class WorkerRequestMessage extends Message
	{
		public function WorkerRequestMessage(request:String = "", data:Object = null, responce:Object = null )
		{
			super(request, responce, data);
		}
		
		public function get data():Object
		{
			return body;
		}
		
		public function get request():String
		{
			return type;
		}
		
		public function get responce():String
		{
			return String(header);
		}
		
		public function set responce(value:String):void 
		{
			header = value;
		}
	}
}