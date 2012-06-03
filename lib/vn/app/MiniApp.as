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
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author 
	 */
	public class MiniApp {
		
		public function MiniApp(app : Object, appId: String = null, resetStageToDefault: Boolean) {
			if (!_mainApp) _mainApp = this; //first app
			
			_app		= app as DisplayObject;
			_appId		= appId;
			_lib		= new MiniAppLib();
			
			if (!_app) throw new Error('[MiniApp] Can not instantiate a null app');
			_resetStageDefault	= resetStageToDefault;
			_app.stage ? _getFlashVars() :  _app.addEventListener(Event.ADDED_TO_STAGE, _getFlashVars);
		}
		
		
		
		
	/***********************
	 * 		CORE
	 ***********************/	
		
		private var _app		: DisplayObject; //the actual app
		private var _appId		: String;
		private var _flashvars	: Object;
		private var _stage		: Stage;
		
		private var _isAppReady			: Boolean;
		private var _resetStageDefault	: Boolean;
		
		private var _dispatcher			: EventDispatcher;
		
		private function _setStageDefault(): MiniApp {
			_app.stage.scaleMode	= StageScaleMode.NO_SCALE;
			_app.stage.align		= StageAlign.TOP_LEFT;
		}
		
		private function _callApp(funcName: String, params: Array = null): void {
			if (_app.hasOwnProperty(funcName)) {
				(_app[funcName] as Function).apply(null, params);
			}
		}
		
	/***********************
	 * 		LIBRARY
	 ***********************/
		
		public var encoder		: EncoderWrapper;
		public var soundManager	: SoundManagerWrapper;
		public var langManager	: LanguageManagerWrapper;
		public var userManager	: UserManagerWrapper;	
		//public var fontManager	: FontManagerWrapper;
		
		
	/***********************
	 * 		EVENT SYSTEM
	 ***********************/	
		
		
		//TODO : add Event System support
		
		
		
	/***********************
	 * 		CONFIGURATION
	 ***********************/	
		
		//path
		public var appPath	: String;
		private var xmlPath	: String;
		
		private function _getFlashVars(e: Event = null):void {
			if (e) _app.removeEventListener(Event.ADDED_TO_STAGE, _getFlashVars);
			
			_stage = _app.stage;
			if (setStageDefault) _setStageDefault();
			
			var tmp : Object = _app.root.loaderInfo.parameters;
			
			if (_appId && tmp[_appId]) {//support _appId flashvars
				_flashvars = tmp[_appId];
			} else {
				_flashvars = tmp;
				if (_appId) { //support appId.appPath / appId.xmlPath
					appPath = _flashvars[_appId + '.appPath'];
					xmlPath = _flashvars[_appId + '.xmlPath'];
				}
			}
			
			if (!appPath) appPath = _flashvars['appPath'] || '';
			if (!xmlPath) xmlPath = _flashvars['xmlPath'] || 'appConfig.xml';
			if (xmlPath) {
				_configLoader = loadData(xmlPath, _onAppConfigLoaded);
			} else {//no xmlPath defined : no libraries ...
				_onAppReady();
			}
		}
		
		//TODO : support App reload ?
		private var _configLoader	: URLLoader;
		
		private function _onAppConfigLoaded(e: Event):void {
			//check to load neccessary libraries
			
			//TODO : load assets
			//TODO : load libraries
			//TODO : load sound / fonts / assets
			//TODO : support XML version caching ( ?ver= )
			//TODO : support debug layer
			//TODO : support dynamic Library
			
			//onEveryting complete
			_onAppReady();
		}
		
		private function _onAppReady(): void {
			_isAppReady = true;
			_callApp('init', _configLoader ? [XML(_configLoader.data)] : null);
		}
		
	/*************************
	 * 		LIBRARY
	 *************************/
		
		private var _library : MiniAppLibrary;
		
		
		
	/*************************
	 * 		CONTEXT MENU
	 *************************/	
		
		
		
	/*************************
	 * 		CORE AS3
	 *************************/
		
		public function populateProps(props: Object, ...list): void {
			var itm : * ;
			var l	: int = list.length;
			for (var i: int = 0; i < l; i++) {
				itm = list[i];
				
				for (var s : String in props) {
					itm[s] = props[s];
				}
			}
		}
		
		
			
		public function getURL(url: String, windows: String = '_blank'): void {
			navigateToURL(new URLRequest(url), windows);
		}
		
		public function midObj(): void {
			
		}
		
		//addLsn
		//removeLsn
		//align / scale
		//bitmapShot
		
		
		//getQueue
		
		//getJSWindow
		//getJS....
		
		//copyObj
		//shuffleArray
		//getExtension
		
		//drag
		//addJSCallbacks()
		
	/************************
	 * 		CACHE SUPPORT
	 ************************/
		
		//TODO : support cache, use ID / timeStamp
		
		
	/*************************
	 * 	SIMPLE LABEL BUTTON
	 *************************/	
		
		//TODO : add simple label button support
		
	/***********************
	 * 		SIMPLE LOADER
	 ***********************/	
		
		private var _ldContext	: LoaderContext;
		private var _loaderRef	: Object;
	 
		public function loadData(url: String, onComplete: Function, onError: Function = null, onProgress: Function = null): URLLoader {
			var ld : URLLoader = new URLLoader();
			if (onComplete) ld.addEventListener(Event.COMPLETE, onComplete);
			ld.addEventListener(IOErrorEvent.IO_ERROR, onError != null ? onError : trace);
			ld.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError != null ? onError : trace);
			ld.load(new URLRequest(appPath + url));
		}
		
		public function loadGraphic(url: String, onComplete: Function, onError: Function = null, onProgress: Function = null): Loader {
			var ld		: Loader		= new Loader();
			var info	: LoaderInfo	= ld.contentLoaderInfo;
			ld.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError ? onError : trace);
			if (onComplete != null) ld.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			if (onProgress != null) ld.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			if (!_ldContext) _ldContext = new LoaderContext(true, ApplicationDomain.currentDomain);
			ld.load(new URLRequest(appPath + url), _ldContext);
			return ld;
		}
		
		public function loadSound(url: String, buffTime: int): void {
			//TODO : do load sound
		}
		
	/***********************
	 * 		SIMPLE TWEENER
	 ***********************/	
		
		//aim
		//aimGroup
		
	/***********************
	 * 		TWEENER
	 ***********************/
		
		private var _tweenLib	: Object;
		private var _loadLib	: Object;
		
		public function tween(target: Object, time: * , vars: Object): void { if (_tweenLib) _tweenLib.to(target, time, vars); }
		public function killTweensOf(target: Object): void 	{ if (_tweenLib) _tweenLib.killTweensOf(target); }
		
		public function load(items: * , onComplete: * = null, itemConfig: Object = null, groupConfig: Object = null, prioritize: Boolean = false): void { if (_lib.loader) _lib.loader.add(items, onComplete, itemConfig, groupConfig, prioritize); }
		//TODO : support local loader
		//TODO : support basePath for loading items
		//TODO : support for stop the loading process or cache group ?
		
	/**************************
	 * 		STATIC WRAPPER
	 **************************/ 
		
		private static var _main : MiniApp;
		
		public static function load(items: * , onComplete: * = null, itemConfig: Object = null, groupConfig: Object = null, prioritize: Boolean = false): void {
			_main.load(items, onComplete, itemConfig, groupConfig, prioritize);
		}
		
		public static function tween(target: Object, time: * , vars: Object): void {
			_main.tween(target, time, vars);
		}
	}
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.IBitmapDrawable;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.net.navigateToURL;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;


