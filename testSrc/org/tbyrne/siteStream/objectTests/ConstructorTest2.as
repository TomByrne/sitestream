package org.tbyrne.siteStream.objectTests
{
	import flash.display.Sprite;
	
	import org.tbyrne.siteStream.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.TestObject;

	public class ConstructorTest2 extends AbstractXmlReaderTest
	{
		public function ConstructorTest2(){
			var includeClass:TestObject;
		}
		override public function get xml():XML{
			return 	<test:TestObject xmlns:test="org.tbyrne.siteStream" xmlns:display="flash.display" xmlns:s="http://www.tbyrne.org/sitestream"
							s:init="[{x:20}, flash.display.Sprite, 1]"/>;
		}
		
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			var testObject:TestObject = (object as TestObject);
			return (testObject.sprite && testObject.sprite.x==20 && testObject.type==Sprite && testObject.property==1);
		}
	}
}