package org.tbyrne.siteStream.core
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.hoborg.ObjectPool;
	
	public class PropDetails{
		private static const pool:ObjectPool = new ObjectPool(PropDetails);

		public static function getNew():PropDetails{
			var ret:PropDetails = pool.takeObject();
			ret.pool = pool;
			return ret;
		}
		
		
		/**
		 * handler(from:PropDetails)
		 */
		public function get afterCommitted():IAct{
			return (_afterCommitted || (_afterCommitted = new Act()));
		}
		
		protected var _afterCommitted:Act;
		
		public function get object():*{
			return _object;
		}
		public function set object(value:*):void{
			_object = value;
		}
		public function get childProps():Vector.<PropDetails>{
			return _childProps;
		}
		
		public function get committed():Boolean{
			return _committed;
		}
		public function set committed(value:Boolean):void{
			_committed = value;
			if(_afterCommitted)_afterCommitted.perform(this);
		}
		
		private var _object:*;
		private var _committed:Boolean;
		
		public var isLibrary:Boolean;
		public var parentSetterIsConstructor:Boolean;
		public var parentSetterIsMethod:Boolean;
		//public var parentSetterArgs:Array;
		public var parentIsVector:Boolean;
		//public var parentSetterIndex:int = -1;
		public var parentSetter:*;
		public var classPath:String;
		public var parent:PropDetails;
		//public var parentObject:*;
		public var data:Object;
		public var interpretted:Boolean;
		public var completed:Boolean;
		public var type:Class;
		public var node:NodeDetails;
		
		// mapped methodName > int
		//public var methodArgsCounts:Dictionary;
		
		public var simpleValue:*;
		
		
		protected var _childProps:Vector.<PropDetails>;
		
		internal var pool:ObjectPool;
		
		public function PropDetails(){
			_childProps = new Vector.<PropDetails>();
		}
		
		public function addChildProp(childProp:PropDetails):void{
			childProp.parent = this;
			_childProps.push(childProp);
		}
		public function removeChildProp(childProp:PropDetails):void{
			if(childProp.parent==this){
				childProp.parent = null;
				var index:int = _childProps.indexOf(childProp);
				_childProps.splice(index,1);
			}
		}
		
		public function release(deepRelease:Boolean):void{
			if(deepRelease){
				for each(var child:PropDetails in _childProps){
					child.release(true);
				}
				_childProps = new Vector.<PropDetails>();
			}
			//xml = null;
			//parentSetterArgs = null;
			parentIsVector = false;
			parent = null;
			//parentObject = null;
			simpleValue = null;
			parentSetter = null;
			classPath = null;
			//methodArgsCounts = null;
			//parentSetterIndex = -1;
			parentSetterIsMethod = false;
			parentSetterIsConstructor = false;
			interpretted = false;
			isLibrary = false;
			pool.releaseObject(this);
		}
	}
}