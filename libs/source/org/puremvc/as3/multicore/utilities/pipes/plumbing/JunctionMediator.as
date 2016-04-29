/*
 PureMVC AS3/MultiCore Utility – Pipes
 Copyright (c) 2008 Cliff Hall<cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package org.puremvc.as3.multicore.utilities.pipes.plumbing
{
	import app.modules.worker.WorkerFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	
	/**
	 * Junction Mediator.
	 * <P>
	 * A base class for handling the Pipe Junction in an IPipeAware 
	 * Core.</P>
	 */
	public class JunctionMediator extends Mediator
	{
		/**
		 * Accept input pipe notification name constant.
		 */ 
        public static const ACCEPT_INPUT_PIPE:String 	= 'acceptInputPipe';
		
		/**
		 * Accept output pipe notification name constant.
		 */ 
        public static const ACCEPT_OUTPUT_PIPE:String 	= 'acceptOutputPipe';

		/**
		 * Constructor.
		 */
		public function JunctionMediator( name:String, viewComponent:Junction )
		{
			super( name, viewComponent );
		}

		/**
		 * List Notification Interests.
		 * <P>
		 * Returns the notification interests for this base class.
		 * Override in subclass and call <code>super.listNotificationInterests</code>
		 * to get this list, then add any sublcass interests to 
		 * the array before returning.</P>
		 */
		override public function listNotificationInterests():Array
		{
			return [ 
				JunctionMediator.ACCEPT_INPUT_PIPE, 
				JunctionMediator.ACCEPT_OUTPUT_PIPE
		   ];	
		}
		
		/**
		 * Handle Notification.
		 * <P>
		 * This provides the handling for common junction activities. It 
		 * accepts input and output pipes in response to <code>IPipeAware</code>
		 * interface calls.</P>
		 * <P>
		 * Override in subclass, and call <code>super.handleNotification</code>
		 * if none of the subclass-specific notification names are matched.</P>
		 */
		override public function handleNotification( note:INotification ):void
		{
			switch( note.getName() )
			{
				// accept an input pipe
				// register the pipe and if successful 
				// set this mediator as its listener
				case JunctionMediator.ACCEPT_INPUT_PIPE:
					const inputPipeName	: String = note.getType();
					const inputPipe		: IPipeFitting = note.getBody() as IPipeFitting;
					
					if(junction.hasInputPipe(inputPipeName)) {
						trace("\t\t : ACCEPT_INPUT_PIPE =", inputPipeName);
						const incomePipeIn	: IPipeFitting = note.getBody() as IPipeFitting;
						const teeInput		: TeeMerge = junction.retrievePipe(inputPipeName) as TeeMerge;
						trace("\t\t : Connect =", teeInput.pipeName, incomePipeIn);
						teeInput.connectInput(incomePipeIn);	
					} else {
						if ( junction.registerPipe(inputPipeName, Junction.INPUT, inputPipe) ) 
						{
							junction.addPipeListener( inputPipeName, this, handlePipeMessage );		
						} 
					}
					
					
					break;
				
				// accept an output pipe
				case JunctionMediator.ACCEPT_OUTPUT_PIPE:
					const outputPipeName:String = note.getType();
					const outputPipe:IPipeFitting = note.getBody() as IPipeFitting;
					trace("\t\t : ACCEPT_OUTPUT_PIPE =", outputPipeName);
					if(junction.hasOutputPipe(outputPipeName)) {
						const teeForOutput:IPipeFitting = junction.retrievePipe(outputPipeName) as IPipeFitting;
						trace("\t\t : Connect =", teeForOutput.pipeName, outputPipe);
						teeForOutput.connect(outputPipe);
					} else {
						junction.registerPipe( outputPipeName, Junction.OUTPUT, outputPipe );
					}
					break;
			}
		}
		
		/**
		 * Handle incoming pipe messages.
		 * <P>
		 * Override in subclass and handle messages appropriately for the module.</P>
		 */
		public function handlePipeMessage( message:IPipeMessage ):void
		{
		}
		
		/**
		 * The Junction for this Module.
		 */
		protected function get junction():Junction
		{
			return viewComponent as Junction;
		}
		
	
	}
}