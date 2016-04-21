package nest.services.worker.swf {
	
	/** 
	 *
	 * The DynamicSWF is a class for generating swf bytes code from defined classname
	 *
	 */	 
	
	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.data.SWFSymbol;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagSymbolClass;
	
	import flash.utils.ByteArray;

	public class DynamicSWF
	{
		
		/**
		 * Creates a Dynamic SWF from defined Class name.
		 * @param className the Class to create
		 * @param bytes SWF ByteArray which must contain the Class definition (usually loaderInfo.bytes)
		 * @return the new SWF ByteArray
		 */
		
		public static function fromClass(className:String, bytes:ByteArray):ByteArray {
			const 
				swf		: SWF = new SWF(bytes),
				tags	: Vector.<ITag> = swf.tags
			;
				
			var len		: uint = tags.length,
				tag		: TagSymbolClass,
				symbols	: Vector.<SWFSymbol>,
				symbol	: SWFSymbol
			;
			bytes = new ByteArray();
			while(len--) {
				tag = tags[len] as TagSymbolClass;
				if (tag) {
					symbols = tag.symbols;
					for each (symbol in symbols) {
						if (symbol.tagId == 0) {
							symbol.name = className;
							swf.publish(bytes);
							bytes.position = 0;
							return bytes;
						}
					}
				}
			}
			return null;
		}
	}
}