package org.tbyrne.siteStream.xml
{
	import flash.utils.Dictionary;
	import flash.xml.XMLNodeKinds;
	
	import org.tbyrne.memory.LooseReference;
	import org.tbyrne.reflection.ReflectionUtils;
	import org.tbyrne.siteStream.util.StringParser;
	import org.tbyrne.utils.methodClosure;

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
		
		private var _interpretting:Dictionary;
		
		public function XmlReader(cacheResults:Boolean=false){
			this.cacheResults = cacheResults;
			_cache = new Dictionary();
			_interpretting = new Dictionary();
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
			}else if(xml.nodeKind()==XMLNodeKinds.ELEMENT && xml.namespace()!=metadataNamespace){
				var packageName:String;
				packageName = cleanPackageName(xml.namespace());
				parentPropName = getChildWithNS(xml,propAttribute,metadataNamespace);
				
				
				var nodeName:String = xml.localName();
				classPath = nodeName;
				if(packageName && classPath)classPath = packageName+classPath;
				
				if((!parentPropName || !parentPropName.length) && !ReflectionUtils.doesClassExist(classPath)){
					parentPropName = nodeName;
					classPath = null;
				}
			}
			propDetails.parentSetter = parentPropName;
			propDetails.classPath = classPath;
		}
		
		
		
		
		
		
		public function readNodeDetails(xml:XML, summary:IXmlNodeSummary):IXmlPendingResult{
			var ret:NodeDetails = summary as NodeDetails;
			ret.xml = xml;
			assessRefAndDetails(xml,ret);
			return ret.detailsPending;
		}
		protected function assessRefAndDetails(xml:XML, propDetails:PropDetails):PropDetails{
			var useReference:Boolean = false;
			var stringValue:String;
			
			var nodeKind:String = xml.nodeKind();
			if(nodeKind==XMLNodeKinds.ATTRIBUTE){
				stringValue = xml.toString();
			}else if(nodeKind==XMLNodeKinds.ELEMENT){
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
			propDetails.simpleValue = stringValue;
			
			return propDetails;
		}
		private function createLibraries(xml:XML, nodeDetails:NodeDetails):void{
			var attList:XMLList = xml.attribute(new QName(metadataNamespace,libsAttribute));
			var eleList:XMLList = xml.child(new QName(metadataNamespace,libsAttribute));
			var libs:Vector.<String> = new Vector.<String>();
			nodeDetails.libraries = libs;
			createChildren(nodeDetails,nodeDetails,attList,eleList,libs,false);
		}
		private function createChildren(parentProp:PropDetails,parentNode:NodeDetails, attList:XMLList, eleList:XMLList, parentObject:*, filterMetadata:Boolean):void{
			if(!attList.length() && !eleList.length())return;
			
			var added:Vector.<PropDetails> = new Vector.<PropDetails>();
			if(attList && attList.length())createChildList(attList,parentObject,added,filterMetadata);
			if(eleList && eleList.length())createChildList(eleList,parentObject,added,filterMetadata);
			
			if(added.length){
				for each(var propDetails:PropDetails in added){
					propDetails.parentObject = parentObject;
					
					var childNode:NodeDetails = (propDetails as NodeDetails);
					
					if(childNode){
						parentNode.addChildNode(childNode);
					}else{
						var refDetails:ReferenceDetails = (propDetails as ReferenceDetails);
						if(refDetails)parentNode.addChildRef(refDetails);
					}
					if(propDetails.parentSetter){
						parentNode.addChildProp(propDetails);
						reassessClassProp(propDetails.xml,propDetails,parentNode,parentObject);
					}
				}
			}
		}
		private function createChildList(xmlList:XMLList, parentObject:*, added:Vector.<PropDetails>, filterMetadata:Boolean):void{
			var parentClass:Class = (parentObject.constructor);
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
				
				if(filterMetadata && memberXML.namespace()==metadataNamespace){
					continue;
				}
				
				var nodeDetails:NodeDetails = assessNodeSummary(memberXML,null);
				var propDetails:PropDetails = assessRefAndDetails(memberXML,nodeDetails);
				if(propDetails){
					var denyAdd:Boolean;
					if((isArray || isVector) && propDetails.simpleValue!=null){
						if(attemptLiteralParse(propDetails, nodeDetails, isArray, isVector, vectorType, added)){
							denyAdd = true;
						}
					}
					if(!denyAdd){
						if(!nodeDetails && !propDetails.parentSetter && !propDetails.classPath){
							// this happens with s:libs nodes, etc.
							if(propDetails.simpleValue){
								childListAdd(propDetails, nodeDetails, isArray, isVector, vectorType, added);
							}
							var attList:XMLList = memberXML.attributes();
							var eleList:XMLList = memberXML.elements();
							if(attList && attList.length())createChildList(attList,parentObject,added,filterMetadata);
							if(eleList && eleList.length())createChildList(eleList,parentObject,added,filterMetadata);
						}else{
							childListAdd(propDetails, nodeDetails, isArray, isVector, vectorType, added);
						}
					}
				}
			}
		}
		private function attemptLiteralParse(propDetails:PropDetails, nodeDetails:NodeDetails, isArray:Boolean, isVector:Boolean, vectorType:String, added:Vector.<PropDetails>):Boolean{
			var array:Array = StringParser.parseArray(propDetails.simpleValue);
			var ret:Boolean;
			var subPropDetails:PropDetails;
			if(array){
				ret = true;
				for each(var value:* in array){
					subPropDetails = PropDetails.getNew();
					subPropDetails.simpleValue = value;
					childListAdd(subPropDetails, null, isArray, isVector, vectorType, added)
				}
			}else{
				var object:Object = StringParser.parseObject(propDetails.simpleValue);
				if(object){
					ret = true;
					for(var prop:String in object){
						subPropDetails = PropDetails.getNew();
						subPropDetails.parentSetter = prop;
						subPropDetails.simpleValue = object[prop];
						childListAdd(subPropDetails, null, isArray, isVector, vectorType, added)
					}
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
		
		
		
		
		
		public function readObject(summary:IXmlNodeSummary, oldObject:Object):IXmlPendingResult{
			var ret:NodeDetails = summary as NodeDetails;
			var parentObject:*;
			if(ret.parent){
				parentObject = ret.parent.object;
			}
			reassessClassProp(ret.xml, ret, ret, parentObject);
			return ret.objectPending;
		}
		protected function reassessClassProp(xml:XML, propDetails:PropDetails, parentNode:NodeDetails, parentObject:*):void{
			
			if(propDetails is ReferenceDetails)return;
			
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
						if(typeName && typeName.length && typeName!="*"){
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
						}else if(value){
							varType = value.constructor;
						}
					}
					
					if(!varType && !typeName){
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
			}else if(isClassRef && propDetails.simpleValue){
				type = ReflectionUtils.getClassByName(propDetails.simpleValue);
			}else{
				type = varType;
			}
				
			var object: *;
			var simpleValue:* = propDetails.simpleValue;
			if(isClassRef){
				object = type;
			}else{
				switch(type){
					case XML:
						if(simpleValue is XML){
							object = simpleValue;
						}else{
							object = new XML(simpleValue);
						}
						break;
					case String:
						if(simpleValue is String){
							object = simpleValue;
						}else{
							object = String(simpleValue);
						}
						object = String(simpleValue);
						break;
					case Number:
						if(simpleValue is Number){
							object = simpleValue;
						}else{
							object = StringParser.parseNumber(simpleValue,false);
						}
						break;
					case int:
					case uint:
						if(simpleValue is int){
							object = simpleValue;
						}else{
							object = int(StringParser.parseNumber(simpleValue,false));
						}
						break;
					case Boolean:
						if(simpleValue is Boolean){
							object = simpleValue;
						}else{
							object = (simpleValue=="true");
						}
						break;
					case Function:
						if(simpleValue is Function){
							object = simpleValue;
						}else{
							// TODO: Need to consider package functions, which will look similiar to static functions
							// e.g.		flash.utils.myFunction
							//			flash.utils.FuncClass.myFunction
							var methodSepIndex: int = simpleValue.lastIndexOf(".");
							if (methodSepIndex < 0){
								object = ReflectionUtils.getFunctionByName(simpleValue);
							}else{
								var functionName: String = simpleValue.substr(methodSepIndex + 1, simpleValue.length);
								var className: String = simpleValue.substring(0, methodSepIndex);
								var methodClass: Class = ReflectionUtils.getClassByName(className);
								try{
									object = methodClass[functionName] as Function;
								}catch (e: ReferenceError){
									Log.error("Function " + simpleValue + " is not defined");
								}
							}
						}
						break;
					default:
						object = propDetails.object;
						if(type){
							if(!object || !(object is type)){
								object = new type();
							}
						}
						if(simpleValue){
							if(simpleValue is String){
								simpleValue = StringParser.parse(simpleValue);
							}
							if(simpleValue is Object){
								if(object){
									for(var i:* in simpleValue){
										object[i] = simpleValue[i];
									}
								}else{
									object = simpleValue;
								}
							}else{
								object = simpleValue;
							}
						}
				}
			}
			if(xml){
				var attList:XMLList = xml.attributes();
				var eleList:XMLList = xml.elements();
				createChildren(propDetails,parentNode,attList,eleList,object,true);
			}
			
			propDetails.committed = false;
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
				ret.requestInterpret.addHandler(onRequestInterpret);
				_cache[xml] = new LooseReference(ret);
			}else if(looseRef.referenceExists){
				ret = looseRef.reference as NodeDetails;
			}else{
				ret = NodeDetails.getNew();
				ret.requestInterpret.addHandler(onRequestInterpret);
				looseRef.object = ret;
			}
			return ret;
		}
		
		protected function onRequestInterpret(from:NodeDetails, interpretBundle:InterpretBundle):void{
			if(!_interpretting[interpretBundle]){
				var interpTried:Boolean = false;
				var pendingChildren:Boolean = false;
				for each(var prop:PropDetails in interpretBundle.props){
					if(!prop.committed){
						interpTried = true;
						interpretProp(prop,methodClosure(checkBundle,interpretBundle));
						if(!prop.committed){
							pendingChildren = true;
						}
					}
				}
				if(pendingChildren){
					_interpretting[interpretBundle] = true;
				}else if(!interpTried){
					interpretBundle.performSuceeded();
				}
			}
		}
		private function checkBundle(prop:PropDetails, interpretBundle:InterpretBundle):void{
			for each(var prop:PropDetails in interpretBundle.props){
				if(!prop.committed){
					return;
				}
			}
			delete _interpretting[interpretBundle];
			interpretBundle.performSuceeded();
		}
		
		private function interpretProp(prop:PropDetails, onComplete:Function):void{
			var complete:Function;
			var pendingChildren:Boolean = false;
			var interpTried:Boolean = false;
			for each(var childProp:PropDetails in prop.childProps){
				if(!childProp.committed){
					interpTried = true;
					interpretProp(childProp, complete || (complete = methodClosure(onPropInterpreted,prop,onComplete)));
					if(!childProp.committed){
						pendingChildren = true;
					}
				}
			}
			if(!pendingChildren){
				if(!prop.committed){
					commitValue(prop);
				}
				if(!interpTried)onComplete(prop);
			}
		}
		private function onPropInterpreted(prop:PropDetails, parentProp:PropDetails, onComplete:Function):void{
			interpretProp(parentProp,onComplete);
		}
		
		private function commitValue(prop:PropDetails):void{
			prop.committed = true;
			
			if(!prop.parentObject){
				return;
			}
			
			if(prop.parentSetterIsMethod){
				var args:Array;
				if(prop.parentSetterArgs){
					args = prop.parentSetterArgs.concat();
					for(var i:int=0; i<args.length; ++i){
						if(args[i]==PROP_REPLACE){
							args[i] = prop.object;
						}
					}
				}else{
					args = [prop.object];
				}
				prop.parentObject[prop.parentSetter].apply(null,args);
			}else{
				prop.parentObject[prop.parentSetter] = prop.object;
			}
		}
	}
}
import flash.xml.XMLNodeKinds;

