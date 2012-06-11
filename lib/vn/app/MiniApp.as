package vn.app 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import vn.app.mini.mDisplay;
	import vn.app.mini.mLoad;
	
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
		
		private var _miniLoad	: mLoad;
		private var _miniVars	: mVars;
	 
		public function MiniApp(app: Object = null, config: Object = null, appId: String = null, appVersion: String = null) {
			if (!(app is DisplayObjectContainer)) throw new Error('[MiniApp] Can not be attached a null app');
			if (!main) main = this; //first App
			
			_miniVars	= new mVars(appId, config, appVersion || APP_VERSION);
			_miniLoad	= new mLoad(_miniVars);
			_app		= app as DisplayObjectContainer;
			_app.stage ? _init() :  _app.addEventListener(Event.ADDED_TO_STAGE, _init);
		}
		
		private function _init(e:Event = null): void {
			if (e) _app.removeEventListener(Event.ADDED_TO_STAGE, _init);
			
			mDisplay.initStage(_app);
			_miniVars.getVars(_app);
			_miniVars.appConfig ? _miniLoad.data(_miniVars.appConfig, _onAppConfigLoaded) : _onAppReady();
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
		
	/*********************
	 *		APP VARS
	 *********************/
		
		private var _app		: DisplayObjectContainer; //the actual app
		private var _appXML		: XML;
		
		public function get app()			: DisplayObject		{ return _app }
		public function get appId()			: String			{ return _miniVars.appId }
		public function get appXML()		: String			{ return _appXML }
		
		public function get appDebug()		: Boolean 			{ return _miniVars.appDebug }
		public function get appVars()		: Object 			{ return _miniVars.appVars }
		public function get appPath()		: String			{ return _miniVars.appPath }
		
	/*********************
	 *	MINI LIBRARY
	 ********************/
		
		public function get load():mLoad  { return _miniLoad; }
		
	}
}

import flash.display.DisplayObject;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import vn.app.mini.mContextMenu;
import vn.app.mini.mDisplay;
import vn.app.mini.mObject;

class mVars {
	public var appId		: String;
	public var appVars		: Object;
	
	public var appPath		: String;
	public var appConfig	: String;
	public var appCache		: String;
	public var appVersion 	: String;
	public var appDebug		: Boolean;
	public var appIsLocal	: Boolean;
	
	private var map	: Object = { //mapping flashvar names
		appPath		: 'path',
		cacheMode	: 'cacheMode',		/* time, version, none */
		configURL	: 'config',		/* xml path */
		debug		: 'debug',
		noCache		: 'noCache'
	}
	
	public function mVars(id: String, vars: Object, version : String = null) {
		appVars 	= vars;
		appId		= id || vars.id;
		appPath 	= '';
		appVersion	= version || '';
	}
	
	public function getVars(app: DisplayObject): void {
		if (appVars && appVars.map) mObject.copy(map, appVars.map); //copy default props
		var cnt : int;
		if (appId) {//try to get vars
			for (var s : String in mDisplay.flashvars) {
				if (s.indexOf(appId + '.') == 0) {
					cnt++;
					appVars[s.split(appId+'.')[1]] = mDisplay.flashvars[s];
				}
			}
		} 
		if (cnt == 0) mObject.copy(appVars, mDisplay.flashvars);
		appConfig		= appVars[map.configURL] || 'config.xml';
		appPath			= appVars[map.appPath] || '';
		appCache		= appVars[map.cacheMode] || 'none';
		
		if (!appVars || !appVars.preventContextMenuDefault) mContextMenu.add(app, appId || ('MiniApp v.' + appVersion));
		if (!appVars || appVars.preventStageDefault != true) {
			mDisplay.stage.scaleMode	= StageScaleMode.NO_SCALE;
			mDisplay.stage.align		= StageAlign.TOP_LEFT;
		}
	}
}