package org.tbyrne.siteStream.objectTests
{
	import flash.display.Sprite;
	
	import org.tbyrne.siteStream.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.TestObject;
	
	public class UntypedMethodSetterTest2 extends AbstractXmlReaderTest
	{
		public function UntypedMethodSetterTest2()
		{
			super();
			TestObject;
		}
		override public function get xml():XML{
			return <test:TestObject xmlns:test="org.tbyrne.siteStream" xmlns:s="http://www.tbyrne.org/sitestream" setGetSprite="[{x:20},flash.display.Sprite]"/>;
		}
		
		override public function checkObject():Boolean{
			return true; 
		}
		override public function testObject(object:*):Boolean{
			return (object is TestObject) && (object.sprite is Sprite) && (object.sprite.x==20) && (object.type==Sprite);
		}
	}
}