package graph;

class NodeOption {
	public var name:NodeSetting->String;
	public final onSelected:Node->Void;
	public final closeAfterSelection:Bool;

	public function new(name:NodeSetting->String, onSelected:NodeSetting->Void, closeAfterSelection:Bool = false) {
		this.name = name;
		this.onSelected = n -> {
			onSelected(n.setting);
			n.notifyUpdate();
		};
		this.closeAfterSelection = closeAfterSelection;
	}
}
