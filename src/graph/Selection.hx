package graph;

class Selection {
	public var selected(default, set):Bool;
	public var count:Int;

	public function new() {
		selected = false;
		count = 0;
	}

	function set_selected(selected:Bool):Bool {
		if (this.selected != selected) {
			this.selected = selected;
			count = 0;
		}
		return selected;
	}
}
