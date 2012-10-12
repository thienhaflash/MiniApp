package vn.app.mini {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.IBitmapDrawable;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author thienhaflash (thienhaflash@gmail.com)
	 */
	public class mDisplay {
		
		internal static var formatProps : Object = { align: 1, blockIndent: 1, bold: 1, bullet: 1, color: 1, font: 1, indent: 1, italic: 1, italic: 1, kerning: 1, leading: 1, leftMargin: 1, letterSpacing: 1, rightMargin: 1, size: 1, tabStops: 1, target: 1, underline: 1, url: 1 };
		
		public static var stage		: Stage;
		public static var root		: DisplayObject;
		public static var flashvars	: Object;
		public static var isLocal	: Boolean;
		
		public static function initStage(pdo: DisplayObject): void {
			if (!pdo.stage) return; //|| !pdo.parent
			if (!stage) {
				stage		= pdo.stage;
				root		= stage.root;
				flashvars 	= root.loaderInfo.parameters;
				isLocal		= root.loaderInfo.url.indexOf('file://') != -1;
			}
		}
		
		public static function getFullName(pdo: DisplayObject): String {
			var arr : Array		= getFullHierachy(pdo);
			var l	: int		= arr.length;
			var s 	: String	= '';
			var name: String;
			
			while (--l > -1) {
				name = arr[l].name;
				s += (name && name.length ? name : arr[l]) + (l > 0 ? '.' : '');
			}
			
			return s;
		}
		
		public static function getFullHierachy(pdo : DisplayObject, includeMe: Boolean = true): Array {
			if (!pdo) return [];
			
			var arr : Array = includeMe ? [pdo] : [];
			var p 	: DisplayObjectContainer = pdo.parent;
			while (p) { arr.push(p);  p = p.parent }
			
			return arr;
		}
		
		public static function removeChildren(parent:Object, returnChildren:Boolean = false, fromTop:Boolean = false, ignoreCount:int = 0):Array {
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
				//trace('removeChildren', 'parent', pp);
			}
			
			return ch;
		}
		
		public static function removeDO(pChild: Object): DisplayObject {
			var cdo : DisplayObject = pChild as DisplayObject;
			
			if (cdo && pChild.parent) {
				cdo.parent.removeChild(cdo);
			} else {
				//trace('removeChildrenByNames', 'pChild', pChild);
			}
			
			return cdo;
		}
		
		public static function setMouse(pDO: * , pMouseEnabled: Boolean = false, pButtonMode: Boolean  = false, pMouseChildren: Boolean = false): void {
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
				//trace('setMouse', 'pDO', pDO);
			}
		}
		
		public static function hitTestMouse(pDO: DisplayObject, shapeFlag : Boolean): Boolean {
			var cdo : DisplayObject = pDO as DisplayObject;
			
			//if (!cdo) trace('hitTestMouse', 'pDO', pDO);
			return pDO && cdo.stage ? cdo.hitTestPoint(cdo.stage.mouseX, cdo.stage.mouseY, shapeFlag) : false;
		}
		
		public static function newMask(pDO : Object, w: int, h: int): Shape {
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
				//trace('newMask', 'pDO', pDO);
			}
			return shp;
		}
		
		public static function newTextField(parent: Object = null, isInput: Boolean = false, w: int = 150, h: int = 25, x: int = 0, y: int = 0): TextField {
			var tf : TextField = formatTextField(new TextField(), { type		: isInput ? TextFieldType.INPUT : TextFieldType.DYNAMIC
																	, multiline	: false
																	, x			: x
																	, y			: y
																	, width		: w
																	, height	: h
																	, size		: 16 } );
			var pp : DisplayObjectContainer = parent as DisplayObjectContainer;
			if (pp) pp.addChild(tf);
			//pp ? pp.addChild(tf) : trace('newTextField', 'parent', parent);
			return tf;
		}
		
		public static function newBitmapData(w: int, h: int, src: IBitmapDrawable, bmd: BitmapData = null): BitmapData {
			if (!bmd || bmd.width != w || bmd.height != h) {
				bmd = new BitmapData(w, h, true, 0x00ffffff);
			}
			bmd.draw(src, null, null, null, null, true);
			return bmd;
		}
		
		public static function cloneDO(source: * ): DisplayObject {
			var obj : Object;
			
			if (source) {
				switch (true) {
					case source is Bitmap	: //Clone a Bitmap	: reuse BitmapData
						obj = new Bitmap((source as Bitmap).bitmapData, 'auto', true); break;
					case source is String	: //Clone a ClassName : find the class first - no break !	
						source = getDefinitionByName(source) as Class;
					case source is Class	: //Clone a Class : just new
						//if (getQualifiedClassName(source) == 'flash.display::MovieClip') trace('cloneDO', 'className', source);
						obj = new (source as Class)();
						break;
					default	: obj = new source.constructor();
				}
			} else {
				//trace('cloneDO', 'source', source);
			}
			
			return obj as DisplayObject;
		}
		
		public static function tint(pDO : Object, color: int, amount: Number = 1): void {
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
				//trace('tint', 'pDO', pDO);
			}
		}
		
		public static function brightness(pDO : Object, amount: Number = 1): void {
			var cdo : DisplayObject = pDO as DisplayObject;
			
			if (!cdo) {
				var ct	: ColorTransform = new ColorTransform();
				var val	: int = amount * 255;
				
				ct.redOffset	= val;
				ct.greenOffset	= val;
				ct.blueOffset	= val;
				cdo.transform.colorTransform = ct;
			} else {
				//trace('brightness', 'pDO', pDO);
			}
		}
		
		public static function formatTextField(textfield: *, formatObj: Object, useAsDefault:Boolean = true): TextField { /* small secrets : useDefaults : true */
			var i	: int;
			var arr : Array = textfield is TextField ? [textfield] : textfield;
			
			if (arr) {
				var tff		: TextFormat	= textfield.getTextFormat();
				if (formatObj) {
					if (formatObj.useDefaults) {
						formatObj['autoSize']			= TextFieldAutoSize.LEFT;
						formatObj['selectable']			= false;
						formatObj['mouseWheelEnabled']	= false;
						formatObj['mouseEnabled']		= false;
						formatObj['blendMode']			= BlendMode.LAYER;
						formatObj['rightMargin']		= 1; // prenvet text cuts off
						delete formatObj.useDefaults;
					}
					
					for (var prop : String in formatObj) {
						if (formatProps[prop]) {
							tff[prop] = formatObj[prop];
						} else {
							for (i = 0; i < arr.length; i++) {
								(arr[i] as TextField)[prop] = formatObj[prop];
							}
						}
					}
					
					for (i = 0; i < arr.length; i++) {
						(arr[i] as TextField).setTextFormat(tff);
					}
				}
				
				if (useAsDefault) {
					for (i = 0; i < arr.length; i++) {
						(arr[i] as TextField).defaultTextFormat = tff;
					}
				}
			} else {
				//trace('formatTextfield', 'textfield', textfield, 'formatObj', formatObj);
			}
			
			return textfield;
		}
		
		public static function dropshadow(pDO: Object, distance:Number = 4.0, angle:Number = 45, color:uint = 0, alpha:Number = 1.0, blurX:Number = 4.0, blurY:Number = 4.0, strength:Number = 1.0, quality:int = 1, inner:Boolean = false, knockout:Boolean = false, hideObject:Boolean = false):void {
			var cdo : DisplayObject = pDO as DisplayObject;
			
			cdo ? cdo.filters = [new DropShadowFilter(distance, angle, color, alpha, blurX, blurY, strength, quality, inner, knockout, hideObject)]
				: trace('dropshadow', 'pDO', pDO);
		}
		
		public static function blur(pDO: Object, blurX:Number = 4.0, blurY:Number = 4.0, quality:int = 1):void {
			var cdo : DisplayObject = pDO as DisplayObject;
			
			cdo ? cdo.filters = (blurX == 0 && blurY == 0) ? [] : [new BlurFilter(blurX, blurY, quality)]
				: trace('blur', 'pDO', pDO);
		}
		
		public static function bevel(pDO: Object, distance:Number = 4.0, angle:Number = 45, highlightColor:uint = 0xFFFFFF, highlightAlpha:Number = 1.0, shadowColor:uint = 0x000000, shadowAlpha:Number = 1.0, blurX:Number = 4.0, blurY:Number = 4.0, strength:Number = 1, quality:int = 1, type:String = "inner", knockout:Boolean = false):void {
			var cdo : DisplayObject = pDO as DisplayObject;
			
			cdo ? cdo.filters = [new BevelFilter(distance, angle, highlightColor, highlightAlpha, shadowColor, shadowAlpha, blurX, blurY, strength, quality, type, knockout)]
				: trace('bevel', 'pDO', pDO);
		}
		
		public static function glow(pDO: Object, color:uint = 0xFF0000, alpha:Number = 1.0, blurX:Number = 6.0, blurY:Number = 6.0, strength:Number = 2, quality:int = 1, inner:Boolean = false, knockout:Boolean = false):void {
			var cdo : DisplayObject = pDO as DisplayObject;
			
			cdo ? cdo.filters = [new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout)]
				: trace('glow', 'pDO', pDO);
		}
		
		public static function grayscale(pDO: Object, amount: Number = 1): void {
			var cdo : DisplayObject = pDO as DisplayObject;
			
			if (cdo) {
				if (amount > 0 ) {
					var r : Number = 0.3086;
					var g : Number = 0.6094;
					var b : Number = 0.0820;
					var a : Number = amount;
					var d : Number = 1 - amount;
					
					(cdo as DisplayObject).filters = [
						new ColorMatrixFilter([	a * r + d	, a * g		, a * b		, 0, 0,
												a * r		, a * g + d	, a * b		, 0, 0,
												a * r		, a * g		, a * b + d	, 0, 0,
												0, 0, 0, 1, 0])
					]
				} else {
					(cdo as DisplayObject).filters = [];
				}
			} else {
				trace('grayscale', 'pDO', pDO);
			}
		}
		
		public static function drawRect(pDO: Object, pcolor: int = 0xEAEAEA, pwidth: int = 100, pheight: int = 100, palpha: Number = 1) : DisplayObject {
			var g	: Graphics =	(pDO is Sprite) ? (pDO as Sprite).graphics
									:	(pDO is Shape) ? (pDO as Shape).graphics : null;
			
			if (g) {
				g.beginFill(pcolor, palpha);
				g.drawRect(0, 0, pwidth, pheight);
				g.endFill();
			} else {
				//trace('drawRect', 'pDO', pDO);
			}
			return pDO as DisplayObject;
		}
		
		public static function scaleAround(pDO: Object, x: Number, y: Number, sx: Number, sy: Number, oMatrix: Matrix = null) : void {
			var cdo : DisplayObject = pDO as DisplayObject;
			var m	: Matrix;
			/*
				Maple 14 syntax : evalm(`&*`(`&*`(Matrix(3, 3, {(1, 1) = 1, (1, 2) = 0, (1, 3) = x0, (2, 1) = 0, (2, 2) = 1, (2, 3) = y0, (3, 1) = 0, (3, 2) = 0, (3, 3) = 1}), Matrix(3, 3, {(1, 1) = sx, (1, 2) = 0, (1, 3) = 0, (2, 1) = 0, (2, 2) = sy, (2, 3) = 0, (3, 1) = 0, (3, 2) = 0, (3, 3) = 1})), Matrix(3, 3, {(1, 1) = 1, (1, 2) = 0, (1, 3) = -x0, (2, 1) = 0, (2, 2) = 1, (2, 3) = -y0, (3, 1) = 0, (3, 2) = 0, (3, 3) = 1})))
				
				|1	0	x|		|sx		0		0|		|1	0	-x|		|sx		0		x*(1-sx)|
				|0	1	y|	*	|1		sy		0|	*	|0	1	-y|	 =	|0		sy		y*(1-sy)|
				|0	0	1|      |0		0		1|      |0	0	1 |     |0		0		1		|
				
			*/
			if (cdo) {
				if (oMatrix) {
					m = oMatrix.clone();
					m.concat(new Matrix(sx, 0, 0, sy, x * (1 - sx), y * (1 - sy)));
				} else {
					m = new Matrix(sx, 0, 0, sy, x * (1 - sx), y * (1 - sy));
				}
				(cdo as DisplayObject).transform.matrix = m;
			} else {
				trace('scaleAround', 'pDO', pDO);
			}
		}
		
		public static function rotateAround(pDO: Object, x: Number, y: Number, angle: Number, oMatrix: Matrix = null): void {
			angle *= Math.PI / 180;
			var cdo : DisplayObject = pDO as DisplayObject;
			var sin : Number = Math.sin(angle);
			var cos : Number = Math.cos(angle);
			var m	: Matrix;
			
			/*
				Maple 14 syntax : evalm(`&*`(`&*`(Matrix(3, 3, {(1, 1) = 1, (1, 2) = 0, (1, 3) = x0, (2, 1) = 0, (2, 2) = 1, (2, 3) = y0, (3, 1) = 0, (3, 2) = 0, (3, 3) = 1}), Matrix(3, 3, {(1, 1) = cos, (1, 2) = -sin, (1, 3) = 0, (2, 1) = sin, (2, 2) = cos, (2, 3) = 0, (3, 1) = 0, (3, 2) = 0, (3, 3) = 1})), Matrix(3, 3, {(1, 1) = 1, (1, 2) = 0, (1, 3) = -x0, (2, 1) = 0, (2, 2) = 1, (2, 3) = -y0, (3, 1) = 0, (3, 2) = 0, (3, 3) = 1})))
				
				|1	0	x|		|cos	-sin	0|		|1	0	-x|		|cos	-sin	-cos*x+sin*y+x	|
				|0	1	y|	*	|sin	cos		0|	*	|0	1	-y|	 =	|sin	cos		-sin*x-cos*y+y	|
				|0	0	1|      |0		0		1|      |0	0	1 |     |0		0		1				|
				
			*/
			
			if (cdo) {
				if (oMatrix) {
					m = oMatrix.clone();
					m.concat(new Matrix(cos, sin, -sin, cos, -cos * x + sin * y + x, -sin * x - cos * y + y));
				} else {
					m = new Matrix(cos, sin, -sin, cos, -cos * x + sin * y + x, -sin * x - cos * y + y);
				}
				(cdo as DisplayObject).transform.matrix = m;
			} else {
				trace('rotateAround', 'pDO', pDO);
			}
		}
		
		public static function get contextMenu(): mContextMenu {
			return mContextMenu.instance ||= new mContextMenu();
		}
		
		public static function get enterFrame(): mEnterFrame {
			return mEnterFrame.instance ||= new mEnterFrame();
		}
	}
}

