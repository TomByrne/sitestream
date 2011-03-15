package org.tbyrne.siteStream.core
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.siteStream.ISiteStreamNode;

	
	public class SiteStreamNodeProxy implements ISiteStreamNode
	{
		/**
		 * @inheritDoc
		 */
		public function get objectReadyChanged():IAct{
			return (_objectReadyChanged || (_objectReadyChanged = new Act()));
		}
		/**
		 * @inheritDoc
		 */
		public function get childNodesChanged():IAct{
			return (_childNodesChanged || (_childNodesChanged = new Act()));
		}
		
		protected var _childNodesChanged:Act;
		protected var _objectReadyChanged:Act;
		
		
		
		
		public function get pathId():String{
			return _target.pathId;
		}
		
		public function get childNodes():Vector.<ISiteStreamNode>{
			return _target.childNodes;
		}
		
		public function get objectReady():Boolean{
			return _target.objectReady;
		}
		public function get object():*{
			return _target.object;
		}
		
		
		protected var _target:ISiteStreamNode;
		
		
		
		public function requestObject():void{
			_target.requestObject();
		}
		public function releaseObject():void{
			_target.releaseObject();
		}
		
		
		protected function setTarget(node:ISiteStreamNode):void{
			if(_target!=node){
				if(_target){
					_target.childNodesChanged.removeHandler(onChildNodesChanged);
					_target.objectReadyChanged.removeHandler(onObjectReadyChanged);
				}
				_target = node;
				if(_target){
					_target.childNodesChanged.addHandler(onChildNodesChanged);
					_target.objectReadyChanged.addHandler(onObjectReadyChanged);
				}
			}
		}
		protected function onChildNodesChanged(from:ISiteStreamNode):void{
			if(_childNodesChanged)_childNodesChanged.perform(this);
		}
		protected function onObjectReadyChanged(from:ISiteStreamNode):void{
			if(_objectReadyChanged)_objectReadyChanged.perform(this);
		}
		
	}
}