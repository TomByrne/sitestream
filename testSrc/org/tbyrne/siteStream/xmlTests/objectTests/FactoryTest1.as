package org.tbyrne.siteStream.xmlTests.objectTests
{
	import org.tbyrne.siteStream.SSObjectPool;
	import org.tbyrne.siteStream.TestObject;
	import org.tbyrne.siteStream.TestObjectFactory;
	import org.tbyrne.siteStream.xmlTests.AbstractXmlReaderTest;

	public class FactoryTest1 extends AbstractXmlReaderTest
	{
		public function FactoryTest1()
		{
			super();
			TestObject;
			TestObjectFactory;
			SSObjectPool;
		}
		override public function get xml():XML{
			return <Object xmlns:test="org.tbyrne.siteStream" xmlns:ss="org.tbyrne.siteStream" xmlns:display="flash.display" xmlns:s="http://www.tbyrne.org/sitestream">
						<s:pools>
							<ss:SSObjectPool classpath="org.tbyrne.siteStream.TestObject">
								<props>
									<display:Sprite s:id="sprite" x="20"/>
								</props>
							</ss:SSObjectPool>
						</s:pools>

						<test:TestObject s:id="test1"/>
						<test:TestObject s:id="test2"/>
					</Object>
			
		}
		
		override public function checkObject():Boolean{
			return true; 
		}
		override public function testObject(object:*):Boolean{
			return (object.test1 && object.test1.sprite && object.test1.sprite==object.test2.sprite && object.test1.sprite.x==20);
		}
	}
}