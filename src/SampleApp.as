package {
	import flash.display.MovieClip;
	import vn.app.MiniApp;
	/**
	 * ...
	 * @author 
	 */
	public class SampleApp extends MovieClip {
		
		private var api : MiniApp;
		
		public function SampleApp() {
			api = new MiniApp(this);
		}
		
		public function miniInit(xml: XML): void {
			trace(this, 'miniInit', xml);
		}
		
		
	}
}