package org.tbyrne.siteStream.objectTests
{
	import org.tbyrne.siteStream.AbstractXmlReaderTest;

	public class ArrayLiteralTest extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <Object test="[4,4]"/>;
		}
		
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.test is Array);
		}
	}
}