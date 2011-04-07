package org.tbyrne.siteStream.xmlTest.objectTests
{
	import org.tbyrne.siteStream.xmlTest.AbstractXmlReaderTest;

	public class TypedArrayTest2 extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return 	<test:TestObject xmlns:test="org.tbyrne.siteStream">
						<array>
							<Number>0</Number>
							<Number>1</Number>
							<Number>2</Number>
						</array>
					</test>;
		}
		
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.array && object.array.length==3 && object.array[0]==0 && object.array[1]==1 && object.array[2]==2);
		}
	}
}