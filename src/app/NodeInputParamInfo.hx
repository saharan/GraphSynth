package app;

class NodeInputParamInfo {
	public final name:String;
	public final defaultValue:Null<Float>;

	public function new(name:String, defaultValue:Null<Float>) {
		this.name = name;
		this.defaultValue = defaultValue;
	}
}
