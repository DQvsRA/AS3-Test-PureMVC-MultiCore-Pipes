package app.common.worker
{
	import flash.events.Event;
	import flash.net.registerClassAlias;
	import flash.system.MessageChannel;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import mx.utils.UIDUtil;
	
	import app.common.PipeAwareModule;
	import app.modules.WorkerModule;
	
	import nest.services.worker.process.WorkerTask;
	
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Filter;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;

	public final class WorkerJunction extends Junction
	{
		static public const FILTER_FOR_DISCONNECT_MODULE			: String = "pipeFilterDiconnectMessage";
		static public const FILTER_FOR_STORE_RESPONCE_FUNCTION		: String = "pipeFilterInputMessage";
		static public const FILTER_FOR_APPLY_RESPONCE_FUNCTION		: String = "pipeFilterOutputMessage";
		
		public var isSupported:Boolean = false;
		
		private const _responceFunctions:Dictionary = new Dictionary(true);
		
		{
			registerClassAlias(getQualifiedClassName(WorkerRequestMessage), 		WorkerRequestMessage );
			registerClassAlias(getQualifiedClassName(WorkerResponceMessage), 		WorkerResponceMessage );
		}
		
		public function WorkerJunction(workerModule:WorkerModule)
		{
			isSupported = workerModule.isSupported; 
			if (isSupported) 
			{
				if (workerModule.isMaster) // The WRKIN pipe to the worker from all modules
				{
					const teeMerge:TeeMerge = new TeeMerge();
					const diconectFilter:Filter = new Filter(
						FILTER_FOR_DISCONNECT_MODULE, 
						null, 
						filter_DisconnectModule
					);
					diconectFilter.connect(new PipeListener(workerModule, 
						function ( message:WorkerRequestMessage ):void 
						{
//							trace("\n> WorkerJunction : PipeMessage_MasterToWorker: \n\t\t : isBusy = " + this.isBusy + "\n", JSON.stringify(message) + "\n");
							this.send( new WorkerTask(WorkerTask.MESSAGE, message ));
						})
					);
					const requestFilter:Filter = new Filter( 
						FILTER_FOR_STORE_RESPONCE_FUNCTION, diconectFilter, 
						filter_KeepResponceFunction as Function
					);
					teeMerge.connect(requestFilter);
					this.registerPipe( PipeAwareModule.WRKIN,  Junction.INPUT, teeMerge );
				}
				else // The WRKOUT pipe from the worker to all modules or main
				{
					const teeSplit:TeeSplit = new TeeSplit();
					this.registerPipe( PipeAwareModule.WRKOUT, Junction.OUTPUT, teeSplit );
					this.addPipeListener( PipeAwareModule.WRKOUT, workerModule, function( message:WorkerResponceMessage ):void 
					{
//						trace("\n> WorkerJunction : PipeMessage_WorkerToMaster: \n\t\t : isBusy = " + this.isBusy + "\n", JSON.stringify(message) + "\n");
						this.send( new WorkerTask(WorkerTask.MESSAGE, message) );
					});
					
					workerModule.send( new WorkerTask(WorkerTask.READY) );
				}
				
				workerModule.inputChannel.addEventListener(Event.CHANNEL_MESSAGE, function(junction:Junction):Function {
					const __isMaster	: Boolean 	= workerModule.isMaster;
					const __getData		: Function 	= workerModule.getSharedData;
					const __ready		: Function 	= workerModule.ready;
					const __complete	: Function 	= workerModule.completeTask;
					const __channel		: String 	= __isMaster ? PipeAwareModule.WRKOUT : PipeAwareModule.WRKIN;
					const __getPipe		: Function 	= junction.retrievePipe;
					
					return function (e:Event):void {
						const taskType 	: * = (e.currentTarget as MessageChannel).receive(true);
						const responce 	: IPipeMessage = __getData() as IPipeMessage;
//						trace("\n> CHANNEL_MESSAGE : ", __isMaster, taskType, "\n" + JSON.stringify(responce) + "\n");
						if (taskType is int) {
							switch(taskType)
							{
								case WorkerTask.READY: __ready(); break;
								case WorkerTask.MESSAGE: {
									if(__isMaster && !filter_ApplyResponceFunction(responce as WorkerResponceMessage)) {
										break;
									}
									(__getPipe(__channel) as IPipeFitting).write(responce);
								}
								break;
							}
//							trace("\n===> COMPLETE TASK:", __isMaster, taskType);
							__complete();
						}
					}
				}(this));
			}
		}
		
		public function filter_DisconnectModule(message:WorkerRequestMessage, params:Object = null):IPipeMessage
		{
			const request:String = message.request;
			var disconnected:IPipeFitting;
			switch(request)
			{
				case WorkerModule.DICONNECT_INPUT_PIPE:
				{
//					trace("> filterDisconnectOutput, DISCONNECT_OUTPUT_PIPE");
					disconnected = message.data as IPipeFitting;
					disconnected.disconnect();
					filter_ApplyResponceFunction(new WorkerResponceMessage(message.responce));
					return null;
				}
				case WorkerModule.DICONNECT_OUTPUT_PIPE:
				{
//					trace("> filterDisconnectOutput, DISCONNECT_OUTPUT_PIPE");
					const teeSplit:TeeSplit = this.retrievePipe(PipeAwareModule.WRKOUT) as TeeSplit;
					if(teeSplit) {
						disconnected = message.data as IPipeFitting;
						disconnected.disconnect();
						disconnected = teeSplit.disconnectFitting(disconnected);
						disconnected.disconnect();
						filter_ApplyResponceFunction(new WorkerResponceMessage(message.responce));
					}
					return null;
				}
			}
			return message;
		}
		
		public function filter_ApplyResponceFunction(message:WorkerResponceMessage, params:Object = null):IPipeMessage {
//			trace("> filterApplyFunctionResponce", Worker.current.isPrimordial, JSON.stringify(message));
			const taskResponceID:String = message.responce;
			const taskResponce:Function = _responceFunctions[taskResponceID];
//			trace("\t\t : taskResponce =", taskResponce);
			if(taskResponce) {
				delete _responceFunctions[taskResponceID];
				taskResponce(message);
				return null;
			}
			return message;
		}
		
		public function filter_KeepResponceFunction(message:WorkerRequestMessage, params:Object = null):IPipeMessage {
//			trace("> filterKeepResponceFunction", message);
			const responce:* = message.responce;
			if(responce is Function) {
				const responceTaskID:String = UIDUtil.createUID(); // getTimer().toString();
				_responceFunctions[responceTaskID] = responce;
				message.responce = responceTaskID;
			}
			return message;
		}
	}
}