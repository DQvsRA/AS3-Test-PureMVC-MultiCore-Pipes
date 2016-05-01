
package app.common.worker
{
	import app.common.PipeAwareModule;
	
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Filter;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeSplit;
	
	public class WorkerJunctionMediator extends JunctionMediator
	{
		public function WorkerJunctionMediator(name:String, workerJunction:WorkerJunction )
		{
			super( name, workerJunction || new Junction() );
		}

		public function get workerJunction():WorkerJunction {
			return junction as WorkerJunction;
		}
		
		override public function onRegister():void
		{
			const workerNotSupported:Boolean = workerJunction && !workerJunction.isSupported;
//			trace("> WorkerJunction : PipeAwareModule.WRKOUT =", junction.hasPipe(PipeAwareModule.WRKOUT))
			if (!junction.hasPipe(PipeAwareModule.WRKOUT)) {
				// The WRKOUT pipe from the worker to all modules or main
				var teeOut:IPipeFitting = new TeeSplit();
				if(workerNotSupported) {
					const filter:Filter = new Filter( 
						WorkerJunction.FILTER_FOR_APPLY_RESPONCE, teeOut, 
						workerJunction.filter_ApplyMessageResponce as Function
					);
					teeOut = filter as IPipeFitting;
				}
				junction.registerPipe( PipeAwareModule.WRKOUT, Junction.OUTPUT, teeOut );
			}

//			trace("> WorkerJunction : PipeAwareModule.WRKIN =", junction.hasPipe(PipeAwareModule.WRKIN))
			if(!junction.hasPipe(PipeAwareModule.WRKIN)) {
				// The WRKIN pipe to the worker from all modules
				const teeMerge		: TeeMerge = new TeeMerge();
				const pipeListener	: PipeListener = new PipeListener(this, handlePipeMessage);
				// This situation happend when no worker being accepted
				// Master already has PipeAwareModule.WRKIN it's only 
				if(workerNotSupported)
				{
					const diconectFilter:Filter = new Filter(
						WorkerJunction.FILTER_FOR_DISCONNECT_MODULE, pipeListener, 
						workerJunction.filter_DisconnectModule
					);
					
					const responceFilter:Filter = new Filter( 
						WorkerJunction.FILTER_FOR_STORE_RESPONCE, diconectFilter, 
						workerJunction.filter_KeepMessageResponce as Function
					);
					
					teeMerge.connect(responceFilter);
				} 
				else 
				{
					// This only happend on Worker because he do not need to know about filtering, this is done already in Master
					teeMerge.connect(pipeListener);
				}
				junction.registerPipe( PipeAwareModule.WRKIN, Junction.INPUT, teeMerge );
			}
		}
	}
}