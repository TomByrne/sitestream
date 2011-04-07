package org.tbyrne.siteStream.xmlTest.detailsTests
{
	import org.tbyrne.siteStream.xmlTest.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.core.ISSNodeDetails;

	public class LibraryNodeTest1 extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <Object xmlns:s="http://www.tbyrne.org/sitestream">
						<s:libs>
							<String>common.swf</String>
							<String>other.swf</String>
						</s:libs>
					</Object>;
		}
		
		override public function checkDetails():Boolean{
			return true;
		}
		override public function testDetails(details:ISSNodeDetails):Boolean{
			return (details.libraries && details.libraries[0]=="common.swf" && details.libraries[1]=="other.swf");
		}
	}
}