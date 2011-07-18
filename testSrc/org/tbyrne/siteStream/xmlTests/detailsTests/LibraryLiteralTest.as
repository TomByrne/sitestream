package org.tbyrne.siteStream.xmlTests.detailsTests
{
	import org.tbyrne.siteStream.xmlTests.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.core.ISSNodeDetails;
	
	public class LibraryLiteralTest extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <Object xmlns:s="http://www.tbyrne.org/sitestream" s:libs="[common.swf,other.swf]"/>;
		}
		
		override public function checkDetails():Boolean{
			return true;
		}
		override public function testDetails(details:ISSNodeDetails):Boolean{
			return (details.libraries && details.libraries[0]=="common.swf" && details.libraries[1]=="other.swf");
		}
	}
}