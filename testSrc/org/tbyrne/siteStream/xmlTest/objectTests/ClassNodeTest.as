package org.tbyrne.siteStream.xmlTest.objectTests
{
	import org.tbyrne.siteStream.TestObject;
	import org.tbyrne.siteStream.xmlTest.AbstractXmlReaderTest;

	public class ClassNodeTest extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <test:TestObject xmlns:test="org.tbyrne.siteStream" xmlns:s="http://www.tbyrne.org/sitestream">
						<test:TestObject s:id="type"/>
					</test:TestObject>;
		}
		
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.type == TestObject);
		}
	}
}