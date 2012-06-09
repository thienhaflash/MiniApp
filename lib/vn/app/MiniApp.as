package vn.app 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.ColorTransform;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * 
	 * @author thienhaflash (thienhaflash@gmail.com)
	 */
	public class MiniApp {
		public static const APP_UPDATE	: String = '2012.06.09';
		public static const APP_VERSION : String = '0.1.0';
		
		
	/*********************
	 *		STATIC
	 *********************/		
		
		public static var main : MiniApp;
	 
		
	/*********************
	 *	INIT / RESTART
	 *********************/
		
		public function MiniApp(app: Object = null, config: Object = null, appId: String = null) {//flashvars map name->id
			if (!(app is DisplayObjectContainer)) throw new Error('[MiniApp] Can not be attached a null app');
			if (!main) main = this; //first App
			
			_app		= app as DisplayObjectContainer;
			_appId		= appId;
			_appVars	= config;
			
			_app.stage ? _initStage() :  _app.addEventListener(Event.ADDED_TO_STAGE, _initStage);
		}
		
		private function _initStage(e:Event = null): void {
			if (e) _app.removeEventListener(Event.ADDED_TO_STAGE, _initStage);
			
			_getStage();
			_getVars();
			_configURL ? load.data(_configURL, _onAppConfigLoaded) : _onAppReady();
		}
		
		private function _onAppConfigLoaded(e: Event):void {
			//check to load neccessary libraries
			
			//TODO : load libraries
			//TODO : load assets / sound / fonts /
			//TODO : support XML version caching ( ?ver= )
			//TODO : support debug layer
			//TODO : support dynamic Library
			
			//onEverything complete
			_onAppReady(XML(e.currentTarget.data));
		}
		
		private function _onAppReady(data: XML = null): void {
			_appXML = data;
			_callApp('miniInit', [data]);
		}
		
	/*********************
	 *		SHORTCUTS
	 *********************/	
		
		private function _callApp(funcName: String, params: Array = null): void {
			if (_app.hasOwnProperty(funcName) && _app[funcName] is Function) (_app[funcName] as Function).apply(null, params);
		}
		
		private function _getStage(): void {
			_stage 				= _app.stage;
			if (!_appVars || _appVars.preventStageDefault != true) {
				_stage.scaleMode	= StageScaleMode.NO_SCALE;
				_stage.align		= StageAlign.TOP_LEFT;
			}
			
			if (!_appVars || _appVars.preventContextMenuDefault != true) {
				contextMenu.add(_app, _appId || ('MiniApp v.' + APP_VERSION));
			}
		}
		
		private function _getVars(): void {
			var pathName 		: String = 'path';
			var configURLName	: String = 'config';
			
			if (_appVars && _appVars.mapFlashvars) { //allow reconfig flash variables names for path / config
				pathName		= _appVars.mapFlashvars['path'];
				configURLName	= _appVars.mapFlashvars['config'];
			}
			
			//get flashvars
			var p : DisplayObjectContainer = _app;
			while (p.parent) { p = p.parent };
			_flashvars	= p.root.loaderInfo.parameters;
			
			//get appVars
			_appVars ||= { }; //allow default appvars
			if (_appId) {
				for (var s : String in _flashvars) {
					if (s.indexOf(_appId + '.') == 0) _appVars[s.split(_appId+'.')[1]] = _flashvars[s];
				}
			} else {//no _appId : there are only 1 app here, no need to have _appId. style config
				(_appVars, _flashvars);
			}
			
			load.appPath	= _appVars[pathName] || '';
			_configURL		= _appVars[configURLName] || 'config.xml';
		}
		
		
	/*********************
	 *		APP VARS
	 *********************/
		
		private var _app		: DisplayObjectContainer; //the actual app
		private var _stage		: Stage;
		private var _flashvars	: Object;
		private var _configURL	: String;
		
		private var _appId		: String;
		private var _appDebug	: Boolean;
		private var _appVars	: Object;
		private var _appXML		: XML;
		
		public function get app()			: DisplayObject		{ return _app }
		public function get stage()			: Stage				{ return _stage }
		
		public function get appId()			: String			{ return _appId }
		public function get appDebug()		: Boolean 			{ return _appDebug }
		public function get appVars()		: Object 			{ return _appVars }
		public function get appPath()		: String			{ return load.appPath }
		public function get appXML()		: String			{ return _appXML }
		public function get flashvars()		: Object			{ return _flashvars }
		
	/*********************
	 *	MINI LIBRARY
	 ********************/
		
		public function get tween()			: MiniTween			{ return MiniTween.instance; }
		public function get load()			: MiniLoad			{ return MiniLoad.instance; }
		
		public function get button()		: MiniButton 		{ return MiniButton.instance; }
		public function get movieClip()		: MiniMovie			{ return MiniMovie.instance; }
		public function get object()		: MiniObject		{ return MiniObject.instance; }
		public function get display()		: MiniDisplay		{ return MiniDisplay.instance; }
		public function get contextMenu()	: MiniContextMenu	{ return MiniContextMenu.instance; }
		public function get event()			: MiniEvent			{ return MiniEvent.instance; }
		public function get graphics()		: MiniGraphics		{ return MiniGraphics.instance; }
		public function get utils()			: MiniUtils			{ return MiniUtils.instance; }
	}
}

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.media.Sound;
import flash.net.navigateToURL;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

