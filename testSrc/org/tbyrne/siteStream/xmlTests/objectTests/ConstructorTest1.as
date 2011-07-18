package org.tbyrne.siteStream.xmlTests.objectTests
{
	import flash.display.Sprite;
	
	import org.tbyrne.siteStream.xmlTests.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.TestObject;

	public class ConstructorTest1 extends AbstractXmlReaderTest
	{
		public function ConstructorTest1(){
			var includeClass:TestObject;
		}
		override public function get xml():XML{
			return 	<test:TestObject xmlns:test="org.tbyrne.siteStream" xmlns:display="flash.display" xmlns:s="http://www.tbyrne.org/sitestream">
						<s:init>
							<display:Sprite x='20'/>
							<Class><![CDATA[flash.display.Sprite]]></Class>
							<Number>1</Number>
						</s:init>
				</test:TestObject>;
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