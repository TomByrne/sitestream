package org.tbyrne.siteStream.xml
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.xml.XMLNodeKinds;
	
	import org.tbyrne.core.IPendingResult;
	import org.tbyrne.memory.LooseReference;
	import org.tbyrne.reflection.ReflectionUtils;

	/**
	 * A utility class used to step through XML and generate IXmlElementInfo objects
	 *  
	 * @author Tom Byrne
	 * 
	 */
	public class XmlReader
	{
		private static const NODE_REFERENCE_EXP:RegExp = /^\((\S*)\)$/;
		private static const VECTOR_TEST_1:RegExp = /\[class Vector\.<(.*)>\]/;
		private static const VECTOR_TEST_2:RegExp = /__AS3__\.vec::Vector\.<(.*)>/;
		
		private static const PROP_REPLACE:Number = Math.random(); // a unique tag
		
		/**
		 * Determines whether IXmlNodeSummary and IXmlNodeDetails objects should be
		 * stored internally to link up reference nodes. If the XMLReader instance is
		 * being used as a parsing utility for XML chunks with no references then
		 * this can be set to false to reduce memory footprint. Internal references
		 * to objects are loose references, meaning that if all other references to these
		 * objects are removed then these too will be removed.
		 * 
		 */
		public function get cacheResults():Boolean{
			return _cacheResults;
		}
		public function set cacheResults(value:Boolean):void{
			if(_cacheResults!=value){
				_cacheResults = value;
				if(value)_cache = new Dictionary();
				else{
					for each(var looseRef:LooseReference in _cache){
						looseRef.release();
					}
					_cache = new Dictionary();
				}
			}
		}
		
		public var pathIdAttribute:String = "path";
		public var propAttribute:String = "id";
		public var libsAttribute:String = "libs";
		public var xmlUrlAttribute:String = "url";
		public var metadataNamespace:Namespace;
		
		private var _cacheResults:Boolean;
		
		/* mapped xml > LooseReference(NodeDetails)
		Note that multiple xml instances can reference the same NodeDetails object
		*/
		private var _cache:Dictionary;
		
		public function XmlReader(cacheResults:Boolean=false){
			this.cacheResults = cacheResults;
			_cache = new Dictionary();
		}
		
		
		
		
		
		public function readRootNode(xml:XML):IXmlNodeSummary{
			var ret:NodeDetails = getNodeDetails(xml);
			assessNodeSummary(xml,ret);
			return ret;
		}
		protected function assessNodeSummary(xml:XML, nodeDetails:NodeDetails):NodeDetails{
			var pathId:String;
			var useNode:Boolean = false;
			
			if(xml.nodeKind()==XMLNodeKinds.ELEMENT){
				var packageName:String = cleanPackageName(xml.namespace());
				pathId = getChildWithNS(xml,pathIdAttribute,metadataNamespace);
				if(!pathId || !pathId.length){
					if(nodeDetails){
						// this is the root node and we should force it to have an empty path
						pathId = "";
					}else{
						return null;
					}
				}
			}else{
				// other XML types are not nodes
				return null;
			}
			
			if(!nodeDetails)nodeDetails = getNodeDetails(xml);
			nodeDetails.xmlUrl = getChildWithNS(xml,xmlUrlAttribute,metadataNamespace);
			nodeDetails.pathId = pathId;
			nodeDetails.xml = xml;
			assessClassProp(xml, nodeDetails); // allows us to know whether this node fills one of it's parent's props
			
			return nodeDetails;
		}
		protected function assessClassProp(xml:XML, propDetails:PropDetails):void{
			var parentPropName:String;
			var classPath:String;
			if(xml.nodeKind()==XMLNodeKinds.ATTRIBUTE){
				parentPropName = xml.name();
			}else if(xml.nodeKind()==XMLNodeKinds.ELEMENT){
				
				var packageName:String = cleanPackageName(xml.namespace());
				parentPropName = getChildWithNS(xml,propAttribute,metadataNamespace);
				
				var nodeName:String = xml.localName();
				if((!parentPropName || !parentPropName.length) && !packageName && !ReflectionUtils.getClassByName(nodeName)){
					parentPropName = nodeName;
				}else{
					classPath = nodeName;
				}
				if(packageName)classPath = packageName+classPath;
			}
			propDetails.parentSetter = parentPropName;
			propDetails.classPath = classPath;
		}
		
		
		
		
		
		
		public function readNodeDetails(xml:XML, summary:IXmlNodeSummary):IPendingResult{
			var ret:NodeDetails = summary as NodeDetails;
			ret.xml = xml;
			assessRefAndDetails(xml,ret);
			return ret.detailsPending;
		}
		protected function assessRefAndDetails(xml:XML, propDetails:PropDetails):PropDetails{
			var useReference:Boolean = false;
			var stringValue:String;
			
			if(xml.nodeKind()==XMLNodeKinds.ATTRIBUTE){
				stringValue = xml.toString();
			}else if(xml.nodeKind()==XMLNodeKinds.ELEMENT){
				stringValue = xml.text();
			}else{
				// other XML types are not yet supported
				return null;
			}
			
			if(stringValue && stringValue.length){
				var refTest:Object = NODE_REFERENCE_EXP.test(stringValue);
				if(refTest){
					useReference = true;
					stringValue = refTest[1];
				}
			}
			
			if(!propDetails){
				if(useReference){
					propDetails = ReferenceDetails.getNew();
				}else{
					propDetails = PropDetails.getNew();
				}
				propDetails.xml = xml;
				assessClassProp(xml, propDetails);
			}else{
				var nodeDetails:NodeDetails = (propDetails as NodeDetails);
				if(nodeDetails){
					createLibraries(xml, nodeDetails);
					createChildNodes(xml, nodeDetails);
				}
			}
			propDetails.stringValue = stringValue;
			
			return propDetails;
		}
		private function createLibraries(xml:XML, nodeDetails:NodeDetails):void{
			var attList:XMLList = xml.attribute(new QName(metadataNamespace,libsAttribute));
			var eleList:XMLList = xml.child(new QName(metadataNamespace,libsAttribute));
			var libs:Vector.<String> = new Vector.<String>();
			nodeDetails.libraries = libs;
			createChildren(nodeDetails,nodeDetails,attList,eleList,libs);
		}
		private function createChildren(parentProp:PropDetails,parentNode:NodeDetails, attList:XMLList, eleList:XMLList, parentObject:*):void{
			var added:Vector.<PropDetails> = new Vector.<PropDetails>();
			if(attList)createChildList(attList,parentObject.constructor,added);
			if(eleList)createChildList(eleList,parentObject.constructor,added);
			
			for each(var propDetails:PropDetails in added){
				var childNode:NodeDetails = (propDetails as NodeDetails);
				
				var subParentNode:NodeDetails = parentNode;
				
				if(childNode){
					parentNode.addChildNode(childNode);
					if(!propDetails.parentSetter)subParentNode = childNode;
				}else{
					var refDetails:ReferenceDetails = (propDetails as ReferenceDetails);
					if(refDetails)parentNode.addChildRef(refDetails);
				}
				if(propDetails.parentSetter){
					parentNode.addChildProp(propDetails);
				}
				
				
				if(propDetails.xml)reassessClassProp(propDetails.xml,propDetails,subParentNode,parentObject);
			}
		}
		private function createChildList(xmlList:XMLList, parentClass:Class, added:Vector.<PropDetails>):void{
			var isArray:Boolean = (parentClass == Array);
			
			var isVector:Boolean;
			var vectorType:String;
			if(!isArray){
				var vectorMatch:Object = VECTOR_TEST_1.exec(String(parentClass));
				isVector = vectorMatch!=null;
				if(isVector){
					vectorType = vectorMatch[1];
					if(vectorType=="*")vectorType = null;
				}
			}
			
			var l:int = xmlList.length();
			for(var i:int=0; i<l; ++i){
				var memberXML:XML = xmlList[i];
				var nodeDetails:NodeDetails = assessNodeSummary(memberXML,null);
				var propDetails:PropDetails = assessRefAndDetails(memberXML,nodeDetails);
				if(propDetails){
					var denyAdd:Boolean;
					if((isArray || isVector) && propDetails.stringValue){
						if(attemptLiteralParse(propDetails, nodeDetails, isArray, isVector, vectorType, added)){
							denyAdd = true;
						}
					}
					if(!denyAdd){
						childListAdd(propDetails, nodeDetails, isArray, isVector, vectorType, added)
					}
				}
			}
		}
		private function attemptLiteralParse(propDetails:PropDetails, nodeDetails:NodeDetails, isArray:Boolean, isVector:Boolean, vectorType:String, added:Vector.<PropDetails>):Boolean{
			var array:Array = attemptArrayParse(propDetails.stringValue);
			var ret:Boolean;
			if(array){
				ret = true;
				for each(var string:String in array){
					var subPropDetails:PropDetails = PropDetails.getNew();
					subPropDetails.stringValue = string;
					childListAdd(subPropDetails, null, isArray, isVector, vectorType, added)
				}
			}
			return ret;
		}
		private function childListAdd(propDetails:PropDetails, nodeDetails:NodeDetails, isArray:Boolean, isVector:Boolean, vectorType:String, added:Vector.<PropDetails>):void{
			if(!propDetails.parentSetter){
				if(isArray || isVector){
					propDetails.parentSetterIsMethod = true;
					propDetails.parentSetter = "splice";
					propDetails.parentSetterArgs = [added.length,0,PROP_REPLACE];
					if(isVector && !propDetails.classPath)propDetails.classPath = vectorType;
				}
			}
			added.push(propDetails);
		}
		private function createChildNodes(xml:XML, nodeDetails:NodeDetails):void{
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
		
		
		
		
		
		public function readObject(summary:IXmlNodeSummary, oldObject:Object):IPendingResult{
			var ret:NodeDetails = summary as NodeDetails;
			var parentObject:*;
			if(ret.parent){
				parentObject = ret.parent.object;
			}
			reassessClassProp(ret.xml, ret, ret, parentObject);
			//createObject(ret);
			return ret;
		}
		protected function reassessClassProp(xml:XML, propDetails:PropDetails, parentNode:NodeDetails, parentObject:*):void{
			/*
				Initially, we get the parentPropName and classpath from the node but do not
				check it for deep references, this allows us to check early on whether a node
				must be fully parsed for it's parent object's sake. Then (here) we analyse the
				two variables to clean them up.
			*/
			var isClassRef:Boolean;
			var parentPropName:String = propDetails.parentSetter;
			var classPath:String = propDetails.classPath;
			var hasParent:Boolean = (parentObject && parentPropName && parentPropName.length);
			//var isWriteOnly:Boolean = false;
			var varType:Class;
			if(hasParent){
				
				var typeDesc:XML = getTypeDescription(parentObject);
				
				// Do the check for deep properties. i.e. s:prop="rootProp.parentProp.childProp"
				var varPath: Array = parentPropName.split(".");
				var parentTypeDesc: XML = typeDesc;
				var dynamicMode:Boolean;
				var typeName:String;
				while (varPath.length > 0){
					
					var thisPropName:String = varPath.shift();
					
					varType = null;
					if(parentTypeDesc){
						typeName = getVariableType(parentTypeDesc, thisPropName);
						if(typeName && typeName.length){
							//typeName = typeName.replace("::",".");
							varType = ReflectionUtils.getClassByName(typeName);
							//if(!varPath.length)isWriteOnly = (parentTypeDesc..accessor.(@name==thisPropName).@access=="writeonly");
						}
					}
					
					if(!varPath.length && !propDetails.classPath){
						typeName = typeDesc.@name;
						var vectorMatch:Object = VECTOR_TEST_2.exec(typeName);
						if(vectorMatch!=null){
							propDetails.classPath = vectorMatch[1];
							if(propDetails.classPath=="*")propDetails.classPath = null;
						}
					}
					
					if(!varType){
						var value:* = parentObject[thisPropName];
						if(value is Function){
							propDetails.parentSetterIsMethod = true;
							break;
						}else{
							varType = value.constructor;
						}
					}
					
					if(!varType){
						if(parentTypeDesc.@isDynamic.toString()!="true"){
							var msg: String = "Couldn't map element \"" + thisPropName + "\"";
							msg += " to object: "+ parentObject;
							Log.error( "XmlReader.reassessClassProp: "+msg);
						}
						break;
					}else if(varPath.length){
						parentTypeDesc = getTypeDescription(varType);
						parentObject = parentObject[thisPropName];
					}
				}
				parentPropName = thisPropName;
				isClassRef = (varType==Class);
			}
			
			propDetails.parentSetter = parentPropName;
			propDetails.parentObject = parentObject;
			
			var type:Class;
			if(propDetails.classPath){
				type = ReflectionUtils.getClassByName(propDetails.classPath);
			}else{
				type = varType;
			}
				
			var object: *;
			var stringValue:String = propDetails.stringValue;
			if(isClassRef){
				object = type;
			}else{
				switch(type){
					case XML:
						object = new XML(stringValue);
						break;
					case String:
						object = stringValue;
						break;
					case Number:
						if (stringValue.indexOf("0x") == 0) {
							object = Number(stringValue);
						}else if (stringValue.indexOf("#") == 0) {
							object = Number("0x" + stringValue.substring(1));
						}else if (stringValue.toLowerCase() == "nan") {
							object = NaN;
						} else {
							object = parseFloat(stringValue);
						}
						break;
					case int:
					case uint:
						object = parseInt(stringValue);
						break;
					case Boolean:
						object = (stringValue.toLowerCase()=="true");
						break;
					case Function:
						// TODO: Need to consider package functions, which will look similiar to static functions
						// e.g.		flash.utils.myFunction
						//			flash.utils.FuncClass.myFunction
						var methodSepIndex: int = stringValue.lastIndexOf(".");
						if (methodSepIndex < 0){
							object = ReflectionUtils.getFunctionByName(stringValue);
						}else{
							var functionName: String = stringValue.substr(methodSepIndex + 1, stringValue.length);
							var className: String = stringValue.substring(0, methodSepIndex);
							var methodClass: Class = ReflectionUtils.getClassByName(className);
							try{
								object = methodClass[functionName] as Function;
							}catch (e: ReferenceError){
								Log.error("Function " + stringValue + " is not defined");
							}
						}
						break;
					default:
						object = propDetails.object;
						if(!object || !(object is type)){
							object = new type();
						}
				}
			}
			var attList:XMLList = xml.attributes();
			var eleList:XMLList = xml.elements();
			createChildren(propDetails,parentNode,attList,eleList,object);
			
			propDetails.object = object;
		}
		
		
		
		protected function getChildWithNS(xml:XML, attName:String, metadataNamespace:Namespace):XMLList{
			var attList:XMLList = xml.attribute(new QName(metadataNamespace,attName));
			if(attList.length()){
				return attList;
			}else{
				var eleList:XMLList = xml.child(new QName(metadataNamespace,attName));
				if(eleList.length()){
					return eleList;
				}else{
					return null;
				}
			}
		}
		/**
		 * cleanPackageName will clean a package name into a format which can then be 
		 * prepended to a class name and reference via ReflectionUtils.getClassByName().
		 */
		private function cleanPackageName(packageName:String):String{
			if(packageName.charAt(packageName.length-1)=="*")packageName = packageName.slice(0,packageName.length-1);
			if(packageName.charAt(packageName.length-1)==".")packageName = packageName.slice(0,packageName.length-1);
			if(packageName.length)packageName+=".";
			return packageName;
		}
		/**
		 * getVariableType returns a classpath as found within a class description.
		 * They're in the form 'flash.display::BitmapData'.
		 */
		protected function getVariableType(desc:XML, varName:String):String{
			var xml:XMLList = desc..variable.(@name==varName).@type;
			var type:String = xml.toString();
			if(type && type.length)return type;
			else{
				xml = desc..accessor.(@name==varName).@type;
				if(xml.length()>0){
					type = xml[0].toString();
				}else{
					type = null;
				}
				if(type && type.length)return type;
				else return null;
			}
		}
		
		protected function getTypeDescription(object:Object):XML{
			return ReflectionUtils.describeType(object is String?String:object);
		}
		
		protected function getNodeDetails(xml:XML):NodeDetails{
			var looseRef:LooseReference = _cache[xml];
			var ret:NodeDetails;
			if(!looseRef){
				ret = NodeDetails.getNew();
				_cache[xml] = new LooseReference(ret);
			}else if(looseRef.referenceExists){
				ret = looseRef.reference as NodeDetails;
			}else{
				ret = NodeDetails.getNew();
				looseRef.object = ret;
			}
			return ret;
		}
		
		protected function attemptArrayParse(string:String):Array{
			var lastChar:int = string.length-1;
			if(string.charAt(0)=="[" && string.charAt(lastChar)=="]"){
				var ret:Array = [];
				var pos:int=1;
				var open:Array = [];
				var nextEscaped:Boolean;
				var isInString:Boolean;
				var lastOpen:String;
				var itemStart:int=1;
				while(pos<lastChar){
					var char:String = string.charAt(pos);
					if(isInString){
						if(nextEscaped){
							nextEscaped = false;
						}else if(char==lastOpen){
							lastOpen = open.pop();
							isInString = false;
						}else if(char=="\\"){
							nextEscaped = true;
						}
					}else{
						switch(char){
							case "'":
							case '"':
								if(lastOpen)open.push(lastOpen);
								lastOpen = char;
								isInString = true;
								break;
							case "[":
								if(lastOpen)open.push(lastOpen);
								lastOpen = "]";
								break;
							case '{':
								if(lastOpen)open.push(lastOpen);
								lastOpen = "}";
								break;
							case '(':
								if(lastOpen)open.push(lastOpen);
								lastOpen = ")";
								break;
							case '<':
								if(lastOpen)open.push(lastOpen);
								lastOpen = ">";
								break;
							case lastOpen:
								lastOpen = open.pop();
								break;
							case ",":
								if(!open.length){
									ret.push(string.substring(itemStart,pos));
									itemStart = pos+1;
								}
								break;
						}
					}
					++pos;
				}
				ret.push(string.substring(itemStart,pos));
				return ret;
			}
			return null;
		}
	}
}
import flash.sampler.NewObjectSample;
import flash.xml.XMLNodeKinds;

