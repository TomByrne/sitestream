package org.tbyrne.siteStream
{
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;

	public class TestObject
	{
		public function TestObject(sprite:Sprite=null, type:Class=null, property:*=null){
			this.sprite = sprite;
			this.type = type;
			this.property = property;
		}
		
		
		public var type:Class;
		
		public var property:*;
		
		public var sprite:Sprite;
		
		public var array:Array;
		
		public var vector:Vector.<TestObject>;
		
		public function setProperty(property:*):void{
			this.property = property;
		}
		public function setSprite(sprite:Sprite):void{
			this.sprite = sprite;
		}
		public function setSpriteInt(sprite:IBitmapDrawable):void{
			this.sprite = sprite as Sprite;
		}
		public function getProperty():*{
			return property;
		}
		public function setGetProperty(property:*):*{
			this.property = property;
			return property;
		}
		public function setGetSprite(sprite:Sprite, type:Class=null):Sprite{
			this.sprite = sprite;
			this.type = type;
			return sprite;
		}
	}
}