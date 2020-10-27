package app.ui.view.menu.example;

class ExampleCategory {
	public final name:String;
	public final examples:Array<Example>;

	public function new(name:String, examples:Array<Example>) {
		this.name = name;
		this.examples = examples;
	}
}