class ClassLib {
	public var dictId : Dictionary;
	
	public function ClassLib(xml: XML) {
		dictId = new Dictionary();
		
		var i		: int;
		var l		: int;
		var xmlList : XMLList;
		
		//parse classes
		xmlList	= xml.item;
		l		= xmlList.length();
		
		for (i = 0; i < l; i++) {
			var li : LibItem = new LibItem(xmlList[i]);
			dictId[li.id] = li;
		}
	}
}

class LibItem {
	public var id			: String;
	public var url			: String;
	public var type			: String;
	public var definition	: String;
	
	public var nodeType		: String; //class or manager
	
	public var lib			: Object;
	public var data			: Object;
	
	public function LibItem(xml: XML) {
		id			= String(xml.@id);
		url			= String(xml.@url);
		definition	= String(xml.@definition);
		data		= String(xml);
		
		tryToGetLib();
	}
	
	public function tryToGetLib(): * {
		if (lib) return lib;
		
		var cls : Class = getDefinitionByName(definition);
		if (lib) {
			switch (type) {
				case 'static'		: lib = cls; break;
				case 'instance'		: lib = new cls();  break;
				case 'singleton'	: lib = cls.getInstance(); break;
				//todo : support for other types
			}
		}
		return lib;
	}
	
	//TODO : support newLib() !
}

