package org.tbyrne.siteStream.xmlTest.objectTests
{
	import org.tbyrne.siteStream.xmlTest.AbstractXmlReaderTest;

	public class NativeObjectNodeTest extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <Object/>;
		}
		
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object is Object);
		}
	}
}