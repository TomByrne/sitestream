package org.tbyrne.siteStream.xmlTest.objectTests
{
	import flash.display.Sprite;
	
	import org.tbyrne.siteStream.xmlTest.AbstractXmlReaderTest;

	public class RelReferenceTest1 extends AbstractXmlReaderTest
	{
		public function RelReferenceTest1(){
		}
		override public function get xml():XML{
			return <Object xmlns:s="http://www.tbyrne.org/sitestream" s:path="root">
			
						<Object s:path="node" s:id="child1">
							<reference>(child2.child3)</reference>
							<Object s:id="child2">
								<Object s:id="child3">
								</Object>
							</Object>
						</Object>
					</Object>
		}
								
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.child1.reference && object.child1.child2.child3==object.child1.reference);
		}
	}
}