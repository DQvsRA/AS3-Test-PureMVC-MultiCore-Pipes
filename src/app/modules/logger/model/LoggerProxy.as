/*
 PureMVC AS3 MultiCore Demo – Flex PipeWorks 
 Copyright (c) 2008 Cliff Hall <cliff.hall@puremvc.org>
 Your reuse is governed by the Creative Commons Attribution 3.0 License
 */
package app.modules.logger.model
{
	import app.common.LogMessage;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public class LoggerProxy extends Proxy
	{
        public static const NAME:String = 'LoggerProxy';

		public function LoggerProxy()
        {
            super( NAME, new Array() );
        }
        
        public function addLog(message:LogMessage):void
        {
        	messages.push(message);
        }
		
		public function get messages():Array
		{
			return data as Array;
		}
	}
}