import flash.display.InteractiveObject;
import flash.display.Shape;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.utils.Dictionary;
/**
 * 
 * @author thienhaflash (thienhaflash@gmail.com)
	
SAMPLE USAGE 	:
		
	1.	mContextMenu.add(pdo,	//one caption mapping to an onSelect handler
			'home',			onSelectHome,
			'about us',		onSelectAbout,
			'profile',		onSelectProfile,
			'portfolio',	onSelectPortfolio
		);
		
	2.	mContextMenu.add(pdo, //use '' in place of separators & skip the handlers for NON-clickable items
			'version 1.0',
			'copyright(c) 2012 by MiniApp',
			'',
			'home',			onSelectHome,
			'about us',		onSelectAbout,
			'profile',		onSelectProfile,
			'portfolio',	onSelectPortfolio
		);
		
	3.	mContextMenu.add(pdo, //use Object instead of the item list
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
		
	4.	mContextMenu.add(pdo, //use Array to group items that shares the same onSelect hander
			['version 1.0', 'copyright(c) 2012 by MiniApp', ''],
			['home', 'about us', 'profile', 'portfolio'], onSelectMenuItem
		);
		
		
	//TODO :	SUPPORT FOR ADVANCED OBJECT CONTEXT MENU
	5.	mContextMenu.add(pdo, //use advanced object have more powerful tweaks : rename / disable / enable / prepend / append / hide / show
			{	'rename' : [	
					0,			'Version 1.0 RC - r238',
					6,			'Video'
					'home',		'-> Home'
					'file', 	'Client Profile',
					'about',	'About our company'
				]
			}
		);
 */
