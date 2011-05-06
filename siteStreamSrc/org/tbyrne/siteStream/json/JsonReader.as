package org.tbyrne.siteStream.json
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.siteStream.core.AbstractReader;
	import org.tbyrne.siteStream.core.IPendingSSResult;
	import org.tbyrne.siteStream.core.ISSNodeDetails;
	import org.tbyrne.siteStream.core.ISSNodeSummary;
	import org.tbyrne.siteStream.core.NodeDetails;
	import org.tbyrne.siteStream.core.PropDetails;

	public class JsonReader extends AbstractReader
	{
		private static const VECTOR_TEST_1:RegExp = /\[class Vector\.<(.*)>\]/;
		private static const JSON_NS:String = "jsns";
		
		
		
		public var metadataNamespace:String;
		
		private var _metadataNSPrefix:String;
		
		// mapped prefix > package
		private var packages:Dictionary;
		
		
		public function JsonReader(cacheResults:Boolean=false){
			super(cacheResults);
			
			packages = new Dictionary();
		}
		
		public function readRootNode(json:Object):ISSNodeSummary{
			var namespaces:Object = getChildrenWithNS(json,JSON_NS);
			for(var prop:String in namespaces){
				var value:String = namespaces[prop];
				if(value!=metadataNamespace){
					packages[prop] = value;
				}else{
					_metadataNSPrefix = prop;
				}
			}
			
			return super._readRootNode(json);
		}
		public function readNodeDetails(json:Object, summary:ISSNodeSummary):IPendingSSResult{
			return super._readNodeDetails(json, summary);
		}
		public function readObject(summary:ISSNodeSummary, oldObject:Object):IPendingSSResult{
			return super._readObject(summary, oldObject);
		}
		
		
		
		override protected function getPathIdForData(data:Object, nodeDetails:ISSNodeDetails):String{
			var pathId:String = getChildWithNS(data,pathIdAttribute,_metadataNSPrefix) as String;
			if(!pathId || !pathId.length){
				if(nodeDetails){
					// this is the root node and we should force it to have an empty path
					return "";
				}else{
					return null;
				}
			}
			return pathId;
		}
		override protected function getUrlForData(data:Object):String{
			return getChildWithNS(data,urlAttribute,_metadataNSPrefix) as String;
		}
		override protected function assessClassProp(data:Object, propDetails:PropDetails):void{
			/*var xml:XML = (data as XML);
			var parentPropName:String;
			var classPath:String;
			if(xml.nodeKind()==XMLNodeKinds.ATTRIBUTE){
				parentPropName = xml.name();
			}else if(xml.nodeKind()==XMLNodeKinds.ELEMENT && xml.namespace()!=metadataNamespace){
				var packageName:String;
				packageName = cleanPackageName(xml.namespace());
				parentPropName = getChildWithNS(xml,propAttribute,metadataNamespace);
				
				
				var nodeName:String = xml.localName();
				if(nodeName){
					if(packageName){
						classPath = packageName+nodeName;
					}else if((!parentPropName || !parentPropName.length) && !ReflectionUtils.doesClassExist(nodeName)){
						parentPropName = nodeName;
					}else{
						classPath = nodeName;
					}
				}
			}
			propDetails.parentSetter = parentPropName;
			propDetails.classPath = classPath;*/
		}
		override protected function getStringValue(data:Object):String{
			/*var xml:XML = (data as XML);
			var nodeKind:String = xml.nodeKind();
			if(nodeKind==XMLNodeKinds.ATTRIBUTE){
				return xml.toString();
			}else if(nodeKind==XMLNodeKinds.ELEMENT){
				return xml.text();
			}else{
				// other XML types are not yet supported
				return null;
			}*/
			return null;
		}
		override protected function createLibraries(data:Object, nodeDetails:NodeDetails):void{
			/*var xml:XML = (data as XML);
			var attList:XMLList = xml.attribute(new QName(metadataNamespace,libsAttribute));
			var eleList:XMLList = xml.child(new QName(metadataNamespace,libsAttribute));
			createXMLChildren(nodeDetails,nodeDetails,attList,eleList,null,nodeDetails,false,"libraries");*/
			nodeDetails.checkLibraries();
		}
		override protected function createChildren(data:Object, simpleValue:*, parentClass:Class, parentNode:NodeDetails, propDetails:PropDetails):void{
			/*var xml:XML = (data as XML);
			var attList:XMLList;
			var eleList:XMLList;
			if(xml){
				attList = xml.attributes();
				eleList = xml.elements();
			}
			createXMLChildren(propDetails,parentNode,attList,eleList,simpleValue,object,true,null);*/
		}
		override protected function createChildNodes(data:Object, nodeDetails:NodeDetails):void{
			/*var xml:XML = (data as XML);
			var list:XMLList = xml.descendants(); // we're building an assumption in here that only elements can be nodes (for speed)
			var l:int = list.length(); 
			for(var i:int=0; i<l; ++i){
				var memberXML:XML = list[i];
				var childNode:NodeDetails = assessNodeSummary(memberXML,null);
				if(childNode){
					nodeDetails.addChildNode(childNode);
				}
			}*/
		}
		
		
		
		
		
		/*protected function createXMLChildren(parentProp:PropDetails, parentNode:NodeDetails, attList:XMLList, eleList:XMLList, simpleValue:*, parentObject:*, filterMetadata:Boolean, overrideParentSetter:String):void{
			if(!simpleValue && !attList.length() && !eleList.length())return;
			
			var added:Vector.<PropDetails> = new Vector.<PropDetails>();
			createChildList(attList,eleList,simpleValue,parentObject,added,filterMetadata);
			
			if(added.length){
				for each(var propDetails:PropDetails in added){
					addChildProp(propDetails,parentProp);
				}
			}
		}*/
		/*protected function createChildList(attList:XMLList, eleList:XMLList,simpleValue:*, parentObject:*, added:Vector.<PropDetails>, filterMetadata:Boolean):void{
			var doAtt:Boolean = (attList && attList.length());
			var doEle:Boolean = (eleList && eleList.length());
			
			if(doEle || doAtt || simpleValue!=null){
				var parentClass:Class = (parentObject.constructor);
				var isArray:Boolean = (parentClass == Array);
				
				var isVector:Boolean;
				//var vectorType:String;
				if(!isArray){
					var vectorMatch:Object = VECTOR_TEST_1.exec(String(parentClass));
					isVector = vectorMatch!=null;
				}
				
				if(doAtt)createChildListFromXML(attList,parentObject,added,filterMetadata,parentClass,isArray,isVector);
				if(doEle)createChildListFromXML(eleList,parentObject,added,filterMetadata,parentClass,isArray,isVector);
				if(simpleValue){
					createChildListFromSimpleValue(simpleValue,parentObject,added,filterMetadata,parentClass,isArray,isVector);
				}
			}
		}*/
		/*protected function createChildListFromXML(xmlList:XMLList, parentObject:*, added:Vector.<PropDetails>, filterMetadata:Boolean, parentClass:Class, isArray:Boolean, isVector:Boolean):void{
			var l:int = xmlList.length();
			for(var i:int=0; i<l; ++i){
				var memberXML:XML = xmlList[i];
				
				if(filterMetadata && memberXML.namespace()==metadataNamespace){
					continue;
				}
				
				var nodeDetails:NodeDetails = assessNodeSummary(memberXML,null);
				var propDetails:PropDetails = assessRefAndDetails(memberXML,nodeDetails);
				if(propDetails){
					childListAdd(propDetails, nodeDetails, isArray, isVector, added);
				}
			}
		}*/
		
		
		protected function getChildWithNS(data:Object, attName:String, metadataNSPrefix:String):Object{
			if(typeof(data)=="object"){
				for(var i:String in data){
					var colon:int = i.indexOf(":");
					if(colon!=-1){
						var ns:String = i.slice(0,colon);
						var prop:String = i.slice(colon+1);
						if(ns==metadataNSPrefix && prop==attName){
							return data[i];
						}
					}
				}
			}
			return null;
		}
		protected function getChildrenWithNS(data:Object, metadataNSPrefix:String):Object{
			if(typeof(data)=="object"){
				var ret:Object;
				for(var i:String in data){
					var colon:int = i.indexOf(":");
					if(colon!=-1){
						var ns:String = i.slice(0,colon);
						var prop:String = i.slice(colon+1);
						if(ns==metadataNSPrefix){
							if(!ret)ret = {};
							ret[prop] = data[i];
						}
					}
				}
				return ret;
			}
			return null;
		}
	}
}