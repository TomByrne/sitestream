package org.tbyrne.siteStream
{
	import org.tbyrne.siteStream.core.PropDetails;

	public interface ISSObjectPool
	{
		function doesMatch(propDetails:PropDetails):Boolean;
		function create():*;
		function destroy(object:*):void;
	}
}