import org.tbyrne.acting.actTypes.IAct;
import org.tbyrne.acting.acts.Act;
import org.tbyrne.hoborg.ObjectPool;
import org.tbyrne.siteStream.xml.IXmlNodeDetails;
import org.tbyrne.siteStream.xml.IXmlNodeSummary;
import org.tbyrne.siteStream.xml.IXmlPendingResult;

class PropDetails{
	private static const pool:ObjectPool = new ObjectPool(PropDetails);
	public static function getNew():PropDetails{
		var ret:PropDetails = pool.takeObject();
		ret.pool = pool;
		return ret;
	}
	
	public function get object():*{
		return _object;
	}
	public function set object(value:*):void{
		_object = value;
	}
	public function get childProps():Vector.<PropDetails>{
		return _childProps;
	}
	
	private var _object:*;
	
	public var parentSetterIsMethod:Boolean;
	public var parentSetterArgs:Array;
	public var parentSetter:String;
	public var classPath:String;
	public var parent:PropDetails;
	public var parentObject:*;
	public var xml:XML;
	public var committed:Boolean;
	
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
		simpleValue = null;
		parentSetter = null;
		classPath = null;
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
	
	
	/**
	 * handler(from:NodeDetails, interpretBundle:InterpretBundle)
	 */
	public function get requestInterpret():IAct{
		return _requestInterpret;
	}
	
