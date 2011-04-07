package org.tbyrne.siteStream.core
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IPendingSSResult
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