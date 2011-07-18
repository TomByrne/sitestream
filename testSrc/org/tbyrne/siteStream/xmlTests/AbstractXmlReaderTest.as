package org.tbyrne.siteStream.xmlTests
{
	import org.tbyrne.siteStream.core.ISSNodeDetails;
	import org.tbyrne.siteStream.core.ISSNodeSummary;

	public class AbstractXmlReaderTest implements IXmlReaderTest
	{
		public function get xml():XML{
			return null;
		}
		public function AbstractXmlReaderTest(){
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