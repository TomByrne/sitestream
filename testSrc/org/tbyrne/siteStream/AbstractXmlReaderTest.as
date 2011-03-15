package org.tbyrne.siteStream
{
	import org.tbyrne.siteStream.xml.IXmlNodeDetails;
	import org.tbyrne.siteStream.xml.IXmlNodeSummary;

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
		
		public function testSummary(summary:IXmlNodeSummary):Boolean{
			return true;
		}
		public function testDetails(details:IXmlNodeDetails):Boolean{
			return true;
		}
		public function testObject(object:*):Boolean{
			return true;
		}
	}
}