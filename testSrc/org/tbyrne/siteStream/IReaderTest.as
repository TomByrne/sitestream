package org.tbyrne.siteStream
{
	import org.tbyrne.siteStream.core.ISSNodeDetails;
	import org.tbyrne.siteStream.core.ISSNodeSummary;

	public interface IReaderTest
	{
		function checkDetails():Boolean;
		function checkObject():Boolean;
		
		function testSummary(summary:ISSNodeSummary):Boolean;
		function testDetails(details:ISSNodeDetails):Boolean;
		function testObject(object:*):Boolean;
	}
}