package vn.app.mini 
{
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author thienhaflash (thienhaflash@gmail.com)
	 */
	public class mUtils {
		
		public static function getURL(url: String, windows: String = '_blank'): void {
			navigateToURL(new URLRequest(url), windows);
		}
		
		public static function get object(): mObject { return mObject.instance ||= new mObject(); }
	}
}

class mObject {
	
	public static var instance : mObject;
	
	public function populate(props: Object, ...list): void {
		var itm : * ;
		var l	: int = list.length;
		for (var i: int = 0; i < l; i++) {
			itm = list[i];
			
			for (var s : String in props) {
				itm[s] = props[s];
			}
		}
	}
	
	public function clone(src: Object): Object {
		var obj : Object = { };
		for (var s : String in src) { obj[s] = src[s]; }
		return obj;
	}
	
	public function toString(obj: Object): String {
		var str : String = '';
		for (var s : String in obj) { str += s + ':' + obj[s] + '\n'; };
		return str;
	}
	
	public function copy(to:Object, from:Object):Object {
		for (var s: String in from) { to[s] = from[s]; }
		return to;
	}
}
