package org.tbyrne.siteStream.util
{
	import flash.utils.Dictionary;
	

	public class StringParser
	{
		private static const STRIPPER:RegExp = /^\s*(.*)\s*$/s;
		private static const NUMBER_CHECK:RegExp = /^\d+$/s;
		private static const HEX_NUMBER_CHECK:RegExp = /^[\dabcdef]+$/is;
		private static const VALID_PROP_CHECK:RegExp = /\w+/;
		private static const QUOTE_STRIPPER:RegExp = /^['"](.*)['"]$/;
		
		
		public static function parse(string:String, deepParse:Boolean=true):*{
			return _parse(string,deepParse,false);
		}
		public static function parseJson(string:String, deepParse:Boolean=true):*{
			return _parse(string,deepParse,true);
		}
		private static function _parse(string:String, deepParse:Boolean, stripQuotes:Boolean):*{
			var strippedStr:String = stripWhite(string);
			if(strippedStr=="true"){
				return true;
			}
			if(strippedStr=="false"){
				return false;
			}
			if(strippedStr=="NaN"){
				return NaN;
			}
			var array:Array = _parseArray(strippedStr,deepParse,stripQuotes);
			if(array){
				return array;
			}
			var object:Object = _parseObject(strippedStr,deepParse,stripQuotes);
			if(object){
				return object;
			}
			var number:Number = _parseNumber(strippedStr,true);
			if(!isNaN(number)){
				return number;
			}
			if(stripQuotes){
				return StringParser.stripQuotes(string);
			}else{
				return string;
			}
		}
		public static function parseNumber(string:String, confirmChars:Boolean):Number{
			string = stripWhite(string);
			return _parseNumber(string, confirmChars);
		}
		private static function _parseNumber(string:String, confirmChars:Boolean):Number{
			var hexMode:Boolean = false;
			if (string.indexOf("0x") == 0) {
				hexMode = true;
				string = string.substr(2);
			}else if (string.indexOf("#") == 0) {
				hexMode = true;
				string = string.substr(1);
			}
			
			if(hexMode){
				if(!confirmChars || HEX_NUMBER_CHECK.test(string)){
					return parseFloat("0x"+string);
				}
			}else{
				if(!confirmChars || NUMBER_CHECK.test(string)){
					return parseFloat(string);
				}
			}
			return NaN;
		}
		public static function parseArray(string:String, deepParse:Boolean=true):Array{
			string = stripWhite(string);
			return _parseArray(string,deepParse,false);
		}
		private static function _parseArray(string:String, deepParse:Boolean, stripQuotes:Boolean):Array{
			var lastChar:int = string.length-1;
			if(string.charAt(0)=="[" && string.charAt(lastChar)=="]"){
				var array:Vector.<String> = parseCSV(string.substring(1,string.length-1));
				var ret:Array = [];
				var value:String;
				if(deepParse){
					for each(value in array){
						ret.push(_parse(value,true,stripQuotes));
					}
				}else{
					for each(value in array){
						ret.push(value);
					}
				}
				return ret;
			}
			return null;
		}
		public static function parseObject(string:String, deepParse:Boolean=true):Object{
			string = stripWhite(string);
			return _parseObject(string,deepParse,false);
		}
		private static function _parseObject(string:String, deepParse:Boolean, stripQuotes:Boolean):Object{
			var lastChar:int = string.length-1;
			if(string.charAt(0)=="{" && string.charAt(lastChar)=="}"){
				var props:Vector.<String> = parseCSV(string.substring(1,string.length-1));
				var ret:Object = {};
				var keyValue:String;
				var pair:Vector.<String>;
				for each(keyValue in props){
					pair = parseSeperatedList(keyValue,":");
					if(pair.length!=2){
						return null;
					}else{
						var prop:String = pair[0];
						if(stripQuotes){
							prop = StringParser.stripQuotes(prop);
						}
						if(deepParse)ret[prop] = _parse(pair[1],true,stripQuotes);
						else ret[prop] = pair[1];
					}
				}
				return ret;
			}
			return null;
		}
		
		private static function stripQuotes(prop:String):String{
			var match:Array = QUOTE_STRIPPER.exec(prop);
			if(match){
				return match[1];
			}else{
				return prop;
			}
		}
		
		public static function parseCSV(string:String):Vector.<String>{
			return parseSeperatedList(string,",");
		}
		public static function parseSeperatedList(string:String, seperator:String):Vector.<String>{
			var lastChar:int = string.length;
			var ret:Vector.<String> = new Vector.<String>();
			var pos:int=0;
			var open:Vector.<String> = new Vector.<String>();
			var nextEscaped:Boolean;
			var isInString:Boolean;
			var lastOpen:String;
			var itemStart:int=pos;
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
						case seperator:
							if(!open.length && !lastOpen){
								ret.push(string.substring(itemStart,pos));
								itemStart = pos+1;
							}
							break;
					}
				}
				++pos;
			}
			if(itemStart!=pos)ret.push(string.substring(itemStart,pos));
			return ret;
		}
		
		private static function stripWhite(string:String):String{
			var result:Object = STRIPPER.exec(string);
			if(result){
				return result[1];
			}else{
				return null;
			}
		}
	}
}