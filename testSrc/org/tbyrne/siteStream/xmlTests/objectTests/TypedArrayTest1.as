package org.tbyrne.siteStream.xmlTests.objectTests
{
	import org.tbyrne.siteStream.TestObject;
	import org.tbyrne.siteStream.xmlTests.AbstractXmlReaderTest;

	public class TypedArrayTest1 extends AbstractXmlReaderTest
	{
		public function TypedArrayTest1(){
			var includeClass:TestObject;
		}
		override public function get xml():XML{
			return 	<test:TestObject xmlns:test="org.tbyrne.siteStream">
						<array>[0,1,2]</array>
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