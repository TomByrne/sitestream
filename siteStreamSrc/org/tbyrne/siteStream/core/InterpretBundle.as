package org.tbyrne.siteStream.core
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;

	public class InterpretBundle implements IPendingSSResult{
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
}