class EncoderWrapper {
	public var lib : Object;
	
	public function bmd2PNG(bm: BitmapData): ByteArray {
		
	}
	
	public function bmd2JPG(bm: BitmapData): ByteArray {
		
	}
	
	public function base64(data: *): String {
		
	}
	
	public function md5(data: *): String {
		
	}
	//TODO : how about zip / unzip ?
}

class SoundManagerWrapper {
	public var lib : Object;
	
	public function play(soundId : String, loop: int = 0, reset: Boolean = false): void {
		if (lib) lib.playSound(soundId, loop, reset);
	}
	
	public function stop(soundId: String): void {
		if (lib) lib.stopSound(soundId);
	}
	
	public function stopAll(type: String = null): void {
		if (lib) lib.stopAllSound(soundId);
	}
	
	public function setVolume(type:String = null, value: Number): void {
		if (lib) lib.setSoundVolume(type, value);
	}
	
	public function getVolume(type: String): Number {
		return lib ? lib.getSoundVolume(type) : 0;
	}
	
	public function get fxVolume():Number { return getSoundVolume('fx'); }
	public function get bgVolume():Number { return getSoundVolume('bg'); }
	
	public function set fxVolume(value: Number):void { return setSoundVolume('fx', value); }
	public function set bgVolume(value: Number):void { return setSoundVolume('bg', value); }
}

class LanguageManagerWrapper {
	public var lib : Object;
	
	public function getLangText(id: String): String {
		return _lib.langManager ? _lib.langManager.getText(id) : '';
	}
	
	public function updateLangTf(...list): void {
		if (_lib.langManager) _lib.langManager.updateTextFields.apply(null, list);
	}
	
	public function injectLang(id: String, ...data): String {
		return _lib.langManager ? _lib.langManager.inject() : ''
	}
	
	//TODO : add register/ unRegister visible textfield + refresh to allow instant refresh language
}

class UserManagerWrapper {
	
}

class DisplayLibWrapper {
	
/***************************
 *		EMBED 
 ***************************/

	private static var formatProps : Object = { align: 1, blockIndent: 1, bold: 1, bullet: 1, color: 1, font: 1, indent: 1, italic: 1, italic: 1, kerning: 1, leading: 1, leftMargin: 1, letterSpacing: 1, rightMargin: 1, size: 1, tabStops: 1, target: 1, underline: 1, url: 1 };
	
	public function drawRect(pDO: Object, pcolor: int = 0xEAEAEA, pwidth: int = 100, pheight: int = 100, palpha: Number = 1) : DisplayObject {
		var g	: Graphics =	(pDO is Sprite) ? (pDO as Sprite).graphics
								:	(pDO is Shape) ? (pDO as Shape).graphics : null;
		
		if (g) {
			g.beginFill(pcolor, palpha);
			g.drawRect(0, 0, pwidth, pheight);
			g.endFill();
		} else {
			//showError('drawRect', 'pDO', pDO);
		}
		return pDO as DisplayObject;
	}	
		
	public function removeChildren(parent:Object, returnChildren:Boolean = false, fromTop:Boolean = false, ignoreCount:int = 0):Array {
		var pp	: DisplayObjectContainer = parent as DisplayObjectContainer;
		
		if (pp) {
			var ch	: Array	= returnChildren ? [] : null;
			var n	: int	= pp.numChildren;
			var cdo	: DisplayObject;
			
			while (--n >= ignoreCount) {
				cdo = pp.removeChildAt(fromTop ? n : 0);
				if (returnChildren) ch.push(cdo);
			}
		} else {
			//showError('removeChildren', 'parent', pp);
		}
		
		return ch;
	}
	
	public function removeDO(pChild: Object): DisplayObject {
		var cdo : DisplayObject = pChild as DisplayObject;
		
		if (cdo && pChild.parent) {
			cdo.parent.removeChild(cdo);
		} else {
			//showError('removeChildrenByNames', 'pChild', pChild);
		}
		
		return cdo;
	}
	
	public function setMouse(pDO: * , pMouseEnabled: Boolean = false, pButtonMode: Boolean  = false, pMouseChildren: Boolean = false): void {
		//TODO : support array
		
		var cdo : InteractiveObject = pDO as InteractiveObject;
		
		if (cdo) {
			cdo.mouseEnabled	= pMouseEnabled;
			var sprt : Sprite	= cdo as Sprite;
			
			if (sprt) {
				sprt.buttonMode		= pButtonMode;
				sprt.mouseChildren	= pMouseChildren;
			}
		} else {
			//showError('setMouse', 'pDO', pDO);
		}
	}
	