class MiniTween {
	internal static var instance : MiniTween = new MiniTween();
	//aim
	//aimGroup
}

class MiniLoad {
	internal static var instance : MiniLoad = new MiniLoad();
	
	private var _ldContext	: LoaderContext;
	public var appPath		: String;
	public var noCache		: Boolean;
	
	public function updateURL(url: String): String {
		if (!url) return null;
		
		if (url.indexOf('http://') == -1) url = appPath + url; //prepend appPath
		if (noCache && url.indexOf('noCache') == -1) {//append noCache
			url += (url.indexOf('?') == -1) ? '?noCache=' : '&noCache=' + Math.random();
		}
		return url;
	}
	
	public function data(url: String, onComplete: Function, onError: Function = null, onProgress: Function = null): URLLoader {
		if (!url) return null;
		url = updateURL(url);
		
		var ld : URLLoader = new URLLoader();
		if (onComplete != null) ld.addEventListener(Event.COMPLETE, onComplete);
		ld.addEventListener(IOErrorEvent.IO_ERROR, onError != null ? onError : trace);
		ld.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError != null ? onError : trace);
		ld.load(new URLRequest(url));
		return ld;
	}
	
	public function graphic(url: String, onComplete: Function, onError: Function = null, onProgress: Function = null): Loader {
		if (!url) return null;
		url = updateURL(url);
		
		var ld		: Loader		= new Loader();
		var info	: LoaderInfo	= ld.contentLoaderInfo;
		
		ld.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError != null ? onError : trace);
		if (onComplete != null) ld.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		if (onProgress != null) ld.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
		if (!_ldContext) _ldContext = new LoaderContext(true, ApplicationDomain.currentDomain);
		ld.load(new URLRequest(url), _ldContext);
		return ld;
	}
	
	public function sound(url: String, buffTime: int): Sound {
		//TODO : do load sound
		return null;
	}
	
	public function loadVideo(): void {
		
	}
}

class MiniDisplay {
	internal static var instance : MiniDisplay = new MiniDisplay();
}

class MiniContextMenu {
	internal static var instance : MiniContextMenu = new MiniContextMenu();
	/**
	
	SAMPLE USAGE 	:
		
	1.	setContextMenu(pdo,	//one caption mapping to an onSelect handler
			'home',			onSelectHome,
			'about us',		onSelectAbout,
			'profile',		onSelectProfile,
			'portfolio',	onSelectPortfolio
		);
		
	2.	setContextMenu(pdo, //use '' in place of separators & skip the handlers for NON-clickable items
			'version 1.0',
			'copyright(c) 2012 by MiniApp',
			'',
			'home',			onSelectHome,
			'about us',		onSelectAbout,
			'profile',		onSelectProfile,
			'portfolio',	onSelectPortfolio
		);
		
	3.	setContextMenu(pdo, //use Object instead of the item list
			'version 1.0', 
			'copyright(c) 2012 by MiniApp',
			'', 
			{	home		: onSelectHome,
				'about us'	: onSelectAbout,
				profile 	: onSelectProfile,
				portfolio	: onSelectPortfolio,
				'show Reel'	: onSelectShowReel,
				contact		: onSelectContact,
				info		: onSelectInfo
			}
		);
		
	4.	setContextMenu(pdo, //use Array to group items that shares the same onSelect hander
			['version 1.0', 'copyright(c) 2012 by MiniApp', ''],
			['home', 'about us', 'profile', 'portfolio'], onSelectMenuItem
		);
		
		
	//TODO :	SUPPORT FOR ADVANCED OBJECT CONTEXT MENU
	5.	setContextMenu(pdo, //use advanced object have more powerful tweaks : rename / disable / enable / prepend / append / hide / show
			{	'rename' : [	
					0,			'Version 1.0 RC - r238',
					6,			'Video'
					'home',		'-> Home'
					'file', 	'Client Profile',
					'about',	'About our company'
				]
			}
		);
		
	**/
	public function add(pdo: InteractiveObject, ...list): ContextMenu {
		var menu : ContextMenu = pdo.contextMenu || new ContextMenu();
		menu.hideBuiltInItems();
		
		var i		: int;
		var item	: * ;
		var tmp		: * ;
		var obj		: Object;
		var capsArr	: Array;
		var isFunc	: Boolean;
		var sep		: Boolean;
		var l		: int = list.length;
		var cmiArr 	: Array = menu.customItems || [];
		
		while (i < l) {
			item	= list[i++];
			if (!item) { sep = true; continue; } //null or '' item mean separator
			
			capsArr = item is String ? [item] : item is Array ? item : null;
			
			if (capsArr) {
				tmp	= i < l ? list[i] : null;
				isFunc	= tmp is Function;
				
				for (var j: int = 0; j < capsArr.length; j++) {
					sep = !capsArr;
					if (!sep) cmiArr.push(newItem(capsArr[j], isFunc ? tmp : null, sep, isFunc));
				}
				if (isFunc) i++; //have onSelect cost 1 more element in list
			} else {//must be an Object (complex item)
				obj = item;
				for (var s : String in obj) {
					tmp = obj[s];
					isFunc = tmp is Function;
					if (isFunc) cmiArr.push(newItem(s, tmp));
				}
			}
		}
		
		menu.customItems = cmiArr;
		pdo.contextMenu = menu;
		return menu;
	}
	
