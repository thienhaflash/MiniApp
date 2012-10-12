package vn.app.ui {

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	
	//TODO : test 
	
	/**
	 * uiState provide a stated container that only contains only one child at each state
	 * 
	 * @author thienhaflash
	 * @version 0.1.0
	 * @update 26.Feb.2012
	 * @features 
	 * 		Automatically get the children of a container use as states (for timeline containers)
	 * 		Support optional custom transitions when changing states
	 * 		Support callbacks on each child to be called when transition start / end (onStartIn, onStartOut, onEndIn, onEndOut)
	 * 		Automatically disable interaction and block state changes when doing transition
	 * 		Fully trace for invalid operations for easy tracking down
	 * 
	 * @usage
	 * 		//provided that mcMain contains 3 children mc1, mc2, mc3
	 * 		var mainView : uiState = new uiState(mcMain); //by default defaultState is '' which mean contains no child
	 * 		
	 * 		//to set state to mc1 (will only show mc1 on screen)
	 * 		mainView.state = 'mc1';
	 * 
	 * 		//to hide all children (empty state)
	 * 		mainView.state = '';
	 * 
	 */
		
	public class uiState {
		public var tweenFunc		: Function; /* function (objIn: DisplayObject, objOut : DisplayObject, onComplete: Function, config: Object=null): void */
		
		private var _state 			: String;
		private var _isTweening		: Boolean;
		private var _map			: Object;
		
		private var _holder			: Sprite;
		private var _lastContent	: DisplayObject;
		private var _content		: DisplayObject;
		
		/**
		 * uiState provide a stated container that only contains one child at each state
		 * @param	target the container
		 * @param	defaultState = '' the first state to set transition to, default to '' (no child content)
		 * @param	states object mapping STATE_NAMES to CHILDREN MOVIECLIPS's NAMES {stateA : mc1, stateB : mc2}, by default state name == movieclip name
		 */
		public function uiState(target: Sprite, defaultState: String = '', tweenFunc: Function = null, states: Object = null) {
			_holder	= target;
			
			if (states) {//map states to DisplayObject
				_map	= { }
				var pdo : DisplayObject;
				for (var s :String in states) {
					pdo 	= uiStateUtils.getChildByName(target, states[s]);
					pdo ? _map[s] = pdo : trace(this, 'invalid State declared <' + s + '>, child named <'+states[s]+'> not found on ', target);
				}
			} else {
				_map = uiStateUtils.getChildrenMap(_holder);
			}
			
			uiStateUtils.removeChildren(_holder);
			state			= defaultState;
			this.tweenFunc	= tweenFunc; //skip using tween function for the first time
		}
		
		public function get state():String { return _state; }
		public function get content():DisplayObject { return _content; }
		public function get holder():Sprite { return _holder; }
		
		public function set state(value:String):void {
			if (_isTweening) {//TODO : enable abrupt state changes ?
				trace(this, 'state transitions are not yet ready - can not change state');
				return;
			} else if (value == '' || _map[value]) {//valid states
				//trace(value);
				_state = value;
				_tween(_map[_state], _content);
			} else {
				trace(this, 'invalid state to make transition to : ', state);
			}
		}
		
		public function getStateContent(stateName: String): DisplayObject {
			return _map[stateName];
		}
		
	/*********************
	 * 		TRANSITION
	 ********************/
		
		private function _tween(inTarget: DisplayObject, outTarget: DisplayObject) : void {
			if (inTarget) _holder.addChild(inTarget);
			_lastContent	= outTarget;
			_content		= inTarget;
			_isTweening		= true;
			_holder.mouseChildren = false; //disable interaction
			
			//allow callbacks
			if (inTarget && inTarget.hasOwnProperty('onStartIn')) inTarget['onStartIn']();
			if (outTarget && outTarget.hasOwnProperty('onStartOut')) outTarget['onStartOut']();
			
			//_tweenFunc
			if (tweenFunc != null) {
				tweenFunc(inTarget, outTarget, _onTweenComplete);
			} else {
				if (inTarget) inTarget.visible = true;
				if (outTarget) outTarget.visible = false;
				_onTweenComplete();
			}
		}
		
		private function _onTweenComplete():void {
			//allow callbacks
			if (_content && _content.hasOwnProperty('onEndIn')) _content['onEndIn']();
			if (_lastContent && _lastContent.hasOwnProperty('onEndOut')) _lastContent['onEndOut']();
			
			uiStateUtils.removeMe(_lastContent);
			_holder.mouseChildren = true; //enable interaction
			_isTweening = false;
		}
	}
}

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

class uiStateUtils {
	public static function removeChildren(targetDOC : Object): void {
		var doc : DisplayObjectContainer = targetDOC as DisplayObjectContainer;
		if (doc) {
			while (doc.numChildren > 0) {
				doc.removeChildAt(0);//FIXME : there may sometimes security error on this : catch later
			}
		} else {
			trace('removeChildren fail on ', targetDOC);
		}
	}
	
	public static function removeMe(pdo : DisplayObject): void {
		if (pdo && pdo.parent) pdo.parent.removeChild(pdo);
	}
	
	public static function getChildByName(targetDOC : Object, name:String): DisplayObject {
		return targetDOC.hasOwnProperty(name) ? targetDOC[name] : (targetDOC as DisplayObjectContainer).getChildByName(name);
	}
	
	public static function getChildrenMap(sprt: Sprite): Object {
		var obj :Object = { };
		var child : DisplayObject;
		
		for (var i: int = 0; i < sprt.numChildren; i++) {
			child = sprt.getChildAt(i);
			obj[child.name] = child;
			//trace(i, child.name, child);
		}
		return obj;
	}
}