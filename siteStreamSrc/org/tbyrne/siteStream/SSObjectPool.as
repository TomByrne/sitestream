package org.tbyrne.siteStream
{
	import org.tbyrne.reflection.ReflectionUtils;
	import org.tbyrne.siteStream.core.PropDetails;
	import org.tbyrne.utils.constructorApply;

	public class SSObjectPool implements ISSObjectPool
	{
		
		public function get classpath():String{
			return _classpath;
		}
		public function set classpath(value:String):void{
			if(_classpath!=value){
				_classpath = value;
				_class = null;
				_pool = [];
			}
		}
		
		public var constructorArgs:Array;
		public var props:Object;
		
		private var _classpath:String;
		private var _class:Class;
		private var _pool:Array;
		
		
		public function doesMatch(type:Class):Boolean{
			if(_class==null){
				_class = ReflectionUtils.getClassByName(_classpath);
			}
			return (type==_class);
		}
		public function create():*{
			if(_classpath==null){
				throw new Error("SSObjectPool.create: classpath was not specified");
			}else{
				if(_class==null){
					_class = ReflectionUtils.getClassByName(_classpath);
				}
				var ret:*;
				if(_pool.length){
					ret = _pool.pop();
				}else{
					ret = constructorApply(_class,constructorArgs);
				}
				for(var i:String in props){
					ret[i] = props[i];
				}
				return ret;
			}
		}
		public function destroy(object:*):void{
			_pool.push(object);
			for(var i:String in props){
				object[i] = null;
			}
		}
	}
}