package org.tbyrne.siteStream.xmlTest.objectTests
{
	import org.tbyrne.siteStream.xmlTest.AbstractXmlReaderTest;

	public class ObjectLiteralTest extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <Object child="{}"/>;
		}
		
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.child is Object);
		}
	}
}