package org.tbyrne.siteStream.jsonTest.summaryTests
{
	import org.tbyrne.siteStream.core.ISSNodeSummary;
	import org.tbyrne.siteStream.jsonTest.AbstractJsonReaderTest;

	public class PathIdTest extends AbstractJsonReaderTest
	{
		override public function get json():String{
			return "{'jsonns:s':'http://www.tbyrne.org/sitestream','s:path':'hi'}";
		}
		
		override public function testSummary(summary:ISSNodeSummary):Boolean{
			return summary.pathId=="hi";
		}
	}
}