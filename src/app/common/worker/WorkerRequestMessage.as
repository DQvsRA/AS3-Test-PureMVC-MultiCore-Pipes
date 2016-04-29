package app.common.worker
{
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;

	[RemoteClass]
	public class WorkerRequestMessage extends Message
	{
		public function WorkerRequestMessage(request:String = "", data:Object = null, responce:Object = null )
		{
			const header:Object = { request:request, responce:responce };
			super(Message.NORMAL, header, data);
		}
		
		public function get data():Object
		{
			return body;
		}
		
		public function get request():String
		{
			return header.request;
		}
		
		public function get responce():*
		{
			return header.responce;
		}
		
		public function set responce(value:String):void 
		{
			header.responce = value;
		}
	}
}