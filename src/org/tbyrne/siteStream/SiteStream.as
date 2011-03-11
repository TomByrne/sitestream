package org.tbyrne.siteStream
{
	import org.tbyrne.core.IPendingResult;

	public class SiteStream
	{
		public function get rootNode():ISiteStreamNode{
			return _nodeProvider;
		}
		public function set rootNode(value:ISiteStreamNode):void{
			if(_nodeProvider!=value){
				_nodeProvider = value;
			}
		}
		
		private var _nodeProvider:ISiteStreamNode;
		
		public function SiteStream(rootNode:ISiteStreamNode=null){
			this.rootNode = rootNode;
		}
		
		public function getObject(path:String):IPendingResult{
			return null;
		}
		public function releaseObject(path:String):IPendingResult{
			return null;
		}
		public function getPath(object:Object):String{
			return null;
		}
	}
}