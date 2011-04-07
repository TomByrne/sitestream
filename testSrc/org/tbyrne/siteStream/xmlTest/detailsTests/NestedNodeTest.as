package org.tbyrne.siteStream.xmlTest.detailsTests
{
	import org.tbyrne.siteStream.xmlTest.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.core.ISSNodeDetails;

	public class NestedNodeTest extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <Object xmlns:s="http://www.tbyrne.org/sitestream">
						<Object s:path="child1"/>
						<Object>
							<Object s:path="child2"/>
						</Object>
					</Object>;
		}
		
		override public function checkDetails():Boolean{
			return true;
		}
		override public function testDetails(details:ISSNodeDetails):Boolean{
			return (details.childNodes.length==2 && details.childNodes[0].pathId=="child1" && details.childNodes[1].pathId=="child2");
		}
	}
}