package org.tbyrne.siteStream.xml
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.tbyrne.siteStream.core.SiteStreamNodeProxy;
	
	public class XMLRootNode extends SiteStreamNodeProxy
	{
		public function get rootXmlUrl():String{
			return _rootXmlUrl;
		}
		public function set rootXmlUrl(value:String):void{
			if(_rootXmlUrl != value){
				_rootXmlUrl = value;
				resetLoad();
			}
		}
		
		public function get baseXmlUrl():String{
			return _rootNode.baseXmlUrl;
		}
		public function set baseXmlUrl(value:String):void{
			if(_rootNode.baseXmlUrl != value){
				_rootNode.baseXmlUrl = value;
				resetLoad();
			}
		}
		
		public function get baseSwfUrl():String{
			return _rootNode.baseSwfUrl;
		}
		public function set baseSwfUrl(value:String):void{
			if(_rootNode.baseSwfUrl != value){
				_rootNode.baseSwfUrl = value;
			}
		}
		
		protected var _rootXmlUrl:String;
		protected var _rootNode:XMLNode;
		protected var _xmlReader:XmlReader;
		protected var _urlLoader:URLLoader;
		
		public function XMLRootNode(rootXmlUrl:String=null, baseXmlUrl:String=null, baseSwfUrl:String=null){
			super();
			
			_xmlReader = new XmlReader(true);
			_rootNode = new XMLNode(_xmlReader);
			setTarget(_rootNode);
			
			this.rootXmlUrl = rootXmlUrl;
			this.rootXmlUrl = rootXmlUrl;
			this.baseSwfUrl = baseSwfUrl;
		}
		protected function resetLoad():void{
			_rootNode.xmlSummary = null;
			startLoad();
		}
		protected function startLoad():void{
			if(!_urlLoader){
				_urlLoader = new URLLoader();
				_urlLoader.addEventListener(Event.COMPLETE, onXmlLoaded);
				_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onXmlError);
				_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onXmlError);
			}
			var url:String = _rootXmlUrl;
			if(_rootNode.baseXmlUrl){
				url = _rootNode.baseXmlUrl+url;
			}
			_urlLoader.load(new URLRequest(url));
		}
		protected function onXmlLoaded(e:Event):void{
			var xml:XML = new XML(_urlLoader.data);
			_rootNode.xmlSummary = _xmlReader.readRootNode(xml);
		}
		protected function onXmlError(e:Event):void{
			Log.error(e);
		}
	}
}
import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

import org.tbyrne.acting.actTypes.IAct;
import org.tbyrne.acting.acts.Act;
import org.tbyrne.siteStream.ISiteStreamNode;
import org.tbyrne.siteStream.core.SiteStreamNodeProxy;
import org.tbyrne.siteStream.xml.IXmlNodeDetails;
import org.tbyrne.siteStream.xml.IXmlNodeSummary;
import org.tbyrne.siteStream.xml.XmlReader;

class XMLNode implements ISiteStreamNode{
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
	
	
	public function get object():*{
		return _object;
	}
	public function get objectReady():Boolean{
		return _objectReady;
	}
	public function get pathId():String{
		return _xmlSummary.pathId;
	}
	
	public function get baseXmlUrl():String{
		return _baseXmlUrl;
	}
	public function set baseXmlUrl(value:String):void{
		releaseObject();
		_baseXmlUrl = value;
		readXML();
	}
	
	public function get baseSwfUrl():String{
		return _baseSwfUrl;
	}
	public function set baseSwfUrl(value:String):void{
		releaseLibraries();
		_baseSwfUrl = value;
		checkForLibraries();
	}
	
	public function get childNodes():Vector.<ISiteStreamNode>{
		if(_childNodesInvalid){
			createChildNodes();
			_childNodesInvalid = false;
		}
		return _childNodes;
	}
	
	public function get xmlSummary():IXmlNodeSummary{
		return _xmlSummary;
	}
	public function set xmlSummary(value:IXmlNodeSummary):void{
		if(_xmlSummary!=value){
			releaseObject();
			_xmlSummary = value;
			readXML();
		}
	}
	
	
	
	protected var _baseSwfUrl:String;
	protected var _baseXmlUrl:String;
	protected var _xmlReader:XmlReader;
	protected var _objectReady:Boolean;
	protected var _object:*;
	
	protected var _childNodesCast:Vector.<XMLNode>;
	protected var _childNodes:Vector.<ISiteStreamNode>;
	
	//protected var _parseStarted:Boolean;
	protected var _objectRequested:Boolean;
	protected var _childNodesInvalid:Boolean;
	
	protected var _urlLoader:URLLoader;
	protected var _currentLibrary:Loader;
	protected var _xmlSummary:IXmlNodeSummary;
	protected var _xmlDetails:IXmlNodeDetails;
	protected var _xmlDetailsUrl:String;
	
