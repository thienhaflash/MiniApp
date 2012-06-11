package vn.app.mini 
{
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author thienhaflash (thienhaflash@gmail.com)
	 */
	public class mUtils {
		
		public function getURL(url: String, windows: String = '_blank'): void {
			navigateToURL(new URLRequest(url), windows);
		}
		
	}

}