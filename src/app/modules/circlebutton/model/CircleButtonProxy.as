/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.modules.circlebutton.model
{
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class CircleButtonProxy extends Proxy
	{
        public static const NAME:String = 'CircleMakerProxy';

		private var _clickCount:uint;
		
		public function CircleButtonProxy()
        {
            super( NAME, new Array() );
        }
		
		override public function onRegister():void 
		{
			_clickCount = 0;
		}
        
        public function clickHappend():void
        {
        	_clickCount++;
        }
		
		public function get clickCount():uint 
		{
			return _clickCount;
		}
	}
}