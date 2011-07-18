package org.tbyrne.siteStream.jsonTests.summaryTests
{
	import org.tbyrne.siteStream.core.ISSNodeSummary;
	import org.tbyrne.siteStream.jsonTests.AbstractJsonReaderTest;

	public class PathIdTest extends AbstractJsonReaderTest
	{
		override public function get json():String{
			return "{'jsns:s':'http://www.tbyrne.org/sitestream','s:path':'hi'}";
		}
		
		override public function testSummary(summary:ISSNodeSummary):Boolean{
			return summary.pathId=="hi";
		}
	}
}