package org.tbyrne.siteStream.objectTests
{
	import org.tbyrne.siteStream.TestObject;
	import org.tbyrne.siteStream.AbstractXmlReaderTest;

	public class ClassAttributeTest extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <test:TestObject xmlns:test="org.tbyrne.siteStream" type="org.tbyrne.siteStream.tests.TestObject"/>;
		}
		
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.type == TestObject);
		}
	}
}