	public function hitTestMouse(pDO: DisplayObject, shapeFlag : Boolean): Boolean {
		var cdo : DisplayObject = pDO as DisplayObject;
		
		if (!cdo) showError('hitTestMouse', 'pDO', pDO);
		return pDO && cdo.stage ? cdo.hitTestPoint(cdo.stage.mouseX, cdo.stage.mouseY, shapeFlag) : false;
	}
	
	public function newMask(pDO : Object, w: int, h: int): Shape {
		var cdo	: DisplayObject = pDO as DisplayObject;
		if (cdo) {
			var shp : Shape = drawRect(new Shape(), 0, 100, 100) as Shape;
			if (cdo.parent) cdo.parent.addChild(shp);
			
			shp.x		= cdo.x;
			shp.y		= cdo.y;
			shp.width	= w;
			shp.height	= h;
			cdo.mask	= shp;
		} else {
			//showError('newMask', 'pDO', pDO);
		}
		return shp;
	}
	
	public function newTextField(parent: Object = null, isInput: Boolean = false, w: int = 150, h: int = 25, x: int = 0, y: int = 0): TextField {
		var tf : TextField = formatTextField(new TextField(), { type		: isInput ? TextFieldType.INPUT : TextFieldType.DYNAMIC
																, multiline	: false
																, x			: x
																, y			: y
																, width		: w
																, height	: h
																, size		: 16 } );
		var pp : DisplayObjectContainer = parent as DisplayObjectContainer;
		pp ? pp.addChild(tf) : showError('newTextField', 'parent', parent);
		
		return tf;
	}
	
	public function newBitmapData(w: int, h: int, src: IBitmapDrawable, bmd: BitmapData = null): BitmapData {
		if (!bmd || bmd.width != w || bmd.height != h) {
			bmd = new BitmapData(w, h, true, 0x00ffffff);
		}
		bmd.draw(src, null, null, null, null, true);
		return bmd;
	}
	
	public function cloneDO(source: * ): DisplayObject {
		var obj : Object;
		
		if (source) {
			switch (true) {
				case source is Bitmap	: //Clone a Bitmap	: reuse BitmapData
					obj = new Bitmap((source as Bitmap).bitmapData, 'auto', true); break;
				case source is String	: //Clone a ClassName : find the class first - no break !	
					source = getDefinitionByName(source) as Class;
				case source is Class	: //Clone a Class : just new
					//if (getQualifiedClassName(source) == 'flash.display::MovieClip') showError('cloneDO', 'className', source);
					obj = new (source as Class)();
					break;
				default	: obj = new source.constructor();
			}
		} else {
			//showError('cloneDO', 'source', source);
		}
		
		return obj as DisplayObject;
	}
	
	public function tint(pDO : Object, color: int, amount: Number = 1): void {
		var cdo : DisplayObject = pDO as DisplayObject;
		
		if (cdo) {
			var ct	: ColorTransform = new ColorTransform();
			ct.color			= color;
			ct.redOffset		= amount * ct.redOffset;
			ct.greenOffset		= amount * ct.greenOffset;
			ct.blueOffset		= amount * ct.blueOffset;
			
			ct.redMultiplier	= 1 - amount;
			ct.greenMultiplier	= 1 - amount;
			ct.blueMultiplier	= 1 - amount;
			
			(cdo as DisplayObject).transform.colorTransform = ct;
		} else {
			//showError('tint', 'pDO', pDO);
		}
	}
	
	public function brightness(pDO : Object, amount: Number = 1): void {
		var cdo : DisplayObject = pDO as DisplayObject;
		
		if (!cdo) {
			var ct	: ColorTransform = new ColorTransform();
			var val	: int = amount * 255;
			
			ct.redOffset	= val;
			ct.greenOffset	= val;
			ct.blueOffset	= val;
			cdo.transform.colorTransform = ct;
		} else {
			//showError('brightness', 'pDO', pDO);
		}
	}
	
