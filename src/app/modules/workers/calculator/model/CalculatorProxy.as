package app.modules.workers.calculator.model
{
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	public final class CalculatorProxy extends Proxy
	{
		public static const NAME:String = 'CalculatorProxy';
		
		public function CalculatorProxy()
		{
			super(NAME, new uint());
		}
		
		public function callHappend():void 
		{
			data += 1;
		}
		
		public function get callCounter():uint 
		{
			return uint(data);
		}
	}
}