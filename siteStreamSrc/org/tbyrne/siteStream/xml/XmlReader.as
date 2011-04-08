package org.tbyrne.siteStream.xml
{
	import flash.xml.XMLNodeKinds;
	
	import org.tbyrne.reflection.ReflectionUtils;
	import org.tbyrne.siteStream.core.AbstractReader;
	import org.tbyrne.siteStream.core.IPendingSSResult;
	import org.tbyrne.siteStream.core.ISSNodeDetails;
	import org.tbyrne.siteStream.core.ISSNodeSummary;
	import org.tbyrne.siteStream.core.NodeDetails;
	import org.tbyrne.siteStream.core.PropDetails;
	import org.tbyrne.siteStream.core.ReferenceDetails;

	public class XmlReader extends AbstractReader
	{
		private static const VECTOR_TEST_1:RegExp = /\[class Vector\.<(.*)>\]/;
		
		
		public var metadataNamespace:String;
		
		public function XmlReader(cacheResults:Boolean=false){
			super(cacheResults);
		}
		
		public function readRootNode(xml:XML):ISSNodeSummary{
			return super._readRootNode(xml);
		}
		public function readNodeDetails(xml:XML, summary:ISSNodeSummary):IPendingSSResult{
			return super._readNodeDetails(xml, summary);
		}
		public function readObject(summary:ISSNodeSummary, oldObject:Object):IPendingSSResult{
			return super._readObject(summary, oldObject);
		}
		
		
		override protected function getPathIdForData(data:Object, nodeDetails:ISSNodeDetails):String{
			var xml:XML = (data as XML);
			if(xml.nodeKind()==XMLNodeKinds.ELEMENT){
				var pathId:String = getChildWithNS(xml,pathIdAttribute,metadataNamespace);
				if(!pathId || !pathId.length){
					if(nodeDetails){
						// this is the root node and we should force it to have an empty path
						return "";
					}else{
						return null;
					}
				}
				return pathId;
			}else{
				// other XML types are not nodes
				return null;
			}
		}
		override protected function getUrlForData(data:Object):String{
			var xml:XML = (data as XML);
			return getChildWithNS(xml,urlAttribute,metadataNamespace);
		}
		override protected function assessClassProp(data:Object, propDetails:PropDetails):void{
			var xml:XML = (data as XML);
			var parentPropName:String;
			var classPath:String;
			if(xml.nodeKind()==XMLNodeKinds.ATTRIBUTE){
				parentPropName = xml.name();
			}else{
				var ns:Namespace = xml.namespace();
				if(xml.nodeKind()==XMLNodeKinds.ELEMENT && (!ns || ns.uri!=metadataNamespace)){
					var packageName:String;
					if(ns)packageName = cleanPackageName(ns.uri);
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
			}
			propDetails.parentSetter = parentPropName;
			propDetails.classPath = classPath;
		}
		override protected function getStringValue(data:Object):String{
			var xml:XML = (data as XML);
			var nodeKind:String = xml.nodeKind();
			if(nodeKind==XMLNodeKinds.ATTRIBUTE){
				return xml.toString();
			}else if(nodeKind==XMLNodeKinds.ELEMENT){
				return xml.text();
			}else{
				// other XML types are not yet supported
				return null;
			}
		}
		override protected function createLibraries(data:Object, nodeDetails:NodeDetails):void{
			var xml:XML = (data as XML);
			var attList:XMLList = xml.attribute(new QName(metadataNamespace,libsAttribute));
			var eleList:XMLList = xml.child(new QName(metadataNamespace,libsAttribute));
			createXMLChildren(nodeDetails,nodeDetails,attList,eleList,null,nodeDetails,false,"libraries");
			nodeDetails.checkLibraries();
		}
		override protected function createChildren(data:Object, simpleValue:*, object:*, parentNode:NodeDetails, propDetails:PropDetails):void{
			var xml:XML = (data as XML);
			var attList:XMLList;
			var eleList:XMLList;
			if(xml){
				attList = xml.attributes();
				eleList = xml.elements();
			}
			createXMLChildren(propDetails,parentNode,attList,eleList,simpleValue,object,true,null);
		}
		override protected function createChildNodes(data:Object, nodeDetails:NodeDetails):void{
			var xml:XML = (data as XML);
			var list:XMLList = xml.descendants(); // we're building an assumption in here that only elements can be nodes (for speed)
			var l:int = list.length(); 
			for(var i:int=0; i<l; ++i){
				var memberXML:XML = list[i];
				var childNode:NodeDetails = assessNodeSummary(memberXML,null);
				if(childNode){
					nodeDetails.addChildNode(childNode);
				}
			}
		}
		
		
		
		
		
		protected function createXMLChildren(parentProp:PropDetails, parentNode:NodeDetails, attList:XMLList, eleList:XMLList, simpleValue:*, parentObject:*, filterMetadata:Boolean, overrideParentSetter:String):void{
			if(!simpleValue && !attList.length() && !eleList.length())return;
			
			var added:Vector.<PropDetails> = new Vector.<PropDetails>();
			createChildList(attList,eleList,simpleValue,parentObject,added,filterMetadata);
			
			if(added.length){
				for each(var propDetails:PropDetails in added){
					propDetails.parentObject = parentObject;
					
					if(overrideParentSetter){
						propDetails.parentSetter = overrideParentSetter;
					}
					
					var childNode:NodeDetails = (propDetails as NodeDetails);
					
					if(childNode){
						parentNode.addChildNode(childNode);
					}else{
						var refDetails:ReferenceDetails = (propDetails as ReferenceDetails);
						if(refDetails)parentNode.addChildRef(refDetails);
					}
					if(propDetails.parentSetter!=null){
						parentProp.addChildProp(propDetails);
						reassessClassProp(propDetails.data,propDetails,parentNode,parentObject);
					}
				}
			}
		}
		protected function createChildList(attList:XMLList, eleList:XMLList,simpleValue:*, parentObject:*, added:Vector.<PropDetails>, filterMetadata:Boolean):void{
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
					/*
					// this doesn't work, Vector type is always *
					if(isVector){
						vectorType = vectorMatch[1];
						if(vectorType=="*")vectorType = null;
					}*/
				}
				
				if(doAtt)createChildListFromXML(attList,parentObject,added,filterMetadata,parentClass,isArray,isVector);
				if(doEle)createChildListFromXML(eleList,parentObject,added,filterMetadata,parentClass,isArray,isVector);
				if(simpleValue){
					createChildListFromSimpleValue(simpleValue,parentObject,added,filterMetadata,parentClass,isArray,isVector);
				}
			}
		}
		protected function createChildListFromXML(xmlList:XMLList, parentObject:*, added:Vector.<PropDetails>, filterMetadata:Boolean, parentClass:Class, isArray:Boolean, isVector:Boolean):void{
			var l:int = xmlList.length();
			for(var i:int=0; i<l; ++i){
				var memberXML:XML = xmlList[i];
				
				var ns:Namespace = memberXML.namespace();
				if(filterMetadata && ns && ns.uri==metadataNamespace){
					continue;
				}
				
				var nodeDetails:NodeDetails = assessNodeSummary(memberXML,null);
				var propDetails:PropDetails = assessRefAndDetails(memberXML,nodeDetails);
				if(propDetails){
					childListAdd(propDetails, nodeDetails, isArray, isVector, added);
				}
			}
		}
		
		
		protected function getChildWithNS(xml:XML, attName:String, metadataNamespace:String):XMLList{
			var qName:QName = new QName(metadataNamespace,attName);
			var attList:XMLList = xml.attribute(qName);
			if(attList.length()){
				return attList;
			}else{
				var eleList:XMLList = xml.child(qName);
				if(eleList.length()){
					return eleList;
				}else{
					return null;
				}
			}
		}
	}
}