class mContextMenu {
	
	public static var instance : mContextMenu;
	
	public function add(pdo: Object, ...list): ContextMenu {
		if (!(pdo is InteractiveObject)) return null;
		
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
					if (capsArr[j]) {
						cmiArr.push(newItem(capsArr[j], isFunc ? tmp : null, sep, isFunc));
						sep = false;
					} else {
						sep = true;
					}
				}
				if (isFunc) i++; //have onSelect cost 1 more element in list
			} else {//must be an Object (complex item)
				obj = item;
				for (var s : String in obj) {
					tmp = obj[s];
					isFunc = tmp is Function;
					if (isFunc) cmiArr.push(newItem(s, tmp, sep));
					sep = false;
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
	
	public function findItem(pdo: Object, captionHasWord: String): ContextMenuItem {
		var arr 	: Array	= (pdo as InteractiveObject).contextMenu.customItems;
		var l		: int	= arr.length;
		var mi		: ContextMenuItem;
		
		for (var i: int = 0; i < l; i++) {
			mi = arr[i];
			if (mi.caption.indexOf(captionHasWord) != -1)  return mi;
		}
		
		return null;
	}
	
	public function findItems(pdo: Object, captionHasWord: String): Array {
		var arr 	: Array	= (pdo as InteractiveObject).contextMenu.customItems;
		var l		: int	= arr.length;
		var mi		: ContextMenuItem;
		var arr2	: Array = [];
		
		for (var i: int = 0; i < l; i++) {
			mi = arr[i];
			if (mi.caption.indexOf(captionHasWord) != -1) {
				arr2.push(mi);
			}
		}
		
		return arr2;
	}
	
	public function activeItem(pdo: Object, item : *, char: String = '. : '): void {
		var cmi : ContextMenuItem = findItem(pdo, char);
		
		if (cmi) {//return last one
			cmi.enabled = true;
			cmi.caption = cmi.caption.split(char)[1];
		}
		
		//active this one
		if (item is String) item = findItem(pdo, item);
		if (item is ContextMenuItem) {
			item.enabled = false;
			item.caption = char + item.caption;
		}
	}
}

class mEnterFrame {
	public static var instance : mEnterFrame;
	
	private var heart 		: Shape;
	private var nextList	: Dictionary;
	private var eachList	: Dictionary;
	private var eachCnt		: int;
	
	public function mEnterFrame() {
		heart		= new Shape();
		nextList	= new Dictionary();
		eachList	= new Dictionary();
		eachCnt		= 0;
	}
	
	public function onNext(f: Function, params : Array = null): void {
		heart.addEventListener(Event.ENTER_FRAME, _onNextFrame);
		nextList[f] = params;
	}
	
	public function onEach(f: Function, params: Array = null): void {
		if (eachCnt == 0) heart.addEventListener(Event.ENTER_FRAME, _onEachFrame);
		eachList[f] = params;
	}
	
	public function remove_onEach(f: Function): void {
		delete eachList[f]
	}
	
	public function remove_onNext(f:Function): void {
		delete nextList[f];
	}
	
	private function _onEachFrame(e:Event):void {
		eachCnt = 0;
		for (var f: * in eachList) {
			eachCnt++;
			(f as Function).apply(null, eachList[f]);
		}
		if (eachCnt == 0) heart.removeEventListener(Event.ENTER_FRAME, _onEachFrame); //remove event if there are no items listened
	}
	
	private function _onNextFrame(e: Event): void {
		heart.removeEventListener(Event.ENTER_FRAME, _onNextFrame);
		for (var f: * in nextList) {
			(f as Function).apply(null, nextList[f]);
			delete nextList[f];
		}
	}
}