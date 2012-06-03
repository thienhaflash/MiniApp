MiniApp is an AS3 library that attempts to minimize the efforts needed to create small apps

Most importantly, its component based architecture allow apps to built with some benifits :
	
	+	More flexible as no base class to extend from & no interface to implement, you can freely define the api for your app without worrying about any conflict or restrict.
	
	+	Portable / Reusable : Normally when switching from a self-running MiniApp to be a part of a bigger app (that could be built by other developer and did not use MiniApp library at all) we need to change quite a bit, MiniApp now let you do it transparently. Whether you let it play alone or load it into another app, the MiniApp works right out of the box.
	
	+	Flexible library / assets / module management : you can easily add / remove / replace any external library used as easy as modifing the config XML file, you also have the full control of the loading order of libraries / assets or module
	
	+	Lowering the file size to the bare minimum : each library will only be loaded once, right before the need then reuse, no deadth code gets bunched into each module.
	
	+	Adding / removing MiniApp from your app is very easy, only one class to include / exclude.