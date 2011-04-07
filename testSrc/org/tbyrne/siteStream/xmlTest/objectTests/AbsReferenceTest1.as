package org.tbyrne.siteStream.xmlTest.objectTests
{
	import flash.display.Sprite;
	
	import org.tbyrne.siteStream.xmlTest.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.TestObject;

	public class AbsReferenceTest1 extends AbstractXmlReaderTest
	{
		public function AbsReferenceTest1(){
			var includeClass:TestObject;
		}
		override public function get xml():XML{
			return 	<test:TestObject xmlns:test="org.tbyrne.siteStream" xmlns:s="http://www.tbyrne.org/sitestream" sprite="{x:500}" parameter="(sprite.x)">
				</test:TestObject>;
		}
								
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			var testObject:TestObject = (object as TestObject);
			return (testObject.property==500);
		}
	}
}