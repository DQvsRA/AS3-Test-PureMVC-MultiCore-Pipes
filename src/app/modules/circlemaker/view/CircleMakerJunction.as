/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.modules.circlemaker.view
{
	import app.common.LogFilterMessage;
	import app.common.LoggingJunction;
	import app.common.LogMessage;
	import app.common.PipeAwareModule;
	import app.common.UIQueryMessage;
	import app.modules.circlemaker.CircleMakerFacade;
	import app.modules.circlemaker.view.components.CircleButton;
	import app.modules.CircleMakerModule;
	import app.shell.MainFacade;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import mx.core.UIComponent;
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Filter;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.TeeMerge;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	
	public class CircleMakerJunction extends LoggingJunction
	{
		public static const NAME:String = 'CircleMakerJunctionMediator';

		/**
		 * Constructor.
		 * <P>
		 * Creates and registers its own STDIN pipe
		 * and adds this instance as a listener, 
		 * because the logger uses a TeeMerge and 
		 * new inputs are added to it rather than
		 * as separate pipes registered with the
		 * Junction.</P>
		 */ 		
		public function CircleMakerJunction( )
		{
			super( NAME, new Junction() );
		}

		override public function onRegister():void
		{
			//var teeMerge:TeeMerge = new TeeMerge();
			//junction.registerPipe( PipeAwareModule.STDIN, Junction.INPUT, teeMerge );
		}
		
		/**
		 * List Notification Interests.
		 * <P>
		 * Adds subclass interests to those of the JunctionMediator.</P>
		 */
		override public function listNotificationInterests():Array
		{
			var interests:Array = super.listNotificationInterests();
			interests.push(CircleMakerFacade.EXPORT_CIRLE_BUTTON);
			interests.push(CircleMakerFacade.CLICK_COUNT_CHANGED);
			return interests;
		}

		/**
		 * Handle Junction related Notifications for the LoggerModule.
		 * <P>
		 * For the Logger, this consists of exporting the
		 * LogButton and LogWindow in a PipeMessage to STDSHELL, 
		 * as well as the ordinary JunctionMediator duties of 
		 * accepting input and output pipes from the Shell.</P>
		 * <P>
		 * It handles accepting input pipes instead of letting
		 * the superclass do it because the STDIN to the logger
		 * is Merging Tee and not a pipe, so the details of 
		 * connecting it differ.</P>
		 */		
		override public function handleNotification( note:INotification ):void
		{
			
			switch( note.getName() )
			{
				// Send the LogWindow UI Component 
				case CircleMakerFacade.CLICK_COUNT_CHANGED:
					trace("CircleMakerJunctionMediator.CLICK_COUNT_CHANGED:", note.getBody());
					const moduleKey:String = note.getType();
					const clickCount:int = int(note.getBody());
					sendNotification(LogMessage.SEND_TO_LOG, moduleKey + " - Circle Button clicked: " + clickCount + " times", LogMessage.LEVELS[LogMessage.INFO]);
					break;
				case CircleMakerFacade.EXPORT_CIRLE_BUTTON:
					trace("CircleMakerJunctionMediator.EXPORT_CIRLE_BUTTON:", note.getBody());
					const circleMakerMessage:UIQueryMessage = new UIQueryMessage( UIQueryMessage.SET, CircleMakerModule.MESSAGE_TO_SHELL_CIRCLE_MAKER_BUTTON, note.getBody() as DisplayObject );
					junction.sendMessage( PipeAwareModule.STDSHELL, circleMakerMessage );
					break;
				// And let super handle the rest (ACCEPT_OUTPUT_PIPE)								
				default:
					super.handleNotification(note);
			}
		}
		
		/**
		 * Handle incoming pipe messages.
		 */
		override public function handlePipeMessage( message:IPipeMessage ):void
		{
			
		}
	}
}