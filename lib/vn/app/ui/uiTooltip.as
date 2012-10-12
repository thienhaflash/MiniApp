package vn.app.ui {
	
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class uiTooltip {
		
		public function uiTooltip() {
			throw new Error('Tooltip is a static class and can not be instantiated');
		}
		
		private static var _hookSkin		: Function; //hook to control
		private static var _hookSkinOptions	: Object;
		private static var _hookUpdateMap	: Dictionary = new Dictionary(true);
		
		private static var _skin			: MovieClip;
		private static var _currentDO		: InteractiveObject;
		private static var _showTipTimer	: Timer; /* use to count idle time */
		private static var _isMouseOut 		: Boolean; /* use to refine mouseOut check */
		
		private static var _stageRef	: Stage;
		private static var _showDelay	: Number; /* delay time to show tooltip */
		private static var _hideDelay	: Number; /* auto hide after specified time, 0 = don't auto hide */
		private static var _tipDict		: Dictionary;
		
		//TODO : refactor default skin, support configurable for tip position (avoidStage, avoidObject, followMouse ...)
		
		public static function init(skin :MovieClip, stage: Stage, showDelay: Number = 2, hideDelay: Number = 0):void {
			_skin		= skin || getDefaultSkin();
			_stageRef	= stage;
			_showDelay	= showDelay;
			_hideDelay	= hideDelay;
			
			if (_skin.parent) _skin.parent.removeChild(_skin);
			_skin.mouseEnabled	= false;
			_skin.mouseChildren = false;
			
			_tipDict			= new Dictionary(true);
			_showTipTimer		= new Timer(100, _showDelay * 10); //update every 100 ms : might be enough accuracy
			_showTipTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _onTimerComplete);
			//_showTipTimer.addEventListener(TimerEvent.TIMER, trace);
			stage.addEventListener(Event.MOUSE_LEAVE, _onMouseOutOrLeave);
		}
		
		public static function getDefaultSkin(): MovieClip {
			var mc		: MovieClip = new MovieClip();
			var mcBg	: Shape		= new Shape();
			mcBg.name = "bg";
			
			var g : Graphics = mcBg.graphics;
			g.beginFill(0xffff55, 0.8);
			g.drawRect(0, 0, 100, 50);
			g.endFill();
			
			mc.addChild(mcBg);
			
			var tf : TextField = new TextField();
			tf.selectable = false;
			mc.addChild(tf);
			tf.name = "txt";
			
			mc.txt = tf;
			mc.bg  = mcBg;
			
			mc.mouseChildren	= false;
			mc.mouseEnabled 	= false;
			return mc;
		}
		
	/**********************
	 * 	INTERNAL HANDLERS
	 **********************/
		
		private static function _onMouseOutOrLeave(e:Event):void {
			_isMouseOut = true;
			
			//trace('out :: ', e.target.name, e.currentTarget.name);
			/*	Don't stop the Timer here as for a special case :			
				When we add tooltip for a parent of two children or more and keep
				moving mouse between them, the tooltip won't show as the Timer being
				reset overy time.
				Of course if this is the only case, we don't really need to care, but there
				might be animation in children clips that keeps sending MouseOver / MouseOut
				events to its parent as its shape is changing over time.
				So, don't stop the Timer here, once it complete and there are no _currentDO 
				(mouse is really out) then the Timer will stop itself automatically.
			*/
			
			//_showTipTimer.stop();
		}
		
		private static function _onOverIDO(e:MouseEvent):void {
			_isMouseOut	= false;
			if (_currentDO != e.currentTarget) hideTip(); //force hide last tooltip !
			
			//trace('over :: ', e.target.name, e.currentTarget.name);
			
			if (_tipDict[e.target]) {//children has Tip, too : use .target instead
				_currentDO = e.target as InteractiveObject;
			} else {//children don't have tip, use .currentTarget
				_currentDO	= e.currentTarget as InteractiveObject;
			}
			_currentDO.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOutOrLeave);
			
			if (_showDelay == 0) {
				showTip(_tipDict[_currentDO]);
			} else {
				if (!_showTipTimer.running) {//moving around in the same tooltip target ? should not reset the timer
					_showTipTimer.reset();
					_showTipTimer.start();
				}
			}
		}
		
		private static function _onTimerComplete(e:TimerEvent):void {
			_showTipTimer.reset();
			_showTipTimer.stop();
			showTip(_tipDict[_currentDO]);
		}
		
		private static function _updateTip(e:Event):void {
			var func	: Function	= _hookUpdateMap[_currentDO] || nearSideUpdateTip;
			var obj 	: Object	= func(_currentDO, _skin);
			
			if (obj) {//after hook :
				if (e == null) {
					_skin.x = obj.tx;
					_skin.y = obj.ty;
				} else {
					updateDelta(obj.tx, obj.ty);
				}
			}
			
			if (_skin.alpha < 0.99) {
				_skin.alpha += (1 - _skin.alpha) / 2;
			} else {
				_skin.alpha = 1;
			}
			
			if (_isMouseOut && _currentDO) {
				hideTip();
			}
		}
		
	/*******************
	 * 	FOUR AREA HOOKS
	 ******************/	
		
		public static function nearSideUpdateTip(targetDO : DisplayObject, tooltipSkin: DisplayObject): Object {
			if (!targetDO) return null;
			
			var rect	: Rectangle = targetDO.getRect(_stageRef);
			var mx	: int = _stageRef.mouseX;
			var my	: int = _stageRef.mouseY;
			var rb	: int = rect.x + rect.width;
			var bb	: int = rect.y + rect.height;
			
			var arr : Array = [	{ position : "left",	value		: mx - rect.x }
							,	{ position : "right",	value		: rb - mx }
							,	{ position : "top",		value		: my - rect.y }
							,	{ position : "bottom",	value		: bb - my} ];
			
			arr.sortOn('value', Array.NUMERIC);
			
			
			var skinW	: int = tooltipSkin.width;
			var skinH	: int = tooltipSkin.height;
			var stageH	: int = _stageRef.stageHeight;
			var stageW	: int = _stageRef.stageWidth;
			
			var obj : Object;
			var tx	: int;
			var ty	: int;
			
			//TODO : OPTIMIZE !
			
			forloop : for (var i: int = 0; i < 4; i++) {
				obj	= arr[i];
				
				switch (obj.position) {
					case 'left'		: 
						if (skinW < rect.x) {//check if left is valid
							tx = rect.x - skinW;
							ty = Math.min(my, stageH - skinH);
							break forloop;
						}
						break;
					case 'right'	:
						if (stageW > rb + skinW) {//check if right is valid
							tx = rb;
							ty = Math.min(my, stageH - skinH);
							break forloop;
						}
						break;
					case 'top'		:
						if (rect.y > skinH) {//check if top is valid
							ty = rect.y - skinH;
							tx = Math.min(stageW - skinW, mx);
							break forloop;
						}
						break;
					case 'bottom'	:
						if (stageH > bb + skinH) {//check if bottom is valid
							ty = bb;
							tx = Math.min(stageW - skinW, mx);
							break forloop;
						}
						break;
				}
			}
			
			return { tx: tx, ty: ty };
		}
		
	/*******************
	 * 	INTERNAL HOOKS
	 ******************/
		
		private static function _defaultHookSkin(message: String): void {
			_skin.txt.autoSize	= TextFieldAutoSize.LEFT;
			_skin.txt.text		= message;
			_skin.bg.width		= _skin.txt.width	+ 2 * _skin.txt.x;
			_skin.bg.height		= _skin.txt.height	+ 2 * _skin.txt.y;
			
			_skin.txt.blendMode = BlendMode.LAYER;
		}
				
		private static function updateDelta(tx: Number, ty: Number): void {
			var dx : Number = (tx - _skin.x) / 2;
			var dy : Number = (ty - _skin.y) / 2;
			
			if (dx < 0.1) {
				_skin.x += dx;
			} else {
				_skin.x	= Math.round(_skin.x + dx);
			}
			
			if (dy < 0.1) {
				_skin.y += dy;
			}else {
				_skin.y	 = Math.round(_skin.y + dy);
			}
		}
		
	/*******************
	 * 	PUBLIC API
	 ******************/
		
		public static function showTip(message: String): void {
			if (_hookSkin == null) {
				_defaultHookSkin(message); //don't need params for built in hooks
			} else {
				_hookSkin(_skin, message, _currentDO, _hookSkinOptions);
			}
			
			_stageRef.addChild(_skin);
			
			//TODO : add a hook for showTip
			var dx	: Number = Math.abs(_stageRef.mouseX - _skin.x);
			var dy	: Number = Math.abs(_stageRef.mouseY - _skin.y);
			var d	: Number = dx * dx + dy * dy;
			if (d > 10000) { //if it's too far : move it nearly before show
				d	= 20;
				dx	= (_stageRef.mouseX > _stageRef.stageWidth / 2) ? -d : d;
				dy	= (_stageRef.mouseY > _stageRef.stageHeight / 2) ? -d : d;
				
				_skin.x		= Math.min(_stageRef.stageWidth-_skin.width, _stageRef.mouseX + dx);
				_skin.y		= Math.min(_stageRef.stageHeight-_skin.height, _stageRef.mouseY + dy);
			}
			_skin.addEventListener(Event.ENTER_FRAME, _updateTip);
			_updateTip(null);
		}
		
		public static function hideTip(): void {
			_skin.alpha = 0;
			_skin.txt.text = '';
			_skin.removeEventListener(Event.ENTER_FRAME, _updateTip);
			
			_showTipTimer.stop();
			if (_currentDO) {
				_currentDO.addEventListener(MouseEvent.MOUSE_OUT, _onMouseOutOrLeave);
				_currentDO = null;
			}
			
			if (_skin.parent) _stageRef.removeChild(_skin);
			_skin.removeEventListener(Event.ENTER_FRAME, _updateTip);
		}
		
		public static function attach(target:DisplayObject, message:String, hookUpdateFunc: Function = null):void {
			if (!_tipDict) return; //not yet init, or used in modules
			
			var ido : InteractiveObject = target as InteractiveObject;
			//if (ido is Sprite) (ido as Sprite).buttonMode = true;
			
			if (!ido) return;
			
			_tipDict[ido]		= message;
			_hookUpdateMap[ido] = hookUpdateFunc;
			
			ido.addEventListener(MouseEvent.MOUSE_OVER, _onOverIDO);
		}
		
		public static function detach(target:DisplayObject):void {
			delete _tipDict[target];
			target.removeEventListener(MouseEvent.MOUSE_OVER, _onOverIDO);
		}
		
	}
}