	public function newItem(caption: String, onSelect: Function = null, separatorBefore: Boolean = false, enabled: Boolean = true, visible: Boolean = true): ContextMenuItem {
		var mi : ContextMenuItem = new ContextMenuItem(caption, separatorBefore, enabled, visible);
		if (onSelect != null) mi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onSelect);
		return mi;
	}
	
	public function rename(): ContextMenu {
		var menu : ContextMenu;
		return menu;
	}
	
	//public function hasCustomContextMenuItems(pdo: InteractiveObject): Boolean {
		//return (pdo.contextMenu as ContextMenu).customItems && (pdo.contextMenu as ContextMenu).customItems.length > 0;
	//}
}

class MiniButton {
	internal static var instance : MiniButton = new MiniButton();
	
}

class MiniMovie {
	static public var instance : MiniMovie;
}

class MiniGraphics {
	static public var instance : MiniGraphics;
}

class MiniUtils {
	internal static var instance : MiniUtils = new MiniUtils();
	
	public function getURL(url: String, windows: String = '_blank'): void {
		navigateToURL(new URLRequest(url), windows);
	}
	
	
	//public function getFlashVars(pdo : DisplayObject): Object {
		//if (!pdo.stage) return null; //not yet added to stage, can not get flashvars
		//var p : DisplayObjectContainer = pdo;
		//while (p.parent) { p = p.parent };
		//return p.root.loaderInfo.parameters;
	//}
	
	
	//getQueue
		
	//getJSWindow
	//getJS....
	
	//copyObj
	//shuffleArray
	//getExtension
	
	//drag
	//addJSCallbacks()
}

class MiniMath {
	public function interpolateObject(st: Object, ed: Object, percent: Number, target: Object = null): Object {
		if (!target) target = { };
		
		for (var s: String in st) {
			target[s] = st[s] + (ed[s] - st[s]) * percent;
		}
		return target;
	}
	
	//public function interpolate(listOfValues: Array, percent: Number): Number {
		//
	//}
}

class MiniObject {
	public static var instance : MiniObject = new MiniObject();
	
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
}

class MiniEvent {
	static public var instance : MiniEvent = new MiniEvent;//addLsn
	//removeLsn
	
	
}

class MiniDebug {
	
	public var traceErrors	: Boolean	= true;
	public function showError(functionName: String, ...rest): void {
		if (!traceErrors) return;
		
		var s	: String = 'KDisplay.' + functionName + ' fail with';
		var tmp	: String;
		var l	: int = rest.length;
		var cdo	: DisplayObject;
		
		for (var i: int = 0; i < l; i += 2) {
			cdo = rest[i + 1];
			
			if (cdo) {
				tmp = cdo.name || String(cdo);
				while (cdo.parent) { //get full name from the root
					cdo = cdo.parent;
					if (cdo == cdo.stage) {
						tmp = 'stage.' + tmp;
						break;
					}
					tmp = (cdo.name || cdo) +'.' + tmp;
				}
				s += ' [' + rest[i] + '=' + tmp + ']';
			} else {
				s += ' [' + rest[i] + '=' + rest[i + 1] +']';
			}
		}
		trace(s);
	}
}

class MiniScroller {
	
}

class MiniMenu {
	
}

