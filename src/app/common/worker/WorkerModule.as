
package app.common.worker
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import nest.services.worker.events.WorkerEvent;
	import nest.services.worker.process.WorkerTask;
	import nest.services.worker.swf.DynamicSWF;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	
	public class WorkerModule extends Sprite implements IWorkerModule
	{
		static private const 
			WORKER_MODULE_NAME			: String = "worker.module"
		,	INCOMIMG_MESSAGE_CHANNEL	: String = "incomimgMessageChannel"
		,	OUTGOING_MESSAGE_CHANNEL	: String = "outgoingMessageChannel"
		,	SHARE_DATA_PIPE				: String = "shareDataPipe"
		;
		
		static public const 
			CONNECT_MODULE_TO_WORKER	: String = "connectModuleToWorker"
		,	DICONNECT_OUTPUT_PIPE		: String = "diconnectOutputPipe"
		,	DICONNECT_INPUT_PIPE		: String = "diconnectInputPipe"
		;
		
		public var 
			incomingMessageChannel	: MessageChannel
		,	outgoingMessageChannel	: MessageChannel
		
		,	isSupported		: Boolean
		,	isMaster 		: Boolean
		,	isReady 		: Boolean
		,	isBusy			: Boolean
		;
		
		private var 
			_worker  	: Worker
		,	_shareable	: ByteArray
		;
		
		protected var facade:IFacade;
			
		private const _tasksQueue:Vector.<WorkerTask> = new Vector.<WorkerTask>();
		
		/**
		 * This object is the part of Master as well as the worker
		 * It's a facade holder - entry point for worker application (like Main)
		 */
		public function WorkerModule(bytes:ByteArray = null, useWorker:Boolean = true)
		{
			isSupported = Worker.isSupported && useWorker;
			isMaster = Worker.current.isPrimordial;
			isReady = false;
			isBusy = false;
			
			if (isSupported) 
			{
				if (isMaster) {
					const className : String = getQualifiedClassName(this);
					const swf 		: ByteArray = DynamicSWF.fromClass(className, bytes);
					
					_worker = WorkerDomain.current.createWorker(swf, false);
					_worker.addEventListener(Event.WORKER_STATE, function(e:Event):void {
						switch(e.currentTarget.state) {
							case WorkerState.RUNNING: start(); break;
							case WorkerState.NEW: break;				
							case WorkerState.TERMINATED: break;					
						}
					}, false, 0, true);
					
					incomingMessageChannel = Worker.current.createMessageChannel(_worker);
					outgoingMessageChannel = _worker.createMessageChannel(Worker.current);
					
					setSharedProperty(INCOMIMG_MESSAGE_CHANNEL, incomingMessageChannel);
					setSharedProperty(OUTGOING_MESSAGE_CHANNEL, outgoingMessageChannel);

					_shareable = new ByteArray();
					_shareable.shareable = true;
					setSharedProperty(SHARE_DATA_PIPE, _shareable);
					
					// Because we cant run task before worker is being ready
					// So we mark "task execution" as Busy to store all WorkerTasks in a Queue for later execution
					isBusy = true;
					
					_worker.start();
					
				} else {
					_worker = Worker.current;
					
					outgoingMessageChannel = getSharedProperty(OUTGOING_MESSAGE_CHANNEL);
					incomingMessageChannel = getSharedProperty(INCOMIMG_MESSAGE_CHANNEL);
					
					_shareable = getSharedProperty(SHARE_DATA_PIPE);
					_shareable.shareable = true;
					
					// Worker don't need to wait, it's start immediately
					start();
				}
			} else {
				start();
				ready();
			}
		}
		
		public function get outputChannel():MessageChannel { return isMaster ? incomingMessageChannel : outgoingMessageChannel; }
		public function get inputChannel():MessageChannel { return isMaster ? outgoingMessageChannel : incomingMessageChannel; }
		
		//==================================================================================================	
		public function send(task:WorkerTask):void {
		//==================================================================================================	
			if(isBusy) {
				_tasksQueue.push(task);
			} else {
				isBusy = true;
				setSharedData(task.data);
				outputChannel.send(task.id, 0);
			}
		}
				
		//==================================================================================================	
		public function getSharedProperty(id:String):* {
		//==================================================================================================	
			return _worker.getSharedProperty(id);
		}
		
		//==================================================================================================	
		public function completeTask():void {
		//==================================================================================================	
			isBusy = false;
//			trace("\n> COMPLETE TASK => TASK QUEUE:", isMaster, _tasksQueue.length);
			if(_tasksQueue.length) {
				const task:WorkerTask = _tasksQueue.shift();
//				trace("\t\t : TASK:", JSON.stringify(task));
				this.send(task);
			}
		}
		
		//==================================================================================================	
		public function setSharedProperty(id:String, obj:*):void {
		//==================================================================================================	
			_worker.setSharedProperty(id, obj);
		}
		
		//==================================================================================================	
		public function setSharedData(data:*):void {
		//==================================================================================================	
			_shareable.clear();
			if(data) {
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
		public function start():void {
		//==================================================================================================	
//			trace("> WorkerModule -> Starting: M =", isMaster);
			throw new Error("Method start in class that extend WorkerModule must be overwritten");
		}
		
		public function acceptInputPipe(name:String, pipe:IPipeFitting):void 
		{ facade.sendNotification( JunctionMediator.ACCEPT_INPUT_PIPE, pipe, name ); }
		public function acceptOutputPipe(name:String, pipe:IPipeFitting):void 
		{ facade.sendNotification( JunctionMediator.ACCEPT_OUTPUT_PIPE, pipe, name ); }
		
		public function getID():String { return moduleID; }
		public static function getNextID():String { return WORKER_MODULE_NAME + "." + serial++; }
		private static var serial:Number = 0;
		protected const moduleID:String = WorkerModule.getNextID();
	}
}