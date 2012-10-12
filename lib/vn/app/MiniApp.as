package vn.app 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import vn.app.mini.mDisplay;
	import vn.app.mini.mLoad;
	import vn.app.mini.mUtils;
	
	/**
	 * 
	 * @author thienhaflash (thienhaflash@gmail.com)
	 */
	public class MiniApp {
		public static const APP_UPDATE	: String = '2012.10.12';
		public static const APP_VERSION : String = '0.1.1';
		
		
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
			
			if (!_init(_app.stage || config.stage)) {
				_app.addEventListener(Event.ADDED_TO_STAGE, function (e: Event): void {
					_app.removeEventListener(Event.ADDED_TO_STAGE, arguments.callee);
					_init(_app.stage);
				});
			}
		}
		
		private function _init(stageRef : Stage): Boolean {
			if (stageRef == null) return false;
			
			mDisplay.initStage(stageRef);
			_miniVars.getVars(_app);
			if (_miniVars.appDebug) trace(this, "_init::flashvars{\n" + mUtils.object.toString(appVars) + "}");
			
			//BUGFIXED : delay 1 frame so that the reference to this MiniApp got ready.
			_app.addEventListener(Event.ENTER_FRAME, function (e: Event): void {
				_app.removeEventListener(Event.ENTER_FRAME, arguments.callee);
				_miniVars.appConfig ? _miniLoad.data(_miniVars.appConfig, _onAppConfigLoaded) : _onAppReady();
			});
			
			return true;
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
			if (_miniVars.appDebug) trace(this, "_onAppReady::config{"+data+"}");
			
			_appXML = data;
			_callApp('miniInit', [data]);
			
			//add default event handlers
			if (_appHasFunction("onStageResize")) {
				mDisplay.stage.addEventListener(Event.RESIZE, _app['onStageResize']);
				_app['onStageResize'](null);
			}
		}
		
	/*********************
	 *		SHORTCUTS
	 *********************/	
		
		private function _appHasFunction(funcName: String): Boolean {
			return _app && _app.hasOwnProperty(funcName) && _app[funcName] is Function;
		}
		
		private function _callApp(funcName: String, params: Array = null): void {
			if (_appHasFunction(funcName)) (_app[funcName] as Function).apply(null, params);
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
import vn.app.mini.mDisplay;
import vn.app.mini.mUtils;

class mVars {
	public var appId		: String;
	public var appVars		: Object;
	
	public var appPath		: String;
	public var appConfig	: String;
	public var appCache		: String;	
	public var appVersion 	: String;
	public var appDebug		: Boolean;
	
	private var map	: Object = {	//mapping flashvar names
		appPath		: 'path'	,		
		appConfig	: 'config'	,	/* xml path */
		appCache	: 'cache'	,	/* time, version, none */
		appVersion 	: 'version'	,
		appDebug	: 'debug'
	}
	
	public function mVars(id: String, vars: Object, version : String = null): void {
		appVars 	= vars;
		appId		= id || vars.id;
		
		appPath		= vars.appPath		|| '';
		appConfig	= vars.appConfig	|| null;
		appCache	= vars.appCache 	|| 'none';
		appVersion 	= version			|| vars.appVersion;
		appDebug	= vars.appDebug;
	}
	
	public function getVars(app: DisplayObject): void {
		if (appVars && appVars.map) mUtils.object.copy(map, appVars.map); //copy default props
		var cnt : int;
		
		if (appId) {//try to get vars
			for (var s : String in mDisplay.flashvars) {
				if (s.indexOf(appId + '.') == 0) {
					cnt++;
					appVars[s.split(appId+'.')[1]] = mDisplay.flashvars[s];
				}
			}
		}
		
		if (cnt == 0) mUtils.object.copy(appVars, mDisplay.flashvars);
		
		appPath		= appVars[map.appPath] 		|| appPath;
		appConfig	= appVars[map.appConfig]	|| appConfig;
		appCache	= appVars[map.appCache]		|| appCache;
		appVersion 	= appVars[map.appVersion]	|| appVersion;
		appDebug	= appVars[map.appDebug]		|| appDebug;
		
		if (!appVars || !appVars.preventDefaultContextMenu) mDisplay.contextMenu.add(app, (appId ? appId : 'MiniApp') +' v.' + appVersion);
		if (!appVars || appVars.preventStageDefault != true) {
			mDisplay.stage.scaleMode	= StageScaleMode.NO_SCALE;
			mDisplay.stage.align		= StageAlign.TOP_LEFT;
		}
	}
}