package org.tbyrne.siteStream.objectTests
{
	import org.tbyrne.siteStream.AbstractXmlReaderTest;

	public class TypedObjectLiteralTest extends AbstractXmlReaderTest
	{
		override public function get xml():XML{
			return <test:TestObject xmlns:test="org.tbyrne.siteStream" sprite="{x:10}"/>;
		}
		
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.sprite && object.sprite.x==10);
		}
	}
}