package app.ui.core;

import app.ui.core.layout.Axis;
import app.ui.core.layout.FlexLayout;
import app.ui.core.layout.Layout;

using common.ArrayTools;
using common.FloatTools;
using common.IntTools;

class Element {
	public var parent(default, null):Element = null;

	public final children:Array<Element> = [];

	public var layout(default, set):Layout;

	function set_layout(layout:Layout):Layout {
		this.layout = layout;
		layout.setTarget(this);
		return layout;
	}

	public final boundary:Rect = new Rect(0, 0, 0, 0);
	public final style:Style = new Style();

	public var childIndex(default, null):String;
	public var path(get, never):String;

	function get_path():String {
		var dirs = [];
		var s = this;
		while (s.parent != null) {
			dirs.push(s.childIndex);
			s = s.parent;
		}
		dirs.reverse();
		return dirs.join("");
	}

	static var idCount:Int = 0;

	public final id:Int = ++idCount;

	public function new() {
		layout = new FlexLayout(X);
	}

	public function addChild(child:Element):Void {
		if (child.parent != null)
			throw "added twice";
		children.push(child);
		child.parent = this;
		child.childIndex = String.fromCharCode(32 + children.length - 1);
	}

	public function removeChild(child:Element):Void {
		if (child.parent != this)
			throw "cannot remove";
		children.remove(child);
		child.parent = null;
		child.childIndex = null;

		for (i in 0...children.length) {
			children[i].childIndex = String.fromCharCode(32 + i);
		}
	}

	public function getBoundarySize(axis:Axis, parentSize:Float, includeMargin:Bool):Float {
		var size = calcBoundarySize(axis, style.size.along(axis), parentSize, () -> layout.getContentSize(axis));
		if (includeMargin)
			size += style.margin.calcAssigningZeroToAutoAlong(axis, parentSize);
		return size;
	}

	public function getMinBoundarySize(axis:Axis, parentSize:Float, includeMargin:Bool):Float {
		var size = calcBoundarySize(axis, style.minSize.along(axis), parentSize, () -> layout.getMinContentSize(axis));
		if (includeMargin)
			size += style.margin.calcAssigningZeroToAutoAlong(axis, parentSize);
		return size;
	}

	public function getMaxBoundarySize(axis:Axis, parentSize:Float, includeMargin:Bool):Float {
		var size = calcBoundarySize(axis, style.maxSize.along(axis), parentSize, () -> layout.getMaxContentSize(axis));
		if (includeMargin)
			size += style.margin.calcAssigningZeroToAutoAlong(axis, parentSize);
		return size;
	}

	public function contentStart(axis:Axis):Float {
		return boundary.start(axis) + style.padding.start(axis).calc(boundary.size(axis));
	}

	public function contentEnd(axis:Axis):Float {
		return boundary.end(axis) - style.padding.end(axis).calc(boundary.size(axis));
	}

	public function contentSize(axis:Axis):Float {
		return boundary.size(axis) - style.padding.calcAlong(axis, boundary.size(axis));
	}

	extern inline function calcBoundarySize(axis:Axis, len:LengthOrAuto, parentSize:Float, calcAutoContentSize:Void->Float):Float {
		return if (len == Auto) {
			calcAutoContentSize() + style.padding.calcAlong(axis, parentSize);
		} else {
			var res = len.toLength(Zero).calc(parentSize);
			switch style.boxSizing {
				case Content:
					res + style.padding.calcAlong(axis, parentSize);
				case Boundary:
					res;
			}
		}
	}
}
