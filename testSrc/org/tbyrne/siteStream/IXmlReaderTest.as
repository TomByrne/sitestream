package org.tbyrne.siteStream
{
	import org.tbyrne.siteStream.xml.IXmlNodeDetails;
	import org.tbyrne.siteStream.xml.IXmlNodeSummary;

	public interface IXmlReaderTest
	{
		function get xml():XML;
		
		function checkDetails():Boolean;
		function checkObject():Boolean;
		
		function testSummary(summary:IXmlNodeSummary):Boolean;
		function testDetails(details:IXmlNodeDetails):Boolean;
		function testObject(object:*):Boolean;
	}
}