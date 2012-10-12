package {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	import vn.app.mini.mDisplay;
	import vn.app.MiniApp;
	import vn.app.ui.uiInput;
	import vn.app.ui.uiMenu;
	import vn.app.ui.uiRadio;
	import vn.app.ui.uiScroller;
	import vn.app.ui.uiTooltip;
	/**
	 * ...
	 * @author 
	 */
	public class SampleApp extends MovieClip {
		
		public var APP_NAME 	: String = "SampleApp";
		public var APP_VERSION	: String = "1.0.0";
		
		private var api : MiniApp;
		
		public function SampleApp() {
			api = new MiniApp(this, {
				config	:'config.xml',
				path	:'bin/',
				debug	: true,
				preventDefaultContextMenu: true
			}, APP_NAME, APP_VERSION);
		}
		
		private function onSelectMenuItem(e: Event):void {
			mDisplay.contextMenu.activeItem(this, e.currentTarget);
		}
		
		public function miniInit(xml: XML): void {
			mDisplay.contextMenu.add(this, 
				//'', 
				['Home', 'About us', 'Profile', 'Client List', 'Portfolio'], onSelectMenuItem,
				'', 'Copyright(c) 2012 by MiniApp'
			);
			
			var pdo : DisplayObject = new uiInput({parent: this, x : 100, y : 200}).setHint("...").skin;
			
			uiTooltip.init(null, this.stage, 0);
			uiTooltip.attach(pdo, "Hey, an Input item");
			
			new uiScroller( {parent: this, y: 70 } );
			
			new uiRadio(trace).reset({parent: this, y: 50}, "Option 1","Option 2","Option 3","Option 4", "Option 5");
			new uiMenu(trace).reset(this, ["File", "Open", "Close", "Save"], "Edit", "View", "Search", "Debug", "Project", "Insert", "Refactor", "Tools", "Macros", "Syntax", "Help");
			
			
			//trace('done', api.load.progress);
			//trace(this, 'miniInit', xml);
		}
		
		public function onStageResize(e: Event): void {
			trace(this, "onStageResize::", e);
		}
	}
}