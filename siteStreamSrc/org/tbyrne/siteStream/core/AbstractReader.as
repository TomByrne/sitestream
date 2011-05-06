package org.tbyrne.siteStream.core
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.memory.LooseReference;
	import org.tbyrne.reflection.ReflectionUtils;
	import org.tbyrne.siteStream.util.StringParser;
	import org.tbyrne.utils.ConstructorApply;
	import org.tbyrne.utils.methodClosure;
	
	public class AbstractReader
	{
		private static const NODE_REFERENCE_EXP:RegExp = /^\((\S*)\)$/;
		private static const VECTOR_TEST:RegExp = /__AS3__\.vec::Vector\.<(.*)>/;
		
		/**
		 * Determines whether ISSNodeSummary and ISSNodeDetails objects should be
		 * stored internally to link up reference nodes. If the Reader instance is
		 * being used as a parsing utility for data with no references then
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
		public var urlAttribute:String = "url";
		public var initAttribute:String = "init";
		//public var poolsAttribute:String = "pools";
		
		private var _cacheResults:Boolean;
		
		/* mapped xml > LooseReference(NodeDetails)
		Note that multiple xml instances can reference the same NodeDetails object
		*/
		private var _cache:Dictionary;
		
		private var _interpretting:Dictionary;
		
		public function AbstractReader(cacheResults:Boolean=false){
			this.cacheResults = cacheResults;
			_cache = new Dictionary();
			_interpretting = new Dictionary();
		}
		
		
		
		
		
		protected function _readRootNode(data:Object):ISSNodeSummary{
			var ret:NodeDetails = getNodeDetails(data);
			assessNodeSummary(data,ret);
			return ret;
		}
		protected function assessNodeSummary(data:Object, nodeDetails:NodeDetails):NodeDetails{
			var pathId:String = getPathIdForData(data, nodeDetails);
			if(pathId==null)return null;
			
			
			if(!nodeDetails)nodeDetails = getNodeDetails(data);
			nodeDetails.url = getUrlForData(data);
			nodeDetails.pathId = pathId;
			nodeDetails.data = data;
			assessClassProp(data, nodeDetails); // allows us to know whether this node fills one of it's parent's props
			
			return nodeDetails;
		}
		protected function getPathIdForData(data:Object, nodeDetails:ISSNodeDetails):String{
			// override me
			throw new Error();
		}
		protected function getUrlForData(data:Object):String{
			// override me
			throw new Error();
		}
		protected function assessClassProp(data:Object, propDetails:PropDetails):void{
			// override me
			throw new Error();
		}
		protected function getInitProp(data:Object, nodeDetails:ISSNodeDetails):PropDetails{
			// override me
			throw new Error();
		}
		
		
		
		
		
		
		protected function _readNodeDetails(data:Object, summary:ISSNodeSummary):IPendingSSResult{
			var ret:NodeDetails = summary as NodeDetails;
			ret.data = data;
			assessRefAndDetails(data,ret);
			return ret.detailsPending;
		}
		protected function assessRefAndDetails(data:Object, propDetails:PropDetails):PropDetails{
			var useReference:Boolean = false;
			var stringValue:String = getStringValue(data);
			
			if(stringValue && stringValue.length){
				var refTest:Object = NODE_REFERENCE_EXP.exec(stringValue);
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
				propDetails.data = data;
				assessClassProp(data, propDetails);
			}else{
				var nodeDetails:NodeDetails = (propDetails as NodeDetails);
				if(nodeDetails){
					createLibraries(data, nodeDetails);
					createChildNodes(data, nodeDetails);
				}
			}
			propDetails.simpleValue = stringValue;
			
			return propDetails;
		}
		protected function getStringValue(data:Object):String{
			// override me
			throw new Error();
		}
		protected function createLibraries(data:Object, nodeDetails:NodeDetails):void{
			// override me
			throw new Error();
		}
		protected function createChildListFromSimpleValue(simpleValue:*, added:Vector.<PropDetails>, filterMetadata:Boolean, parentClass:Class, isArray:Boolean, isVector:Boolean):void{
			var subPropDetails:PropDetails;
			if(isArray || isVector){
				var array:Array = (simpleValue as Array) || StringParser.parseArray(simpleValue,false);
				if(array){
					for each(var value:* in array){
						subPropDetails = PropDetails.getNew();
						subPropDetails.simpleValue = value;
						//subPropDetails.classPath = vectorType;
						childListAdd(subPropDetails, null, isArray, isVector, added)
					}
				}else{
					subPropDetails = PropDetails.getNew();
					subPropDetails.simpleValue = simpleValue;
					//subPropDetails.classPath = vectorType;
					childListAdd(subPropDetails, null, isArray, isVector, added)
				}
			}else{
				var object:Object = (typeof(simpleValue)=="object"?simpleValue:StringParser.parseObject(simpleValue,false));
				if(object){
					for(var prop:String in object){
						subPropDetails = PropDetails.getNew();
						subPropDetails.parentSetter = prop;
						subPropDetails.simpleValue = object[prop];
						childListAdd(subPropDetails, null, isArray, isVector, added)
					}
				}
			}
		}
		protected function addChildProp(propDetails:PropDetails, parentProp:PropDetails, parentNode:NodeDetails, parentClass:Class, overrideParentSetter:*):void{
			
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
				reassessClassProp(propDetails.data,propDetails,parentNode,parentClass);
			}
		}
		protected function childListAdd(propDetails:PropDetails, nodeDetails:NodeDetails, isArray:Boolean, isVector:Boolean, added:Vector.<PropDetails>):void{
			if(!propDetails.parentSetter){
				if(isArray || isVector){
					propDetails.parentIsVector = isVector;
					propDetails.parentSetter = added.length;
				}
			}
			added.push(propDetails);
		}
		protected function createChildNodes(data:Object, nodeDetails:NodeDetails):void{
			// override me
			throw new Error();
		}
		
		
		
		
		
		protected function _readObject(summary:ISSNodeSummary, oldObject:Object):IPendingSSResult{
			var ret:NodeDetails = summary as NodeDetails;
			var parentObject:*;
			var parentClass:Class;
			if(ret.parent){
				parentObject = ret.parent.object;
				if(parentObject!=null)parentClass = parentObject["constructor"];
			}
			reassessClassProp(ret.data, ret, ret, parentClass);
			return ret.objectPending;
		}
		protected function reassessClassProp(data:Object, propDetails:PropDetails, parentNode:NodeDetails, parentClass:Class):void{
			
			if(propDetails is ReferenceDetails)return;
			
			var nextParent:NodeDetails = (propDetails as NodeDetails) || parentNode;
			
			/*
			Initially, we get the parentPropName and classpath from the node but do not
			check it for deep references, this allows us to check early on whether a node
			must be fully parsed for it's parent object's sake. Then (here) we analyse the
			two variables to clean them up.
			*/
			var parentPropName:* = propDetails.parentSetter;
			var classPath:String = propDetails.classPath;
			//var isWriteOnly:Boolean = false;
			var varType:Class;
			var typeDesc:XML;
			var typeName:String;
			
			if(propDetails.parentIsVector){
				typeDesc = getTypeDescription(parentClass);
				typeName = typeDesc.@name;
				var vectorMatch:Object = VECTOR_TEST.exec(typeName);
				if(vectorMatch!=null){
					propDetails.classPath = vectorMatch[1];
					if(propDetails.classPath=="*")propDetails.classPath = null;
				}
			}else if(propDetails.parent && propDetails.parent.parentSetterIsMethod){
				typeDesc = ReflectionUtils.describeType(propDetails.parent.parent.classPath);
				varType = findParamType(typeDesc,propDetails.parent.parentSetter,parentPropName);
			}else if(propDetails.parent && propDetails.parent.parentSetterIsConstructor){
				typeDesc = ReflectionUtils.describeType(propDetails.parent.parent.classPath);
				varType = findConstType(typeDesc,parentPropName);
			}else if(parentClass){
				if(propDetails.parentSetterIsConstructor){
					propDetails = confirmArrayProp(propDetails);
					varType = Array;
				}else if((parentPropName is String) && parentPropName && parentPropName.length){
					typeDesc = getTypeDescription(parentClass);
					var parentProp:PropDetails = propDetails.parent;
					
					// Do the check for deep properties. i.e. s:prop="rootProp.parentProp.childProp"
					var varPath: Array = parentPropName.split(".");
					var parentTypeDesc: XML = typeDesc;
					var dynamicMode:Boolean;
					while (varPath.length > 0){
						
						var thisPropName:String = varPath.shift();
						
						varType = null;
						if(parentTypeDesc){
							typeName = getVariableType(parentTypeDesc, thisPropName);
							if(typeName && typeName.length && typeName!="*"){
								varType = ReflectionUtils.getClassByName(typeName);
								//if(!varPath.length)isWriteOnly = (parentTypeDesc..accessor.(@name==thisPropName).@access=="writeonly");
							}
						}
						
						
						if(!varType){
							if(typeDesc..method.(@name.toString()==thisPropName).length()){
								propDetails = confirmArrayProp(propDetails);
								propDetails.parentSetterIsMethod = true;
								varType = Array;
								break;
							}
							/*var value:* = parentObject[thisPropName];
							if(value is Function){
								confirmArrayProp(propDetails);
								propDetails.parentSetterIsMethod = true;
								varType = Array;
								break;
							}else if(value){
								varType = value.constructor;
							}*/
						}
						
						if(!varType && !typeName){
							if(parentTypeDesc.@isDynamic.toString()!="true"){
								var msg: String = "Couldn't map element \"" + thisPropName + "\"";
								msg += " to class: "+ parentClass;
								Log.error( "AbstractReader.reassessClassProp: "+msg);
							}
							break;
						}else if(varPath.length){
							parentTypeDesc = getTypeDescription(varType);
							//parentObject = parentObject[thisPropName];
						}
					}
					parentPropName = thisPropName;
				}
			}
			var isClassRef:Boolean = (varType==Class);
			
			if(varType!=null && isInterfaceRef(varType)){
				varType = null;
			}
			
			var type:Class;
			if(isClassRef){
				if(propDetails.simpleValue)type = ReflectionUtils.getClassByName(propDetails.simpleValue);
				else if(propDetails.classPath)type = ReflectionUtils.getClassByName(propDetails.classPath);
			}else if(propDetails.classPath){
				type = ReflectionUtils.getClassByName(propDetails.classPath);
			}else{
				type = varType;
			}
			
			
			var initProp:PropDetails = getInitProp(data,nextParent);
			if(initProp){
				initProp.parentSetterIsConstructor = true;
				propDetails.addChildProp(initProp);
				reassessClassProp(initProp.data,initProp,nextParent,type);
			}
			
			if(isClassRef){
				propDetails.type = Class;
				propDetails.object = type;
			}else{
				propDetails.type = type;
			}
			
			for each(var childProp:PropDetails in propDetails.childProps){
				if(childProp!=initProp)reassessClassProp(childProp.data,childProp,nextParent,type);
			}
			if(data || propDetails.simpleValue){
				createChildren(data, propDetails.simpleValue, type, parentNode, propDetails);
			} 	
			
			propDetails.committed = false;
		}
		
		private function confirmArrayProp(propDetails:PropDetails):PropDetails{
			if(propDetails.classPath && propDetails.classPath!="Array"){
				var reChildProp:PropDetails = propDetails;
				propDetails = PropDetails.getNew();
				propDetails.parentIsVector = reChildProp.parentIsVector;
				propDetails.parentSetter = reChildProp.parentSetter;
				//propDetails.parentObject = reChildProp.parentObject;
				reChildProp.parent.addChildProp(propDetails);
				reChildProp.parent.removeChildProp(reChildProp);
				propDetails.addChildProp(reChildProp);
				propDetails.classPath = "Array";
				
				reChildProp.parentIsVector = false;
				reChildProp.parentSetter = 0;
				reChildProp.parentSetterIsMethod = false;
			}
			return propDetails;
		}
		
		
		private function isInterfaceRef(varType:Class):Boolean{
			var typeDesc:XML = getTypeDescription(varType);
			return typeDesc.factory.extendsClass.length()==0;
		}
		
		protected function createChildren(data:Object, simpleValue:*, parentClass:Class, parentNode:NodeDetails, propDetails:PropDetails):void{
			// override me
			throw new Error();
		}
		
		protected function findParamType(typeDesc:XML, methodName:String, paramIndex:int):Class{
			var methodXML:XMLList = typeDesc..method.(@name.toString()==methodName);
			if(methodXML.length()){
				var paramXML:XMLList = methodXML.parameter.(@index.toString()==(paramIndex+1).toString());
				if(paramXML.length()){
					var paramType:String = paramXML.@type;
					if(paramType!="*")return ReflectionUtils.getClassByName(paramType);
				}
			}
			return null;
		}
		protected function findConstType(typeDesc:XML, paramIndex:int):Class{
			var methodXML:XMLList = typeDesc..constructor;
			if(methodXML.length()){
				var paramXML:XMLList = methodXML.parameter.(@index.toString()==(paramIndex+1).toString());
				if(paramXML.length()){
					var paramType:String = paramXML.@type;
					if(paramType!="*")return ReflectionUtils.getClassByName(paramType);
				}
			}
			return null;
		}
		
		
		/**
		 * cleanPackageName will clean a package name into a format which can then be 
		 * prepended to a class name and reference via ReflectionUtils.getClassByName().
		 */
		protected function cleanPackageName(packageName:String):String{
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
			var varDesc:XMLList = desc..variable.(@name==varName).@type;
			var type:String = varDesc.toString();
			if(type && type.length)return type;
			else{
				varDesc = desc..accessor.(@name==varName).@type;
				if(varDesc.length()>0){
					type = varDesc[0].toString();
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
		
		protected function getNodeDetails(data:Object):NodeDetails{
			var looseRef:LooseReference = _cache[data];
			var ret:NodeDetails;
			if(!looseRef){
				ret = NodeDetails.getNew();
				ret.requestInterpret.addHandler(onRequestInterpret);
				_cache[data] = new LooseReference(ret);
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
			//var pendingChildren:Boolean = false;
			var avoidContinue:Boolean = false;
			
			var childProp:PropDetails;
			var initParams:Array;
			
			prop.interpretted = true;
			
			
			if(prop.object==null){
				// find constructor args
				for each(childProp in prop.childProps){
					if(childProp.parentSetterIsConstructor){
						if(!childProp.interpretted){
							// interpret constructor args
							avoidContinue = true;
							interpretProp(childProp, complete || (complete = methodClosure(onPropInterpreted,prop,onComplete)));
						}
						if(childProp.committed){
							if(!avoidContinue){
								if(!initParams){
									initParams = childProp.object is Array?childProp.object:[childProp.object];
								}else{
									initParams = initParams.concat(childProp.object);
								}
							}
						}else{
							avoidContinue = true;
						}
					}
				}
				if(avoidContinue)return;
				
				instantiateObject(prop,initParams);
			}
			
			// first commit child props
			for each(childProp in prop.childProps){
				if(!childProp.interpretted){
					avoidContinue = true;
					interpretProp(childProp, complete || (complete = methodClosure(onPropInterpreted,prop,onComplete)));
				}
				if(!childProp.committed){
					avoidContinue = true;
				}
			}
			if(avoidContinue)return;
			
			if(!prop.committed){
				
				// then call methods
				var methods:Object;
				for each(childProp in prop.childProps){
					if(childProp.parentSetterIsMethod){
						var args:* = childProp.object;
						var castArgs:Array = (args as Array);
						if(!castArgs)castArgs = [castArgs];
						prop.object[childProp.parentSetter].apply(null,castArgs);
					}
				}
				
				// then commit to parent
				commitValue(prop);
			}
			onComplete(prop);
		}
		
		private function instantiateObject(propDetails:PropDetails, initParams:Array):void{
			var type:Class = propDetails.type;
			var isClassRef:Boolean = (type==Class);
			var object: *;
			var simpleValue:* = propDetails.simpleValue;
			if(!isClassRef){
				switch(type){
					case XML:
						if(simpleValue is XML){
							object = simpleValue;
						}else{
							object = new XML(simpleValue);
						}
						simpleValue = null;
						break;
					case String:
						if(simpleValue is String){
							object = simpleValue;
						}else{
							object = String(simpleValue);
						}
						simpleValue = null;
						//object = String(simpleValue);
						break;
					case Number:
						if(simpleValue is Number){
							object = simpleValue;
						}else{
							object = StringParser.parseNumber(simpleValue,false);
						}
						simpleValue = null;
						break;
					case int:
					case uint:
						if(simpleValue is int){
							object = simpleValue;
						}else{
							object = int(StringParser.parseNumber(simpleValue,false));
						}
						simpleValue = null;
						break;
					case Boolean:
						if(simpleValue is Boolean){
							object = simpleValue;
						}else{
							object = (simpleValue=="true");
						}
						simpleValue = null;
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
						simpleValue = null;
						break;
					default:
						object = propDetails.object;
						if(type){
							if(!object || !(object is type)){
								if(initParams){
									object = ConstructorApply(type,initParams);
								}else{
									object = new type();
								}
							}
						}else if(simpleValue){
							object = StringParser.parse(simpleValue,false);
						}
				}
			}
			propDetails.object = object;
		}
		
		private function onPropInterpreted(prop:PropDetails, parentProp:PropDetails, onComplete:Function):void{
			interpretProp(parentProp,onComplete);
		}
		
		private function commitValue(prop:PropDetails):void{
			prop.committed = true;
			
			var parentObject:*;
			if(prop.parent){
				parentObject = prop.parent.object;
			}
			
			if(prop.isLibrary){
				(prop.parent as NodeDetails).libraries = prop.object;
				return;
			}
			
			if(!parentObject){
				return;
			}
			
			if(!prop.parentSetterIsMethod){
				if(prop.parentIsVector){
					parentObject.splice(prop.parentSetter,0,prop.object);
				}else{
					parentObject[prop.parentSetter] = prop.object;
				}
			}
		}
	}
}