	protected var _requestInterpret:Act = new Act();
	
	
	
	public function get detailsPending():IXmlPendingResult{
		return _detailsBundle;
	}
	public function get objectPending():IXmlPendingResult{
		return _objectBundle;
	}
	public function get nonRefPending():IXmlPendingResult{
		return _nonRefBundle;
	}
	public function get pathId():String{
		return _pathId;
	}
	public function set pathId(value:String):void{
		_pathId = value;
	}
	
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
		
		_detailsBundle.clearProps();
		if(_libraries){
			for each(var propDetails:PropDetails in _childProps){
				if(propDetails.parentObject==_libraries)_detailsBundle.addProp(propDetails);
			}
		}
	}
	override public function set object(value:*):void{
		super.object = value;
		_objectBundle.result = value;
		_nonRefBundle.result = value;
	}
	
	private var _detailsBundle:InterpretBundle;
	private var _objectBundle:InterpretBundle;
	private var _nonRefBundle:InterpretBundle;
	
	private var _childNodes:Vector.<IXmlNodeSummary>;
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
		_childNodes = new Vector.<IXmlNodeSummary>();
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
			_childNodes = new Vector.<IXmlNodeSummary>();
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
class InterpretBundle implements IXmlPendingResult{
	/**
	 * @inheritDoc
	 */
	public function get succeeded():IAct{
		return (_succeeded || (_succeeded = new Act()));
	}
	/**
	 * @inheritDoc
	 */
	public function get failed():IAct{
		return (_failed || (_failed = new Act()));
	}
	/**
	 * handler(handler:PendingResult)
	 */
	public function get beginRequested():IAct{
		return (_beginRequested || (_beginRequested = new Act()));
	}
	
	
	public function get result():*{
		return _result;
	}
	public function set result(value:*):void{
		_result = value;
	}
	
	
	public function get props():Vector.<PropDetails>{
		return _props;
	}
	/*public function get interpretting():Boolean{
		return _interpretting;
	}*/
	public function get invalid():Boolean{
		return _invalid;
	}
	
	//protected var _interpretting:Boolean;
	protected var _invalid:Boolean;
	
	protected var _result:*;
	protected var _props:Vector.<PropDetails>;
	protected var _succeeded:Act;
	protected var _failed:Act;
	protected var _beginRequested:Act;
	
	public function InterpretBundle(result:*=null){
		this.result = result;
		
		_props = new Vector.<PropDetails>();
	}
	
	public function begin():void{
		if(_beginRequested)_beginRequested.perform(this);
	}
	public function performSuceeded():void{
		//_interpretting = false;
		_invalid = true;
		if(_succeeded)_succeeded.perform(this);
	}
	public function performFailed():void{
		//_interpretting = false;
		_invalid = false;
		if(_failed)_failed.perform(this);
	}
	public function addProp(prop:PropDetails):void{
		_props.push(prop);
		_invalid = false;
	}
	public function clearProps():void{
		if(_props.length){
			_props = new Vector.<PropDetails>();
			//_interpretting = false;
			_invalid = false;
		}
	}
	
	public function release():void{
		_succeeded.removeAllHandlers();
		_failed.removeAllHandlers();
		clearProps();
	}
}