package org.tbyrne.siteStream.objectTests
{
	import org.tbyrne.siteStream.AbstractXmlReaderTest;

	public class TypedVectorTest2 extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return 	<test:TestObject xmlns:test="org.tbyrne.siteStream" vector="[{property:0},{property:1}]"/>;
		}
		
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.vector && object.vector.length==2 && object.vector[0].property==0 && object.vector[1].property==1);
		}
	}
}