package app.common.worker
{
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeAware;
	
	public interface IWorkerModule extends IPipeAware
	{
		function start():void;
	}
}