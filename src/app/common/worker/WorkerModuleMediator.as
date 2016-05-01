package app.common.worker
{
	import app.common.PipeAwareModule;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;
	
	public class WorkerModuleMediator extends Mediator
	{
		public static const NAME:String = 'WorkerModuleMediator';
		
		public function WorkerModuleMediator(name:String, module: WorkerModule )
		{
			super( name || NAME, module );
		}
		
		override public function listNotificationInterests():Array
		{
			return [ 
				WorkerModule.CONNECT_MODULE_TO_WORKER,
			];
		}
		
		override public function handleNotification( note:INotification ):void
		{
			switch( note.getName() )
			{
				case  WorkerModule.CONNECT_MODULE_TO_WORKER:
				{	
					trace("\n> WorkerModuleMediator : MainFacade.CONNECT_MODULE_TO_WORKER", note.getBody());

					const module		: IPipeAware = note.getBody() as IPipeAware;
					
					const workerOutPipe	: Pipe = new Pipe(Pipe.newChannelID());
					const workerInPipe	: Pipe = new Pipe(workerOutPipe.channelID);
					
					workerOutPipe.channelID = workerInPipe.channelID;
					
					worker.acceptInputPipe( PipeAwareModule.WRKIN, workerInPipe );
					module.acceptOutputPipe( PipeAwareModule.TOWRK, workerInPipe );
					
					worker.acceptOutputPipe( PipeAwareModule.WRKOUT, workerOutPipe );
					module.acceptInputPipe( PipeAwareModule.FROMWRK, workerOutPipe );
					
					break;
				}
			}
		}
		
		/**
		 * The Worker Module.
		 */
		private function get worker():WorkerModule
		{
			return viewComponent as WorkerModule;
		}
	}
}