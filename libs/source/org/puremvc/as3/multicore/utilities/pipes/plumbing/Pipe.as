/*
 PureMVC AS3/MultiCore Utility – Pipes
 Copyright (c) 2008 Cliff Hall<cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package org.puremvc.as3.multicore.utilities.pipes.plumbing
{
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	
	/**
	 * Pipe.
	 * <P>
	 * This is the most basic <code>IPipeFitting</code>,
	 * simply allowing the connection of an output
	 * fitting and writing of a message to that output.</P>
	 */	
	public class Pipe implements IPipeFitting
	{
		private static var serial:Number = 1;
		public static function getID():uint { return serial++; }
		
		public var chainLength:uint = 0;
		
		private var
			_id			: uint = Pipe.getID()
		,	_pipeName	: String
		;

		protected var output:IPipeFitting;
		
		public function Pipe( output:IPipeFitting = null )
		{
			if (output) connect(output);
		}

		/**
		 * Connect another PipeFitting to the output.
		 * 
		 * PipeFittings connect to and write to other 
		 * PipeFittings in a one-way, syncrhonous chain.</P>
		 * 
		 * @return Boolean true if no other fitting was already connected.
		 */
		public function connect( output:IPipeFitting ) : Boolean
		{
			var success:Boolean = false;
			if (this.output == null) {
				output.pipeName = this.pipeName;
				this.output = output;
				success = true;
				chainLength++;
			}
			return success;
		}
		
		/**
		 * Disconnect the Pipe Fitting connected to the output.
		 * <P>
		 * This disconnects the output fitting, returning a 
		 * reference to it. If you were splicing another fitting
		 * into a pipeline, you need to keep (at least briefly) 
		 * a reference to both sides of the pipeline in order to 
		 * connect them to the input and output of whatever 
		 * fiting that you're splicing in.</P>
		 * 
		 * @return IPipeFitting the now disconnected output fitting
		 */
		public function disconnect( ) : IPipeFitting
		{
			const disconnectedFitting:IPipeFitting = this.output;
			this.output = null;
			return disconnectedFitting;
		}
		
		/**
		 * Write the message to the connected output.
		 * 
		 * @param message the message to write
		 * @return Boolean whether any connected downpipe outputs failed
		 */
		public function write( message:IPipeMessage ) : Boolean
		{
			return output && output.write( message );
		}

		public function get pipeName():String { return _pipeName; }

		public function set pipeName(value:String):void { _pipeName = value; }

		public function get id():uint { return _id; }

		public function set id(value:uint):void { _id = value; }
	}
}