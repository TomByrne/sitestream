package org.tbyrne.siteStream.xmlTests.objectTests
{
	import flash.display.Sprite;
	
	import org.tbyrne.siteStream.xmlTests.AbstractXmlReaderTest;
	import org.tbyrne.siteStream.TestObject;

	public class ReferenceMethodTest2 extends AbstractXmlReaderTest
	{
		public function ReferenceMethodTest2(){
			var includeClass:TestObject;
		}
		override public function get xml():XML{
			return 	<Object xmlns:test="org.tbyrne.siteStream" xmlns:s="http://www.tbyrne.org/sitestream" property="(testObject.getProperty())">
						<test:TestObject s:id="testObject" property="3"/>
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