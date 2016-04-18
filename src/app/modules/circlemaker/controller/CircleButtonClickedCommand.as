/**
 * ...
 * @author Vladimir Minkin
 */

package app.modules.circlemaker.controller 
{
	import app.modules.circlemaker.CircleMakerFacade;
	import app.modules.circlemaker.model.CircleMakerProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	public class CircleButtonClickedCommand extends SimpleCommand implements ICommand 
	{
		
		/**
         * Register the Proxies and Mediators.
         */
		override public function execute( note:INotification ):void 
		{
			const circleMakerProxy:CircleMakerProxy = facade.retrieveProxy(CircleMakerProxy.NAME) as CircleMakerProxy;
			circleMakerProxy.clickHappend();
			trace("> CircleButtonClickedCommand", circleMakerProxy.clickCount);
			this.sendNotification(CircleMakerFacade.CLICK_COUNT_CHANGED, circleMakerProxy.clickCount, multitonKey);
		}
	}
}