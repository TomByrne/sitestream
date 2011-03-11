package org.tbyrne.siteStream
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface ISiteStreamNode
	{
		function get pathId():String;
		
		/**
		 * handler(from:INodeProvider)
		 */
		function get childNodesChanged():IAct;
		function get childNodes():Vector.<ISiteStreamNode>;
		
		/**
		 * handler(from:INodeProvider)
		 */
		function get objectReadyChanged():IAct;
		function get objectReady():Boolean;
		function get object():*;
		
		
		function requestObject():void;
		function releaseObject():void;
		
	}
}