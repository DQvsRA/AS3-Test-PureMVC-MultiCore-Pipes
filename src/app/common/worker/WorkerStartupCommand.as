/**
 * ...
 * @author Vladimir Minkin
 */

package app.common.worker 
{
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class WorkerStartupCommand extends SimpleCommand implements ICommand 
	{
		public var isMaster:Boolean;
		public var isSupported:Boolean;
		
		public function setup( input:Object ):WorkerJunction {
			const module:WorkerModule = input as WorkerModule;
			if(module) {
				isMaster = module.isMaster;
				isSupported = module.isSupported;
				return new WorkerJunction(module);
			} else return null;
		}
		
		override public function execute(note:INotification):void
		{
			note.setBody(setup(note.getBody()));
		}
	}
}