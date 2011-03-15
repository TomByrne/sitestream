package org.tbyrne.siteStream.objectTests
{
	import org.tbyrne.siteStream.AbstractXmlReaderTest;

	public class PropertySetterTest extends AbstractXmlReaderTest
	{
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