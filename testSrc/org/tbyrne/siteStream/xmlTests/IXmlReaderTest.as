package org.tbyrne.siteStream.xmlTests
{
	import org.tbyrne.siteStream.IReaderTest;
	import org.tbyrne.siteStream.core.ISSNodeDetails;
	import org.tbyrne.siteStream.core.ISSNodeSummary;

	public interface IXmlReaderTest extends IReaderTest
	{
		function get xml():XML;
		
	}
}