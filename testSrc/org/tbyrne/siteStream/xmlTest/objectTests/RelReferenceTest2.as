package org.tbyrne.siteStream.xmlTest.objectTests
{
	import flash.display.Sprite;
	
	import org.tbyrne.siteStream.xmlTest.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.TestObject;

	public class RelReferenceTest2 extends AbstractXmlReaderTest
	{
		public function RelReferenceTest2(){
		}
		override public function get xml():XML{
			return <Object xmlns:s="http://www.tbyrne.org/sitestream" s:path="root">
			
						<Object s:id="child1">
							<Object s:id="child2">
								<reference>(../../node.refChild2)</reference>
							</Object>
						</Object>
			
						<Object s:path="node" s:id="refChild1">
							<Object s:id="refChild2">
							</Object>
						</Object>
					</Object>
		}
								
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.child1.child2.reference && object.refChild1.refChild2==object.child1.child2.reference);
		}
	}
}