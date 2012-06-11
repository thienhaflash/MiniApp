package vn.app.mini 
{
	/**
	 * ...
	 * @author thienhaflash (thienhaflash@gmail.com)
	 */
	public class mObject {
		public static function populate(props: Object, ...list): void {
			var itm : * ;
			var l	: int = list.length;
			for (var i: int = 0; i < l; i++) {
				itm = list[i];
				
				for (var s : String in props) {
					itm[s] = props[s];
				}
			}
		}
		
		public static function clone(src: Object): Object {
			var obj : Object = { };
			for (var s : String in src) { obj[s] = src[s]; }
			return obj;
		}
		
		public static function toString(obj: Object): String {
			var str : String = '';
			for (var s : String in obj) { str += s + ':' + obj[s] + '\n'; };
			return str;
		}
		
		public static function copy(to:Object, from:Object):Object {
			for (var s: String in from) { to[s] = from[s]; }
			return to;
		}
	}
}