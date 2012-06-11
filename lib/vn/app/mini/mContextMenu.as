package vn.app.mini {
	import flash.display.InteractiveObject;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
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
	public class mContextMenu {
		public static function add(pdo: Object, ...list): ContextMenu {
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
		
		public static function newItem(caption: String, onSelect: Function = null, separatorBefore: Boolean = false, enabled: Boolean = true, visible: Boolean = true): ContextMenuItem {
			var mi : ContextMenuItem = new ContextMenuItem(caption, separatorBefore, enabled, visible);
			if (onSelect != null) mi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onSelect);
			return mi;
		}
		
		public static function findItem(pdo: Object, captionHasWord: String): ContextMenuItem {
			var arr 	: Array	= (pdo as InteractiveObject).contextMenu.customItems;
			var l		: int	= arr.length;
			var mi		: ContextMenuItem;
			
			for (var i: int = 0; i < l; i++) {
				mi = arr[i];
				if (mi.caption.indexOf(captionHasWord) != -1)  return mi;
			}
			
			return null;
		}
		
		public static function findItems(pdo: Object, captionHasWord: String): Array {
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
		
		public static function activeItem(pdo: Object, item : *, char: String = '. : '): void {
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
}