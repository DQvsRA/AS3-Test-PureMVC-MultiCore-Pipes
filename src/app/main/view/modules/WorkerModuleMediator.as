/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.main.view.modules
{
	import app.common.PipeAwareModule;
	import app.modules.WorkerModule;
	import app.main.MainFacade;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	
	public class WorkerModuleMediator extends Mediator
	{
		public static const NAME:String = 'WorkerModuleMediator';
		
		public function WorkerModuleMediator( module: WorkerModule )
		{
			super( NAME, module );
		}
		
		//==================================================================================================	
		override public function onRegister():void {
		//==================================================================================================	
			
		}

		override public function listNotificationInterests():Array
		{
			return [ 
				MainFacade.CONNECT_MODULE_TO_WORKER,
				MainFacade.CONNECT_MAIN_TO_WORKER
			];
		}
		
		override public function handleNotification( note:INotification ):void
		{
					
			switch( note.getName() )
			{
				case  MainFacade.CONNECT_MODULE_TO_WORKER:
//					trace("\n> WorkerModuleMediator : MainFacade.CONNECT_MODULE_TO_WORKER", note.getBody());

					const workerOutPipe	: Pipe = new Pipe();
					const workerInPipe	: Pipe = new Pipe();
					const moduleIn		: IPipeAware = note.getBody() as IPipeAware;
					
					worker.acceptInputPipe( PipeAwareModule.WRKIN, workerInPipe );
					moduleIn.acceptOutputPipe( PipeAwareModule.TOWRK, workerInPipe );
					
					worker.acceptOutputPipe( PipeAwareModule.WRKOUT, workerOutPipe );
					moduleIn.acceptInputPipe( PipeAwareModule.FROMWRK, workerOutPipe );
					
					break;

				// Bidirectionally connect main and worker on TOWRK/STDMAIN
				case  MainFacade.CONNECT_MAIN_TO_WORKER:
//					trace("\n> WorkerModuleMediator : MainFacade.CONNECT_MAIN_TO_WORKER")
					// The junction was passed from MainJunctionMediator
					const wrkToMain		: Pipe 			= new Pipe();
					const mainJunction	: Junction 		= note.getBody() as Junction;
					
					const mainWrkPipe	: IPipeFitting 	= mainJunction.retrievePipe(PipeAwareModule.TOWRK);
					
					const mainInPipe	: TeeMerge 		= mainJunction.retrievePipe(PipeAwareModule.FROMWRK) as TeeMerge;
					
					worker.acceptInputPipe( PipeAwareModule.WRKIN, 		mainWrkPipe );
					worker.acceptOutputPipe( PipeAwareModule.WRKOUT, 	wrkToMain );
					
					mainInPipe.connectInput(wrkToMain);
					
					break;
			}
		}
		
		/**
		 * The Logger Module.
		 */
		private function get worker():WorkerModule
		{
			return viewComponent as WorkerModule;
		}
	}
}