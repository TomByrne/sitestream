package org.tbyrne.siteStream.xmlTest.objectTests
{
	import flash.display.Sprite;
	
	import org.tbyrne.siteStream.xmlTest.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.TestObject;

	public class ReferenceMethodTest1 extends AbstractXmlReaderTest
	{
		public function ReferenceMethodTest1(){
			var includeClass:TestObject;
		}
		override public function get xml():XML{
			return 	<Object xmlns:test="org.tbyrne.siteStream" xmlns:s="http://www.tbyrne.org/sitestream" property="(testObject.setGetProperty(3))">
						<test:TestObject s:id="testObject"/>
					</Object>
		}
								
		override public function checkObject():Boolean{
			return true;
		}
		override public function testObject(object:*):Boolean{
			return (object.property==3);
		}
	}
}