import org.tbyrne.acting.actTypes.IAct;
import org.tbyrne.acting.acts.Act;
import org.tbyrne.core.IPendingResult;
import org.tbyrne.hoborg.ObjectPool;
import org.tbyrne.siteStream.xml.IXmlNodeDetails;
import org.tbyrne.siteStream.xml.IXmlNodeSummary;

class PropDetails implements IPendingResult{
	private static const pool:ObjectPool = new ObjectPool(PropDetails);
	public static function getNew():PropDetails{
		var ret:PropDetails = pool.takeObject();
		ret.pool = pool;
		return ret;
	}
	
	/**
	 * @inheritDoc
	 */
	public function get success():IAct{
		return (_success || (_success = new Act()));
	}
	/**
	 * @inheritDoc
	 */
	public function get fail():IAct{
		return (_fail || (_fail = new Act()));
	}
	protected var _fail:Act;
	protected var _success:Act;
	
	
	public function get result():*{
		return _object;
	}
	public function get object():*{
		return _object;
	}
	public function set object(value:*):void{
		_object = value;
	}
	
	private var _object:*;
	
	public var parentSetterIsMethod:Boolean;
	public var parentSetterArgs:Array;
	public var parentSetter:String;
	public var classPath:String;
	//public var isWriteOnly:Boolean;
	//public var isClassReference:Boolean;
	public var parent:PropDetails;
	public var parentObject:*;
	public var xml:XML;
	
