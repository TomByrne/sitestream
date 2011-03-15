package org.tbyrne.siteStream.summaryTests
{
	import org.tbyrne.siteStream.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.xml.IXmlNodeSummary;

	public class XmlUrlTest extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <Object xmlns:s="http://www.tbyrne.org/sitestream" s:url="hi"/>;
		}
		
		override public function testSummary(summary:IXmlNodeSummary):Boolean{
			return summary.xmlUrl=="hi";
		}
	}
}