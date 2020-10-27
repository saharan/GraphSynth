package app.ui.core;

using common.ArrayTools;
using common.FloatTools;
using common.IntTools;

class UI {
	public final root:Element;
	public var width:Float;
	public var height:Float;

	public function new() {
		root = new Element();
		width = 100;
		height = 100;
	}

	public function layout():Void {
		var margin = root.style.margin;
		var ml = margin.left.toLength(Zero).calc(width);
		var mr = margin.right.toLength(Zero).calc(width);
		var mt = margin.top.toLength(Zero).calc(height);
		var mb = margin.bottom.toLength(Zero).calc(height);
		root.boundary.set(ml, mt, width - (ml + mr), height - (mt - mb));
		root.layout.layout();
	}

	public function hitTest(x:Float, y:Float):Array<Element> {
		var res = [];
		hitTestRecursive(root, x, y, res);
		return res;
	}

	function hitTestRecursive(e:Element, x:Float, y:Float, res:Array<Element>):Void {
		if (e.style.noHit)
			return;
		var n = e.children.length;
		for (i in 0...n) {
			var c = e.children[n - 1 - i];
			hitTestRecursive(c, x, y, res);
		}
		var boundary = e.boundary;
		if (e.style.hitArea.test(boundary.w, boundary.h, x - boundary.x, y - boundary.y)) {
			res.push(e);
		}
	}
}
