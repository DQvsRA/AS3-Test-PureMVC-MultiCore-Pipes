package app.main.view.modules
{
	import app.common.PipeAwareModule;
	import app.common.worker.WorkerModule;
	import app.main.MainFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Pipe;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import app.common.worker.WorkerModuleMediator;
	
	public class CalculatorModuleMediator extends WorkerModuleMediator
	{
		public static const NAME:String = 'CalculatorModuleMediator';
		
		public function CalculatorModuleMediator( module: WorkerModule )
		{
			super( NAME, module );
		}
		
		//==================================================================================================	
		override public function onRegister():void {
		//==================================================================================================	
			
		}

		override public function listNotificationInterests():Array
		{
			const list:Array = super.listNotificationInterests();
			list.push(MainFacade.CONNECT_MAIN_TO_WORKER);
			return list;
		}
		
		override public function handleNotification( note:INotification ):void
		{
			switch( note.getName() )
			{
				// Bidirectionally connect main and worker on TOWRK/STDMAIN
				case  MainFacade.CONNECT_MAIN_TO_WORKER:
				{
					trace("\n> WorkerModuleMediator : MainFacade.CONNECT_MAIN_TO_WORKER")
					const mainJunction	: Junction 		= note.getBody() as Junction;
					const mainToWrkPipe	: IPipeFitting 	= mainJunction.retrievePipe(PipeAwareModule.TOWRK);
					const mainInTee		: TeeMerge 		= mainJunction.retrievePipe(PipeAwareModule.FROMWRK) as TeeMerge;
					
					// The junction was passed from MainJunctionMediator
					const wrkToMainPipe	: Pipe = new Pipe(mainToWrkPipe.channelID);
					
					worker.acceptInputPipe( PipeAwareModule.WRKIN, 		mainToWrkPipe );
					worker.acceptOutputPipe( PipeAwareModule.WRKOUT, 	wrkToMainPipe );
					
					mainInTee.connectInput(wrkToMainPipe);
					
					break;
				}
				default: super.handleNotification(note);
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