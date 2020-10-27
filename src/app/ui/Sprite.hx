package app.ui;

import app.ui.core.layout.Layout;
import app.ui.core.Style;
import app.graphics.Graphics;
import app.ui.core.Element;

class Sprite implements PointerListener {
	public final element:Element;
	public var parent(default, null):Sprite = null;
	public final children:Array<Sprite> = [];
	public var stopEvent:Bool = false;
	public var pointerPolicy:PointerPolicy = Lock;

	public final pointerManager:PointerManager;

	@:allow(app.ui.Stage)
	public var stage(default, null):Stage = null;

	public var x(get, never):Float;
	public var y(get, never):Float;
	public var width(get, never):Float;
	public var height(get, never):Float;
	public var style(get, never):Style;
	public var pointers(get, never):Array<Pointer>;
	public var layout(get, set):Layout;

	public var cursor:CursorType = Auto;

	public var dead:Bool = false;

	public function new(element:Element = null) {
		this.element = element != null ? element : new Element();
		pointerManager = new PointerManager(() -> x, () -> y);
		pointerManager.addListener(this);
	}

	public function addChild(s:Sprite):Void {
		if (s.parent != null)
			throw "cannot add";
		children.push(s);
		s.parent = this;
		element.addChild(s.element);

		if (stage != null)
			setStage(s, stage);
	}

	/**
	 * do **not** call this in `update`
	 */
	public function removeChild(s:Sprite):Void {
		if (s.parent != this)
			throw "cannot remove";
		children.remove(s);
		s.parent = null;
		element.removeChild(s.element);

		if (stage != null)
			setStage(s, null);
	}

	function setStage(s:Sprite, stage:Stage):Void {
		s.stage = stage;
		for (c in s.children)
			setStage(c, stage);
	}

	public function onPointerEnter(p:Pointer):Void {
	}

	public function onPointerExit(p:Pointer):Void {
	}

	public function onPointerDown(p:Pointer, index:Int):Void {
	}

	public function onPointerUp(p:Pointer, index:Int):Void {
	}

	public function onPointerMove(p:Pointer):Void {
	}

	public function onWheel(p:Pointer, amount:Float):Void {
	}

	public function update():Void {
	}

	public function draw(g:Graphics):Void {
	}

	extern inline function get_x():Float {
		return element.boundary.x;
	}

	extern inline function get_y():Float {
		return element.boundary.y;
	}

	extern inline function get_width():Float {
		return element.boundary.w;
	}

	extern inline function get_height():Float {
		return element.boundary.h;
	}

	extern inline function get_style():Style {
		return element.style;
	}

	extern inline function get_layout():Layout {
		return element.layout;
	}

	extern inline function set_layout(layout:Layout):Layout {
		return element.layout = layout;
	}

	extern inline function get_pointers():Array<Pointer> {
		return pointerManager.pointers;
	}
}
