package org.tbyrne.siteStream
{
	import flash.display.Sprite;

	public class TestObject
	{
		
		public var type:Class;
		
		public var property:*;
		
		public var sprite:Sprite;
		
		public var array:Array;
		
		public var vector:Vector.<TestObject>;
		
		public function setProperty(property:*):void{
			this.property = property;
		}
	}
}