	public var stringValue:*;
	
	
	private var _childProps:Vector.<PropDetails>;
	
	internal var pool:ObjectPool;
	
	public function PropDetails(){
		_childProps = new Vector.<PropDetails>();
	}
	
	public function addChildProp(childProp:PropDetails):void{
		childProp.parent = this;
		_childProps.push(childProp);
	}
	
	public function release(deepRelease:Boolean):void{
		if(deepRelease){
			for each(var child:PropDetails in _childProps){
				child.release(true);
			}
			_childProps = new Vector.<PropDetails>();
		}
		//xml = null;
		parentSetterArgs = null;
		parent = null;
		parentObject = null;
		stringValue = null;
		parentSetter = null;
		classPath = null;
		//isWriteOnly = false;
		//isClassReference = false;
		parentSetterIsMethod = false;
		pool.releaseObject(this);
	}
}
class ReferenceDetails extends PropDetails{
	private static const pool:ObjectPool = new ObjectPool(ReferenceDetails);
	public static function getNew():ReferenceDetails{
		var ret:ReferenceDetails = pool.takeObject();
		ret.pool = pool;
		return ret;
	}
	
	override public function release(deepRelease:Boolean):void{
		super.release(deepRelease);
	}
}
class NodeDetails extends PropDetails implements IXmlNodeSummary, IXmlNodeDetails{
	private static const pool:ObjectPool = new ObjectPool(NodeDetails);
	public static function getNew():NodeDetails{
		var ret:NodeDetails = pool.takeObject();
		ret.pool = pool;
		return ret;
	}
	
	
	
