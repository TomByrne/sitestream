package org.tbyrne.siteStream.xmlTests.objectTests
{
	import org.tbyrne.siteStream.xmlTests.AbstractXmlReaderTest;

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