package org.tbyrne.siteStream.xml
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IXmlPendingResult
	{
		
		/**
		 * handler(from:IXmlPendingResult)
		 */
		function get succeeded():IAct;
		/**
		 * handler(from:IXmlPendingResult)
		 */
		function get failed():IAct;
		function get result():*;
		
		function begin():void;
	}
}