package app.common.worker
{
	import flash.events.Event;
	import flash.net.registerClassAlias;
	import flash.system.MessageChannel;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.UIDUtil;
	
	import app.common.PipeAwareModule;
	import app.modules.WorkerModule;
	
	import nest.services.worker.process.WorkerTask;
	
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;

	public final class WorkerJunction extends Junction
	{
		private const _tasks:Dictionary = new Dictionary(true);
		{
			registerClassAlias(getQualifiedClassName(WorkerRequestMessage), 		WorkerRequestMessage );
			registerClassAlias(getQualifiedClassName(WorkerResponceMessage), 		WorkerResponceMessage );
		}
		
		public function WorkerJunction(workerModule:WorkerModule)
		{
			
			if (workerModule.isSupported) 
			{
				if (workerModule.isMaster) {
					// The WRKIN pipe to the worker from all modules
					this.registerPipe( PipeAwareModule.WRKIN,  Junction.INPUT, new TeeMerge() );
					this.addPipeListener(PipeAwareModule.WRKIN, workerModule, function ( message:WorkerRequestMessage ):void 
					{
						if(message.getHeader() is Function) {
							const responceTaskID:String = UIDUtil.createUID();
							_tasks[responceTaskID] = message.getHeader();
							message.responce = responceTaskID;
						}
						this.send( new WorkerTask(WorkerTask.MESSAGE, message ));
					});
				} 
				else {
					// The WRKOUT pipe from the worker to all modules or main
					this.registerPipe( PipeAwareModule.WRKOUT, Junction.OUTPUT, new TeeSplit() );
					this.addPipeListener( PipeAwareModule.WRKOUT, workerModule, function( message:WorkerResponceMessage ):void 
					{
//						trace("> WorkerProcessor : PipeMessage_WorkerToMaster", message);
						this.send( new WorkerTask(WorkerTask.MESSAGE, message) );
					});
				}
				
				workerModule.inputChannel.addEventListener(Event.CHANNEL_MESSAGE, function(junction:Junction):Function {
					const __isMaster	: Boolean 	= workerModule.isMaster;
					const __getData		: Function 	= workerModule.getSharedData;
					const __ready		: Function 	= workerModule.ready;
					const __channel		: String 	= __isMaster ? PipeAwareModule.WRKOUT : PipeAwareModule.WRKIN;
					const __getPipe		: Function 	= junction.retrievePipe;
					var taskResponce:Function;
					return function (e:Event):void {
						const taskType 	: * = (e.currentTarget as MessageChannel).receive(true);
						const data 		: IPipeMessage = __getData() as IPipeMessage;
						trace("> WorkerProcessor : ", taskType, data);
						if (taskType is int) {
							switch(taskType)
							{
								case WorkerTask.READY: __ready(); break
								case WorkerTask.MESSAGE: {
									if(__isMaster) {
										taskResponce = _tasks[data.getType()];
										if(taskResponce) {
											taskResponce(data);
											return;
										}
									}
									(__getPipe(__channel) as IPipeFitting).write(data);
								}
								break;
							}
						}
					}
				}(this));
				workerModule.send(new WorkerTask(WorkerTask.READY));
			}
		}
	}
}