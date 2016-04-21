/**
 * ...
 * @author Vladimir Minkin
 */

package app.modules.circlebutton.controller.commands 
{
	import app.modules.circlebutton.CircleButtonFacade;
	import app.modules.circlebutton.model.CircleButtonProxy;
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
			const circleMakerProxy:CircleButtonProxy = facade.retrieveProxy(CircleButtonProxy.NAME) as CircleButtonProxy;
			circleMakerProxy.clickHappend();
			trace("> CircleButtonClickedCommand", circleMakerProxy.clickCount);
			this.sendNotification(CircleButtonFacade.CLICK_COUNT_CHANGED, circleMakerProxy.clickCount, multitonKey);
		}
	}
}