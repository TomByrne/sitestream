package org.tbyrne.siteStream.xmlTests.objectTests
{
	import flash.display.Sprite;
	
	import org.tbyrne.siteStream.xmlTests.AbstractXmlReaderTest;

	public class AbsReferenceTest2 extends AbstractXmlReaderTest
	{
		public function AbsReferenceTest2(){
		}
		override public function get xml():XML{
			return <Object xmlns:s="http://www.tbyrne.org/sitestream">
			
						<Object s:path="node" s:id="child1">
							<reference>(//node.child2)</reference>
							<Object s:id="child2"/>
						</Object>
					</Object>
		}
								
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.child1.reference && object.child1.child2==object.child1.reference);
		}
	}
}