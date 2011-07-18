package org.tbyrne.siteStream.xmlTests.objectTests
{
	import flash.display.Sprite;
	
	import org.tbyrne.siteStream.xmlTests.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.TestObject;

	public class TypedReferenceMethodTest1 extends AbstractXmlReaderTest
	{
		public function TypedReferenceMethodTest1(){
			var includeClass:TestObject;
		}
		override public function get xml():XML{
			return 	<Object xmlns:test="org.tbyrne.siteStream" xmlns:s="http://www.tbyrne.org/sitestream" property="(testObject.setGetSprite({x:200}))">
						<test:TestObject s:id="testObject"/>
					</Object>
		}
								
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.property.x==200);
		}
	}
}