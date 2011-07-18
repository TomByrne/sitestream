package org.tbyrne.siteStream.xmlTests.objectTests
{
	import flash.display.Sprite;
	
	import org.tbyrne.siteStream.xmlTests.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.TestObject;
	
	public class UntypedMethodSetterTest3 extends AbstractXmlReaderTest
	{
		public function UntypedMethodSetterTest3()
		{
			super();
			TestObject;
		}
		override public function get xml():XML{
			return <test:TestObject xmlns:test="org.tbyrne.siteStream" xmlns:s="http://www.tbyrne.org/sitestream" setGetSprite="{x:20}"/>;
		}
		
		override public function checkObject():Boolean{
			return true; 
		}
		override public function testObject(object:*):Boolean{
			return (object is TestObject) && (object.sprite is Sprite) && (object.sprite.x==20);
		}
	}
}