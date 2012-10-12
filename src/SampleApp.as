package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	import vn.app.mini.mDisplay;
	import vn.app.MiniApp;
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
			
			//trace('done', api.load.progress);
			//trace(this, 'miniInit', xml);
		}
	}
}