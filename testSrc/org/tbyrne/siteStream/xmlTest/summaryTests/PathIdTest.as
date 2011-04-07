package org.tbyrne.siteStream.xmlTest.summaryTests
{
	import org.tbyrne.siteStream.xmlTest.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.core.ISSNodeSummary;

	public class PathIdTest extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <Object xmlns:s="http://www.tbyrne.org/sitestream" s:path="hi"/>;
		}
		
		override public function testSummary(summary:ISSNodeSummary):Boolean{
			return summary.pathId=="hi";
		}
	}
}