package org.tbyrne.siteStream.xmlTests.summaryTests
{
	import org.tbyrne.siteStream.xmlTests.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.core.ISSNodeSummary;

	public class UrlTest extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <Object xmlns:s="http://www.tbyrne.org/sitestream" s:url="hi"/>;
		}
		
		override public function testSummary(summary:ISSNodeSummary):Boolean{
			return summary.url=="hi";
		}
	}
}