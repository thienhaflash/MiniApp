package {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.ui.ContextMenuItem;
	import vn.app.mini.mContextMenu;
	import vn.app.MiniApp;
	/**
	 * ...
	 * @author 
	 */
	public class SampleApp extends MovieClip {
		
		private var api : MiniApp;
		
		public function SampleApp() {
			api = new MiniApp(this, { config: 'config.xml', path:'bin/' }, '[ SampleApp v.1.0 ]' );//, preventContextMenuDefault: true
			
			mContextMenu.add(this, 
				'',
				['Home', 'About us', 'Profile', 'Client List', 'Portfolio'], onSelectMenuItem,
				'','Copyright(c) 2012 by MiniApp'
			);
		}
		
		private function onSelectMenuItem(e: Event):void {
			mContextMenu.activeItem(this, e.currentTarget);
		}
		
		public function miniInit(xml: XML): void {
			//trace('done', api.load.progress);
			//trace(this, 'miniInit', xml);
		}
	}
}