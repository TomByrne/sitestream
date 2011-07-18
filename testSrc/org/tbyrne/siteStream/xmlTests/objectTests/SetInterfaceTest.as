package org.tbyrne.siteStream.xmlTests.objectTests
{
	import org.tbyrne.siteStream.TestObject;
	import org.tbyrne.siteStream.xmlTests.AbstractXmlReaderTest;

	public class SetInterfaceTest extends AbstractXmlReaderTest
	{
		public function SetInterfaceTest(){
			var includeClass:TestObject;
		}
		override public function get xml():XML{
			return 	<test:TestObject xmlns:test="org.tbyrne.siteStream" xmlns:display="flash.display.*" xmlns:s="http://www.tbyrne.org/sitestream">
						<display:Sprite s:id="setSpriteInt" x="30"/>
					</test>;
		}
		
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			var test:TestObject = (object as TestObject);
			return (test && test.sprite && test.sprite.x==30);
		}
	}
}