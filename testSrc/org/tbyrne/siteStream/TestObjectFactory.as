package org.tbyrne.siteStream
{
	public class TestObjectFactory
	{
		public var sprite:Sprite;
		
		public function TestObjectFactory()
		{
		}
		
		public function createTestObject():TestObject{
			return new TestObject(sprite);
		}
		public function returnTestObject(value:TestObject):void{
			// ignore
		}
	}
}