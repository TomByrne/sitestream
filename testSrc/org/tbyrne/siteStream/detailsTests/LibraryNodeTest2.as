package org.tbyrne.siteStream.detailsTests
{
	import org.tbyrne.siteStream.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.xml.IXmlNodeDetails;

	public class LibraryNodeTest2 extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <Object xmlns:s="http://www.tbyrne.org/sitestream">
						<s:libs>common.swf</s:libs>
						<s:libs>other.swf</s:libs>
					</Object>;
		}
		
		override public function checkDetails():Boolean{
			return true;
		}
		override public function testDetails(details:IXmlNodeDetails):Boolean{
			return (details.libraries && details.libraries[0]=="common.swf" && details.libraries[1]=="other.swf");
		}
	}
}