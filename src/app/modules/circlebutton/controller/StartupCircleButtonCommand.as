package app.modules.circlebutton.controller
{
	import app.modules.circlebutton.model.CircleButtonProxy;
	import app.modules.circlebutton.CircleButtonJunctionMediator;
	import app.modules.circlebutton.view.CircleButtonMediator;
	import app.modules.circlebutton.view.components.CircleButton;
    import org.puremvc.as3.multicore.interfaces.ICommand;
    import org.puremvc.as3.multicore.interfaces.INotification;
    import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupCircleButtonCommand extends SimpleCommand implements ICommand
    {
        override public function execute(note:INotification):void
        {
        	trace("> CircleMaker : StartupCommand");
       		facade.registerProxy( new CircleButtonProxy( ) );
       		facade.registerMediator( new CircleButtonJunctionMediator( ) );
       		facade.registerMediator( new CircleButtonMediator( new CircleButton() ) );
        }
        
    }
}