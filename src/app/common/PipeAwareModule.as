/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.common
{
	import mx.modules.ModuleBase;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;

	public class PipeAwareModule extends ModuleBase implements IPipeAware
	{
		/**
		 * Standard output pipe name constant.
		 */
		public static const STDOUT:String 				= 'outputFromMainToAll';
		
		/**
		 * Standard input pipe name constant.
		 */
		public static const STDIN:String 				= 'inputFromMain';
		
		/**
		 * Standard shell pipe name constant.
		 */
		public static const STDMAIN:String 				= 'toMain';
		
		/**
		 * Standard log pipe name constant.
		 */
		public static const STDLOG:String 				= 'toLog';
		
		/**
		 * Worker output out.
		 */
		public static const TOWRK:String 				= 'toWorkerTee';
		
		/**
		 * Worker output in.
		 */
		public static const FROMWRK:String 				= 'fromWorkerTee';
		
		/**
		 * Worker input in.
		 */
		public static const WRKIN:String 				= 'workerIn';
		
		/**
		 * Worker output out.
		 */
		public static const WRKOUT:String 				= 'workerOut';
		
		/**
		 * Constructor.
		 * <P>
		 * In subclass, create appropriate facade and pass 
		 * to super.</P>
		 */
		public function PipeAwareModule( facade:IFacade )
		{
			super();
			this.facade = facade;
		}

		/**
		 * Accept an input pipe.
		 * <P>
		 * Registers an input pipe with this module's Junction.
		 */
		public function acceptInputPipe( name:String, pipe:IPipeFitting ):void
		{
			facade.sendNotification( JunctionMediator.ACCEPT_INPUT_PIPE, pipe, name );							
		}
		
		/**
		 * Accept an output pipe.
		 * <P>
		 * Registers an input pipe with this module's Junction.
		 */
		public function acceptOutputPipe( name:String, pipe:IPipeFitting ):void
		{
			facade.sendNotification( JunctionMediator.ACCEPT_OUTPUT_PIPE, pipe, name );							
		}

		protected var facade:IFacade;
	}
}