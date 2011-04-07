package org.tbyrne.siteStream.xmlTest.objectTests
{
	import org.tbyrne.siteStream.TestObject;
	import org.tbyrne.siteStream.xmlTest.AbstractXmlReaderTest;

	public class PropertySetterTest extends AbstractXmlReaderTest
	{
		public function PropertySetterTest(){
			var includeClass:Class = TestObject;
		}
		
		override public function get xml():XML{
			return <test:TestObject xmlns:test="org.tbyrne.siteStream" setProperty="123"/>;
		}
		
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.property==123);
		}
	}
}