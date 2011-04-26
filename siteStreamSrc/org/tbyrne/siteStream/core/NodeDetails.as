package org.tbyrne.siteStream.core
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.hoborg.ObjectPool;

	public class NodeDetails extends PropDetails implements ISSNodeSummary, ISSNodeDetails{
		private static const pool:ObjectPool = new ObjectPool(NodeDetails);
		public static function getNew():NodeDetails{
			var ret:NodeDetails = pool.takeObject();
			ret.pool = pool;
			return ret;
		}
		
		
		/**
		 * handler(from:NodeDetails, interpretBundle:InterpretBundle)
		 */
		public function get requestInterpret():IAct{
			return _requestInterpret;
		}
		
		protected var _requestInterpret:Act = new Act();
		
		
		
		public function get detailsPending():IPendingSSResult{
			return _detailsBundle;
		}
		public function get objectPending():IPendingSSResult{
			return _objectBundle;
		}
		public function get nonRefPending():IPendingSSResult{
			return _nonRefBundle;
		}
		public function get pathId():String{
			return _pathId;
		}
		public function set pathId(value:String):void{
			_pathId = value;
		}
		
		public function get url():String{
			return _xmlUrl;
		}
		public function set url(value:String):void{
			_xmlUrl = value;
		}
		
		public function get childNodes():Vector.<ISSNodeSummary>{
			return _childNodes;
		}
		
		public function get childReferences():Vector.<ReferenceDetails>{
			return _childReferences;
		}
		
		public function get libraries():Vector.<String>{
			return _libraries;
		}
		public function set libraries(value:Vector.<String>):void{
			_libraries = value;
		}
		override public function set object(value:*):void{
			super.object = value;
			_objectBundle.result = value;
			_nonRefBundle.result = value;
		}
		
		private var _detailsBundle:InterpretBundle;
		private var _objectBundle:InterpretBundle;
		private var _nonRefBundle:InterpretBundle;
		
		private var _childNodes:Vector.<ISSNodeSummary>;
		private var _childNodesCast:Vector.<NodeDetails>;
		private var _childReferences:Vector.<ReferenceDetails>;
		private var _xmlUrl:String;
		private var _pathId:String;
		
		//private var _nonRefChildren:Vector.<PropDetails>;
		
		//private var _libraryProps:Vector.<PropDetails>;
		private var _libraries:Vector.<String>;
		
		public function NodeDetails(){
			super();
			//_nonRefChildren = new Vector.<PropDetails>();
			_childNodes = new Vector.<ISSNodeSummary>();
			_childNodesCast = new Vector.<NodeDetails>();
			_childReferences = new Vector.<ReferenceDetails>();
			
			_detailsBundle = new InterpretBundle(this);
			_detailsBundle.beginRequested.addHandler(onDetailsRequested);
			
			_objectBundle = new InterpretBundle();
			_objectBundle.beginRequested.addHandler(onObjectRequested);
			_objectBundle.addProp(this);
			
			_nonRefBundle = new InterpretBundle();
			_nonRefBundle.beginRequested.addHandler(onNonRefRequested);
		}
		override public function addChildProp(childProp:PropDetails):void{
			super.addChildProp(childProp);
			if(!(childProp is ReferenceDetails)){
				_nonRefBundle.addProp(childProp);
			}
			if(_libraries && childProp.parentObject==_libraries){
				_detailsBundle.addProp(childProp);
			}
		}
		
		public function checkLibraries():void{
			
			_detailsBundle.clearProps();
			
			for each(var propDetails:PropDetails in _childProps){
				if(propDetails.parentObject==this && 
					propDetails.parentSetter=="libraries"){
					
					_detailsBundle.addProp(propDetails);
				}
			}
		}
		protected function onDetailsRequested(from:InterpretBundle):void{
			if(_detailsBundle.invalid){
				_detailsBundle.performSuceeded();
			}else{
				//_detailsBundle.interpretting = true;
				_requestInterpret.perform(this,_detailsBundle);
			}
		}
		
		protected function onObjectRequested(from:InterpretBundle):void{
			if(_objectBundle.invalid){
				_objectBundle.performSuceeded();
			}else{
				//_objectBundle.interpretting = true;
				_requestInterpret.perform(this,_objectBundle);
			}
		}
		protected function onNonRefRequested(from:InterpretBundle):void{
			if(_nonRefBundle.invalid){
				_nonRefBundle.performSuceeded();
			}else{
				//_nonRefBundle.interpretting = true;
				_requestInterpret.perform(this,_nonRefBundle);
			}
		}
		
		public function addChildNode(childNode:NodeDetails):void{
			childNode.parent = this;
			_childNodes.push(childNode);
		}
		public function addChildRef(childNode:ReferenceDetails):void{
			childNode.parent = this;
			_childReferences.push(childNode);
		}
		
		
		override public function release(deepRelease:Boolean):void{
			super.release(deepRelease);
			
			if(deepRelease){
				for each(var childNode:NodeDetails in _childNodesCast){
					childNode.release(true);
				}
				for each(var childRef:ReferenceDetails in _childReferences){
					childRef.release(true);
				}
				_childNodes = new Vector.<ISSNodeSummary>();
				_childNodesCast = new Vector.<NodeDetails>();
				_childReferences = new Vector.<ReferenceDetails>();
				//_nonRefChildren = new Vector.<PropDetails>();
				//_libraryProps = new Vector.<PropDetails>();
			}
			_pathId = null;
			_xmlUrl = null;
			_libraries = null;
			_requestInterpret.removeAllHandlers();
			_detailsBundle.release();
			_objectBundle.release();
			_nonRefBundle.release();
		}
	}

}