	protected var _libraries:Vector.<Loader>;
	
	public function XMLNode(xmlReader:XmlReader, xmlSummary:IXmlNodeSummary=null){
		_xmlReader = xmlReader;
		this.xmlSummary = xmlSummary;
	}
	
	public function requestObject():void{
		_objectRequested = true;
		readXML();
	}
	public function releaseObject():void{
		_objectRequested = false;
		
		if(_urlLoader){
			_urlLoader.close();
		}
		releaseLibraries();
		//_parseStarted = false;
		
		if(_childNodes){
			//@todo pool child nodes
			_childNodesCast = null;
			_childNodes = null;
			if(_childNodesChanged)_childNodesChanged.perform(this);
		}
		_xmlDetails = null;
		
		setObjectReady(false);
	}
	
	protected function releaseLibraries():void{
		if(_currentLibrary){
			_currentLibrary.close();
		}
		for each(var loader:Loader in _libraries){
			loader.unload();
		}
		_libraries = null;
	}
	
	
	
	private function readXML():void{
		var summary:IXmlNodeSummary = (_xmlDetails || _xmlSummary);
		if(summary){
			if(_xmlDetailsUrl && _objectRequested){
				// newly loaded xml is again pointing to another XML file
				_xmlDetailsUrl = summary.xmlUrl;
				loadXML();
			}else{
				_childNodesInvalid = true;
				if(_childNodesChanged)_childNodesChanged.perform(this);
				
				if(_objectRequested)checkForLibraries();
			}
		}
	}
	
	
	
	protected function loadXML():void{
		if(!_urlLoader){
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.COMPLETE, onXmlLoaded);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onXmlError);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onXmlError);
		}
		var url:String = _xmlDetailsUrl;
		if(_baseXmlUrl){
			url = _baseXmlUrl+url;
		}
		_urlLoader.load(new URLRequest(url));
	}
	protected function onXmlLoaded(e:Event):void{
		var xml:XML = new XML(_urlLoader.data);
		// Removed: was causing a compiler error, not sure of correct replacement
		//_xmlDetails = _xmlReader.readNodeDetails(xml,_xmlSummary);
		checkForLibraries();
	}
	protected function onXmlError(e:Event):void{
		Log.error(e);
	}
	
	
	
	private function checkForLibraries():void{
		if(_xmlDetails && _xmlDetails.libraries && _xmlDetails.libraries.length){
			_libraries = new Vector.<Loader>();
			loadNextLibrary()
		}else{
			parseXML();
		}
	}
	private function loadNextLibrary():void{
		var url:String = _xmlDetails.libraries[_libraries.length];
		if(_baseSwfUrl){
			url = _baseSwfUrl+url;
		}
		var request:URLRequest = new URLRequest(url);
		_currentLibrary = new Loader();
		_currentLibrary.contentLoaderInfo.addEventListener(Event.COMPLETE, onLibraryComplete);
		_currentLibrary.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLibraryError);
		_currentLibrary.load(request,new LoaderContext(false,ApplicationDomain.currentDomain));
		_libraries.push(_currentLibrary);
	}
	private function onLibraryComplete(e:Event):void{
		_currentLibrary = null;
		if(_xmlDetails.libraries.length>_libraries.length){
			loadNextLibrary();
		}else{
			parseXML();
		}
	}
	private function onLibraryError(e:Event):void{
		_currentLibrary = null;
		Log.error(e);
		if(_xmlDetails.libraries.length>_libraries.length){
			loadNextLibrary();
		}else{
			parseXML();
		}
	}
	
	private function parseXML():void{
		var summary:IXmlNodeSummary = (_xmlDetails || _xmlSummary);
		_object = _xmlReader.readObject(summary,_object);
		
		if(_xmlDetails || !_xmlSummary.xmlUrl){
			setObjectReady(true);
		}
	}
	
	
	protected function createChildNodes():void{
		if(_xmlDetails && _xmlDetails.childNodes && _xmlDetails.childNodes.length){
			_childNodes = new Vector.<ISiteStreamNode>();
			_childNodesCast = new Vector.<XMLNode>();
			for each(var nodeSummary:IXmlNodeSummary in _xmlDetails.childNodes) {
				var xmlNode:XMLNode = new XMLNode(_xmlReader,nodeSummary);
				_childNodes.push(xmlNode);
				_childNodesCast.push(xmlNode);
			}
		}else{
			_childNodesCast = null;
			_childNodes = null;
		}
	}
	
	
	private function setObjectReady(value:Boolean):void{
		if(_objectReady != value){
			_objectReady = value;
			if(_objectReadyChanged)_objectReadyChanged.perform(this);
		}
	}
}