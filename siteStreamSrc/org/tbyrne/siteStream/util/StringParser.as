package org.tbyrne.siteStream.util
{
	

	public class StringParser
	{
		private static const STRIPPER:RegExp = /^\s*(.*)\s*$/s;
		private static const NUMBER_CHECK:RegExp = /^\d+$/s;
		private static const HEX_NUMBER_CHECK:RegExp = /^[\dabcdef]+$/is;
		
		
		public static function parse(string:String, deepParse:Boolean=true):*{
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
			var array:Array = _parseArray(strippedStr,deepParse);
			if(array){
				return array;
			}
			var object:Object = _parseObject(strippedStr,deepParse);
			if(object){
				return object;
			}
			var number:Number = _parseNumber(strippedStr,true);
			if(!isNaN(number)){
				return number;
			}
			return string;
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
			return _parseArray(string,deepParse);
		}
		private static function _parseArray(string:String, deepParse:Boolean):Array{
			var lastChar:int = string.length-1;
			if(string.charAt(0)=="[" && string.charAt(lastChar)=="]"){
				var array:Vector.<String> = parseCSV(string.substring(1,string.length-1));
				var ret:Array = [];
				var value:String;
				if(deepParse){
					for each(value in array){
						ret.push(parse(value));
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
			return _parseObject(string,deepParse);
		}
		private static function _parseObject(string:String, deepParse:Boolean):Object{
			var lastChar:int = string.length-1;
			if(string.charAt(0)=="{" && string.charAt(lastChar)=="}"){
				var props:Vector.<String> = parseCSV(string.substring(1,string.length-1));
				var ret:Object = {};
				for each(var keyValue:String in props){
					var pair:Vector.<String> = parseSeperatedList(keyValue,":");
					if(pair.length!=2){
						return null;
					}else{
						if(deepParse)ret[pair[0]] = parse(pair[1]);
						else ret[pair[0]] = pair[1];
					}
				}
				return ret;
			}
			return null;
		}
		public static function parseCSV(string:String):Vector.<String>{
			return parseSeperatedList(string,",");
		}
		private static function parseSeperatedList(string:String, seperator:String):Vector.<String>{
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
							if(!open.length){
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