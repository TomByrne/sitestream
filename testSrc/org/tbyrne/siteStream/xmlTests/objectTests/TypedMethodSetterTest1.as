package org.tbyrne.siteStream.xmlTests.objectTests
{
	import flash.display.Sprite;
	
	import org.tbyrne.siteStream.xmlTests.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.TestObject;
	
	public class TypedMethodSetterTest1 extends AbstractXmlReaderTest
	{
		public function TypedMethodSetterTest1()
		{
			super();
			TestObject;
		}
		override public function get xml():XML{
			return <test:TestObject xmlns:test="org.tbyrne.siteStream" xmlns:display="flash.display" xmlns:s="http://www.tbyrne.org/sitestream">
						<display:Sprite s:id="setSprite"/>
					</test:TestObject>;
		}
		
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object is TestObject) && (object.sprite is Sprite);
		}
	}
}