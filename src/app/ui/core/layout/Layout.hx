package app.ui.core.layout;

class Layout {
	public var target(default, null):Element;

	var children:Array<Element>;
	var boundary:Rect;

	public function new() {
		target = null;
		children = null;
		boundary = null;
	}

	@:allow(app.ui.core.Element)
	function setTarget(target:Element):Void {
		if (this.target != null)
			throw "target set twice";
		this.target = target;
		children = target.children;
		boundary = target.boundary;
	}

	public function getContentSize(axis:Axis):Float {
		throw "implement this";
	}

	public function getMinContentSize(axis:Axis):Float {
		throw "implement this";
	}

	public function getMaxContentSize(axis:Axis):Float {
		throw "implement this";
	}

	function run():Void {
		throw "implement this";
	}

	public final function layout():Void {
		run();
		for (c in children) {
			c.layout.layout();
		}
	}
}
