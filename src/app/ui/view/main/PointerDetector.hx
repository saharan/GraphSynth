package app.ui.view.main;

import app.ui.core.Element;
import app.ui.core.layout.OverlayLayout;

class PointerDetector extends Sprite {
	final markers:Array<PointerMarker> = [];

	public function new() {
		super();
		style.size.set(Percent(100), Percent(100));
		layout = new OverlayLayout();
	}

	override function onPointerEnter(p:Pointer) {
		var marker = new PointerMarker(p);
		markers.push(marker);
		addChild(marker);
	}

	override function onPointerExit(p:Pointer) {
		getMarker(p).die();
	}

	override function onPointerDown(p:Pointer, index:Int) {
		// trace("down! " + p.id);
		if (index == 0)
			getMarker(p).down();
	}

	override function onPointerUp(p:Pointer, index:Int) {
		// trace("up!" + p.id);
		if (index == 0)
			getMarker(p).up();
	}

	function getMarker(p:Pointer):PointerMarker {
		for (marker in markers) {
			if (marker.p == p)
				return marker;
		}
		return null;
	}
}
