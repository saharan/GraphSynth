package app;

class Menu {
	public var title:String;
	public var items:Array<Array<String>> = [];

	public function new(title:String, items:Array<Array<String>>) {
		this.title = title;
		this.items = items;
	}
}
