package org.tbyrne.siteStream.jsonTest.summaryTests
{
	import org.tbyrne.siteStream.core.ISSNodeSummary;
	import org.tbyrne.siteStream.jsonTest.AbstractJsonReaderTest;

	public class UrlTest extends AbstractJsonReaderTest
	{
		override public function get json():String{
			return "{'jsns:s':'http://www.tbyrne.org/sitestream','s:url':'hi'}";
		}
		
		override public function testSummary(summary:ISSNodeSummary):Boolean{
			return summary.url=="hi";
		}
	}
}