	public function get detailsPending():IPendingResult{
		return _detailsPending;
	}
	public function get pathId():String{
		return _pathId;
	}
	public function set pathId(value:String):void{
		_pathId = value;
	}
	
	/*public function get xml():XML{
		return _xml;
	}
	public function set xml(value:XML):void{
		_xml = value;
	}*/
	
	public function get xmlUrl():String{
		return _xmlUrl;
	}
	public function set xmlUrl(value:String):void{
		_xmlUrl = value;
	}
	
	public function get childNodes():Vector.<IXmlNodeSummary>{
		return _childNodes;
	}
	
	public function get libraries():Vector.<String>{
		return _libraries;
	}
	public function set libraries(value:Vector.<String>):void{
		_libraries = value;
	}
	
	private var _detailsPending:PendingResult;
	private var _libraries:Vector.<String>;
	private var _childNodes:Vector.<IXmlNodeSummary>;
	private var _childNodesCast:Vector.<NodeDetails>;
	private var _childReferences:Vector.<ReferenceDetails>;
	private var _xmlUrl:String;
	//private var _xml:XML;
	private var _pathId:String;
	
	
	public function NodeDetails(){
		super();
		_childNodes = new Vector.<IXmlNodeSummary>();
		_childNodesCast = new Vector.<NodeDetails>();
		_childReferences = new Vector.<ReferenceDetails>();
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
			_childNodes = new Vector.<IXmlNodeSummary>();
			_childNodesCast = new Vector.<NodeDetails>();
			_childReferences = new Vector.<ReferenceDetails>();
		}
		_pathId = null;
		_xmlUrl = null;
		_libraries = null;
	}
}
class PendingResult implements IPendingResult{
	/**
	 * @inheritDoc
	 */
	public function get success():IAct{
		return (_success || (_success = new Act()));
	}
	
	/**
	 * @inheritDoc
	 */
	public function get fail():IAct{
		return (_fail || (_fail = new Act()));
	}
	
	
	public function get result():*{
		return _result;
	}
	public function set result(value:*):void{
		_result = value;
	}
	
	private var _result:*;
	protected var _fail:Act;
	protected var _success:Act;
}