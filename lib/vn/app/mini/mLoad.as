package vn.app.mini 
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	/**
	 * ...
	 * @author thienhaflash (thienhaflash@gmail.com)
	 */
	public class mLoad {
		public var callback			: Object;
		
		public var path 			: String;
		public var noCache			: String;
		public var version			: String;
		public var context			: LoaderContext; //so we can tweak for each instance
		
		private var _queue			: Array = [];
		private var _isLocal		: Boolean;
		private var _ignorePath		: Boolean;
		private var _progress		: Number;
		
		public function mLoad(callback: Object, basePath: String = '', noCache: String = 'v.1.0') {//inject vars
			this.path		= basePath;
			this.noCache 	= noCache;
			this.version 	= version;
			
			_progress		= 0;
			
			this.callback	= (callback && callback.hasOwnProperty('progress')) ? callback : null;
			this._isLocal	= Capabilities.playerType == 'StandAlone' || Capabilities.playerType == 'External';
			this.context	= new LoaderContext(true, ApplicationDomain.currentDomain);
		}
		
		
		public function updateURL(url: String): String {
			if (!url) return null;
			
			if (!_ignorePath && url.indexOf('http://') == -1) {//prepend appPath to relative url that are not appConfig (appConfig should NOT be affects by appPath)
				if (path && url.indexOf('../') != -1 && path.indexOf('/') != -1) {//resolve when there are ../ in url
					var arr		: Array		= url.split('../');
					var arr2 	: Array		= path.split('/');
					var n		: int		= Math.min(arr.length - 1, arr2.length-1);
					var url2	: String	= arr[n];
					var path2	: String	= (n == arr2.length-1) ? '' : arr2.slice(0, arr2.length - n).join('/');
					
					url = path2 + url2;
				} else {
					url = path + url;
				}
			}
			
			if (!_isLocal && noCache && url.indexOf(noCache) == -1) url	+=	(url.indexOf('?') == -1 ? '?' : '&') + noCache;
			return url;
		}
		
		public function data(url: String, onComplete: Function = null, onError: Function = null, onProgress: Function = null, ignoreAppPath: Boolean = false): URLLoader {
			if (!url) return null;
			
			var ld : URLLoader = new URLLoader();
			
			if (onComplete != null) ld.addEventListener(Event.COMPLETE, onComplete);
			if (onProgress != null) ld.addEventListener(ProgressEvent.PROGRESS, onProgress);
			ld.addEventListener(IOErrorEvent.IO_ERROR, onError != null ? onError : trace);
			ld.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError != null ? onError : trace);
			ld.addEventListener(ProgressEvent.PROGRESS, checkProgress);
			
			ld.load(new URLRequest(updateURL(url)));
			_queue.push(ld);
			return ld;
		}
		
		public function graphic(url: String, onComplete: Function = null, onError: Function = null, onProgress: Function = null, ignoreAppPath: Boolean = false): Loader {
			if (!url) return null;
			var ld		: Loader		= new Loader();
			var info	: LoaderInfo	= ld.contentLoaderInfo;
			
			info.addEventListener(IOErrorEvent.IO_ERROR, onError != null ? onError : trace);			
			info.addEventListener(ProgressEvent.PROGRESS, checkProgress);
			if (onComplete != null) info.addEventListener(Event.COMPLETE, onComplete);
			if (onProgress != null) info.addEventListener(ProgressEvent.PROGRESS, onProgress);
			
			if (!context) context = new LoaderContext(true, ApplicationDomain.currentDomain);
			ld.load(new URLRequest(updateURL(url)), context);
			_queue.push(info);
			return ld;
		}
		
		private function checkProgress(e: Event): void {
			var l		: int = _queue.length;
			_progress = 0;
			for (var i: int = 0; i < l; i++) {
				_progress += _queue[i].bytesTotal >0 ? (_queue[i].bytesLoaded / _queue[i].bytesTotal) / l : 0;
			}
			
			if (callback) callback.progress = _progress;
		}
		
		public function clearQueue(forceStop: Boolean = false): void {
			if (forceStop) {
				var l	: int = _queue.length;
				for (var i: int = 0; i < l; i++) {
					_queue[i].removeEventListener(ProgressEvent.PROGRESS, checkProgress);
					
					try {
						if (_queue[i] is LoaderInfo) {
							(_queue[i] as LoaderInfo).loader.close();
							(_queue[i] as LoaderInfo).loader.unload();
						} else {
							(_queue[i] as URLLoader).close();
						}
					} catch (e: Error) { trace(e) };
				}
			}
			_queue	= [];
			_progress	= 0;
		}
		
		public function get progress():Number { return _progress; }
		public function get ignoreBasePath():Boolean { return _ignorePath; }
		public function set ignoreBasePath(value:Boolean):void  { _ignorePath = value; }
	}

}