	public function formatTextField(textfield: TextField, formatObj: Object, useAsDefault:Boolean = true): TextField { /* small secrets : useDefaults : true */
		if (textfield) {
			var tff		: TextFormat	= textfield.getTextFormat();
			if (formatObj) {
				if (formatObj.useDefaults) {
					formatObj['autoSize']			= TextFieldAutoSize.LEFT;
					formatObj['selectable']			= false;
					formatObj['mouseWheelEnabled']	= false;
					formatObj['mouseEnabled']		= false;
					formatObj['blendMode']			= BlendMode.LAYER;
					delete formatObj.useDefaults;
				}
				
				for (var prop : String in formatObj) {
					formatProps[prop] ? tff[prop] = formatObj[prop] : textfield[prop] = formatObj[prop];
				}
				textfield.setTextFormat(tff);
			}
			if (useAsDefault) textfield.defaultTextFormat = tff;
		} else {
			//showError('formatTextfield', 'textfield', textfield, 'formatObj', formatObj);
		}
		
		return textfield;
	}
		
		
/***************************
 *		EXTERNAL LINKED 
 ***************************/
	
	public var lib : Object; //more advanced display features
	
	public function getIndex(pChild : Object): int {
		
	}
	public function setIndex(pChild : Object, idx : int): void {
		
	}
	public function removeChildrenByNames(parent: Object, names: * , returnChildren: Boolean = false): Array {
		
	}
	public function removeChildrenExceptNames(parent: Object, exceptNames: * , returnRemovedDO : Boolean = false): Array {
		
	}
	public function addChildrenByNames(parent: Object, names: * ): void {
		
	}
	public function addChildren(parent: Object, children: Array, at: int = -1) : void {
		
	}
	public function getChildrenExceptNames(parent: Object, exceptNames: * ): Array {
		
	}
	public function getChildrenByNames(parent: Object, names: * ): Array {
		
	}
	public function getChildren(parent: Object, fromTop : Boolean = false, ignoreCount : int = 0): Array {
		
	}
	public function hzDistribute(spacing: int = 0, ...list):void {
		
	}
	public function getBound(pDO: Object):Rectangle {
		
	}
	public function getRect(pDO: DisplayObject): Rectangle {
		
	}
	public function dropshadow(pDO: Object, distance:Number = 4.0, angle:Number = 45, color:uint = 0, alpha:Number = 1.0, blurX:Number = 4.0, blurY:Number = 4.0, strength:Number = 1.0, quality:int = 1, inner:Boolean = false, knockout:Boolean = false, hideObject:Boolean = false):void {
		
	}
	public function blur(pDO: Object, blurX:Number = 4.0, blurY:Number = 4.0, quality:int = 1):void {
		
	}
	public function bevel(pDO: Object, distance:Number = 4.0, angle:Number = 45, highlightColor:uint = 0xFFFFFF, highlightAlpha:Number = 1.0, shadowColor:uint = 0x000000, shadowAlpha:Number = 1.0, blurX:Number = 4.0, blurY:Number = 4.0, strength:Number = 1, quality:int = 1, type:String = "inner", knockout:Boolean = false):void {
		
	}
	public function glow(pDO: Object, color:uint = 0xFF0000, alpha:Number = 1.0, blurX:Number = 6.0, blurY:Number = 6.0, strength:Number = 2, quality:int = 1, inner:Boolean = false, knockout:Boolean = false):void {
		
	}
	public function grayscale(pDO: Object, amount: Number = 1): void {
		
	}
	public function drawArc(pDO: Object, ox: int, oy: int, r: Number, stAngle: Number, edAngle: Number): DisplayObject {
		
	}
	public function scaleAround(pDO: Object, x: Number, y: Number, sx: Number, sy: Number, oMatrix: Matrix = null) : void {
		
	}
	public function rotateAround(pDO: Object, x: Number, y: Number, angle: Number, oMatrix: Matrix = null): void {
		
	}
	
	//KStateView
	//KGroup
	
	//KVideo
	//KWebcam
	//KView
	
}

class DebugWrapper {
	public function obj2String(obj: Object): String {
		
	}
	
	//FPS
	//Performance bencher
	//Logger
	//MonsterDebugger connect
}

class PerformanceTweak {
	//cache
	//pool
	//lazyIndex (array dirty mark)
}

class DisplayComponent {
	//AssetBasic
	//AssetReplacer
	
	//mask scroller
	//menu
	//radio button
	//scroller
	//tooltip
	//item grid
	//form
	//Search / filter
}



class SimpleMath {
	//pct2Val
	//val2pct
	//roundTo
	//clamp
	//copyMatrix
}


class AirWrapper {
	//do Air Specific functions
}



