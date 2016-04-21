
package app.modules
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import app.modules.worker.WorkerFacade;
	
	import nest.services.worker.events.WorkerEvent;
	import nest.services.worker.process.WorkerTask;
	import nest.services.worker.swf.DynamicSWF;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	
	public class WorkerModule extends Sprite implements IPipeAware
	{
		static public const INCOMIMG_MESSAGE_CHANNEL	: String = "incomimgMessageChannel";
		static public const OUTGOING_MESSAGE_CHANNEL	: String = "outgoingMessageChannel";
		
		static public const SHARE_DATA_PIPE				: String = "shareDataPipe";
		
		static public const CALCULATE_CIRCLE_BUTTON		: String = "calculateCircleSize";
		static public const CALCULATE_MAIN_COLOR		: String = "calculateMainColor";
		static public const CALCULATE_LOG_SIZE			: String = "calculateLogSize";
		
		static public const MESSAGE_TO_MAIN_SET_COLOR 	: String = "messageToMainSetColor";

		public var 
			isReady 		: Boolean
		,	isMaster 		: Boolean
		,	isSupported		: Boolean
		;
		
		public var incomingMessageChannel:MessageChannel;
		public var outgoingMessageChannel:MessageChannel;
		
		protected var _worker  		: Worker;
		protected var _shareable	: ByteArray;
			
		public function WorkerModule(bytes:ByteArray = null)
		{
			this.facade = WorkerFacade.getInstance( moduleID );
			
			isSupported = Worker.isSupported;
			isMaster = Worker.current.isPrimordial;
			
			WorkerFacade(facade).isMaster = isMaster;
			
			if (isSupported) 
			{
				if (isMaster) {
					const className : String = getQualifiedClassName(this);
					const swf 		: ByteArray = DynamicSWF.fromClass(className, bytes);
					
					_worker = WorkerDomain.current.createWorker(swf, false);
					_worker.addEventListener(Event.WORKER_STATE, MasterHanlder_WorkerState); 
					
					incomingMessageChannel = Worker.current.createMessageChannel(_worker);
					outgoingMessageChannel = _worker.createMessageChannel(Worker.current);
					
					setSharedProperty(INCOMIMG_MESSAGE_CHANNEL, incomingMessageChannel);
					setSharedProperty(OUTGOING_MESSAGE_CHANNEL, outgoingMessageChannel);

					_shareable = new ByteArray();
					_shareable.shareable = true;
					setSharedProperty(SHARE_DATA_PIPE, _shareable);
					
					_worker.start();
					
					if(NativeApplication) NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, function(e:Event):void {
						_worker.terminate();
					}, false, 0, true);
					
				} else {
					_worker = Worker.current;
					
					outgoingMessageChannel = getSharedProperty(OUTGOING_MESSAGE_CHANNEL);
					incomingMessageChannel = getSharedProperty(INCOMIMG_MESSAGE_CHANNEL);
					
					_shareable = getSharedProperty(SHARE_DATA_PIPE);
					_shareable.shareable = true;
					
					Starting();
				}
			} else {
				Starting();
				ready();
			}
		}
		
		public function get outputChannel():MessageChannel { return isMaster ? incomingMessageChannel : outgoingMessageChannel; }
		public function get inputChannel():MessageChannel { return isMaster ? outgoingMessageChannel : incomingMessageChannel; }
		
		//==================================================================================================	
		public function send(task:WorkerTask):void {
		//==================================================================================================	
			trace("> WorkerModule -> SEND MESSAGE: isMaster =", task);
			setSharedData(task.data);
			outputChannel.send(task.id, 0);
		}
		
		//==================================================================================================
		private function MasterHanlder_WorkerState(e:Event):void {
		//==================================================================================================
			trace("> WorkerModule : MasterHanlder_WorkerState", e.currentTarget.state == WorkerState.RUNNING);
			switch(e.currentTarget.state) {
				case WorkerState.RUNNING: Starting(); break;
				case WorkerState.NEW: break;				
				case WorkerState.TERMINATED: break;					
			}
		}
		
				
		//==================================================================================================	
		public function getSharedProperty(id:String):* {
		//==================================================================================================	
			return _worker.getSharedProperty(id);
		}
		
		//==================================================================================================	
		public function setSharedProperty(id:String, obj:*):void {
		//==================================================================================================	
			_worker.setSharedProperty(id, obj);
		}
		
		//==================================================================================================	
		public function setSharedData(data:*):void {
		//==================================================================================================	
			if(data) {
				_shareable.clear();
				_shareable.writeObject(data);
			}
		}
		
		//==================================================================================================	
		public function getSharedData():* {
		//==================================================================================================	
			_shareable.position = 0;
			if(_shareable.bytesAvailable) {
				return _shareable.readObject();
			}
			return null;
		}
		
		//==================================================================================================	
		public function ready():void {
		//==================================================================================================	
			isReady = true;
			this.dispatchEvent( new WorkerEvent( WorkerEvent.READY ));
		}
		
		//==================================================================================================	
		private function Starting():void {
		//==================================================================================================	
			WorkerFacade(facade).startup( this );
		}
		
		public function getID():String { return moduleID; }
		private static function getNextID():String { return NAME + "." + serial++; }
		private static const NAME:String = "worker.module"
		private static var serial:Number = 0;
		private const moduleID:String = WorkerModule.getNextID();
		
		public function acceptInputPipe(name:String, pipe:IPipeFitting):void 
		{ facade.sendNotification( JunctionMediator.ACCEPT_INPUT_PIPE, pipe, name ); }
		public function acceptOutputPipe(name:String, pipe:IPipeFitting):void 
		{ facade.sendNotification( JunctionMediator.ACCEPT_OUTPUT_PIPE, pipe, name ); }
		protected var facade:IFacade;
	}
}