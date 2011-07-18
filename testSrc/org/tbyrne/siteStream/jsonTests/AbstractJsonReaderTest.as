package org.tbyrne.siteStream.jsonTests
{
	import org.tbyrne.siteStream.core.ISSNodeDetails;
	import org.tbyrne.siteStream.core.ISSNodeSummary;

	public class AbstractJsonReaderTest implements IJsonReaderTest
	{
		public function get json():String{
			return null;
		}
		public function AbstractJsonReaderTest(){
		}
		
		public function checkDetails():Boolean{
			return false;
		}
		public function checkObject():Boolean{
			return false;
		}
		
		public function testSummary(summary:ISSNodeSummary):Boolean{
			return true;
		}
		public function testDetails(details:ISSNodeDetails):Boolean{
			return true;
		}
		public function testObject(object:*):Boolean{
			return true;
		}
	}
}