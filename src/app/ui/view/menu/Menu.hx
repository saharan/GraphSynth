package app.ui.view.menu;

import pot.input.KeyValue;
import pot.input.Keyboard;
import app.ui.view.main.graph.GraphWrapper;
import app.ui.view.color.StaticColor;
import app.graphics.TextAlign;
import app.graphics.Graphics;
import app.ui.core.layout.FlexLayout;

using common.FloatTools;

class Menu extends Sprite {
	public static inline final WIDTH:Float = 250;
	public static inline final PADDING:Float = 8;
	public static inline final FONT_SIZE:Float = 1.3;
	public static inline final ITEM_HEIGHT:Float = 20;
	public static inline final ITEM_MARGIN:Float = 2;
	public static inline final ITEM_SPACE:Float = 8;
	public static inline final ANIMATION_DURATION:Int = 10;

	public static inline final MENU_CLOSE_WAIT_RATIO:Float = 0.5;

	public final wrapper:Sprite;

	final graph:GraphWrapper;

	var deathCount:Int = 0;
	var liveCount:Int = ANIMATION_DURATION;

	var primaryPointerDownOutsize:Bool;
	var enableClosingOnOutsideClick:Bool;

	public function new(graph:GraphWrapper, wrapper:Sprite = null) {
		super();
		this.graph = graph;
		stopEvent = true;
		style.size.set(Percent(100), Percent(100));
		var fl = new FlexLayout(Y);
		fl.alignCross = Center;
		layout = fl;

		if (wrapper == null)
			wrapper = new Sprite();
		this.wrapper = wrapper;
		wrapper.style.size.w = Px(WIDTH);
		wrapper.style.padding.all(Px(PADDING));
		wrapper.style.grow = 1;
		wrapper.style.margin.top = Percent(5);
		wrapper.style.margin.bottom = Auto;

		wrapper.layout = new FlexLayout(Y);

		enableClosingOnOutsideClick = false;

		addChild(wrapper);
	}

	override function onPointerDown(p:Pointer, index:Int) {
		super.onPointerDown(p, index);
		if (p.isPrimary) {
			primaryPointerDownOutsize = !wrapper.element.boundary.hitTest(p.x, p.y);
		}
	}

	override function onPointerUp(p:Pointer, index:Int) {
		super.onPointerUp(p, index);
		if (p.isPrimary && primaryPointerDownOutsize) {
			if (!wrapper.element.boundary.hitTest(p.x, p.y)) {
				// clicked outside the window, close the menu
				if (enableClosingOnOutsideClick)
					close();
			}
		}
	}

	function addTitle(text:Gen<String>):Void {
		var title = new Label(text, Center, Auto, Px(32), 2.0);
		title.style.margin.top = Px(8);
		title.style.margin.bottom = Px(8);
		title.stroke = true;
		title.strokeColor = StaticColor.black();
		title.fillColor = StaticColor.white();
		wrapper.addChild(title);
	}

	public function addRow(itemOrItems:MenuRow, heightScale:Float = 1.0):Void {
		var items:Array<Sprite> = itemOrItems;
		var row = new Sprite();
		row.style.size.h = Px(ITEM_HEIGHT * heightScale);
		row.style.margin.bottom = Px(ITEM_MARGIN);
		row.layout = new FlexLayout(X);

		for (item in items) {
			item.style.margin.left = Px(ITEM_MARGIN);
			if (item.style.grow == 0)
				item.style.grow = 1;
			row.addChild(item);
		}
		items[0].style.margin.left = Zero;

		wrapper.addChild(row);
	}

	public function addSpace():Void {
		var lastElement = wrapper.children[wrapper.children.length - 1];
		lastElement.style.margin.bottom = Px(ITEM_MARGIN + ITEM_SPACE);
	}

	public function item(text:Gen<String>, onClick:Void->Void, closeWhenSelected:Bool = false, bullet:Bool = true):MenuItem {
		var i = new MenuItem(text, () -> {
			if (onClick != null)
				onClick();
			if (closeWhenSelected)
				close();
		}, bullet);
		i.style.size.h = Px(ITEM_HEIGHT);
		return i;
	}

	public function checkBox(text:Gen<String>, onClick:(selected:Bool) -> Void, selected:Bool = false):CheckBox {
		var cb = new CheckBox(text, onClick == null ? _ -> {} : onClick, selected);
		cb.style.size.h = Px(ITEM_HEIGHT);
		return cb;
	}

	public function radioButton(text:Gen<String>, onSelected:Void->Void, selected:Bool = false):RadioButton {
		var rb = new RadioButton(text, onSelected == null ?() -> {} : onSelected, selected);
		rb.style.size.h = Px(ITEM_HEIGHT);
		return rb;
	}

	public function button(text:Gen<String>, onClick:Void->Void, closeWhenSelected:Bool = false):Button {
		var b = new Button(Auto, Auto, text, () -> {
			if (onClick != null)
				onClick();
			if (closeWhenSelected)
				close();
		}, FONT_SIZE);
		b.style.size.h = Px(ITEM_HEIGHT);
		return b;
	}

	public function label(text:Gen<String>, scale:Float = 1.0, align:TextAlign = Center):Label {
		var l = new Label(text, align, Auto, Auto, FONT_SIZE * scale);
		l.style.size.h = Px(ITEM_HEIGHT);
		return l;
	}

	public function close():Void {
		if (deathCount == 0) {
			deathCount = 1;
			style.noHit = true;
			liveCount = 0;
			onClose();
		}
	}

	// called when the menu is closed
	function onClose():Void {
	}

	override function update() {
		if (deathCount == 0 && graph.op.getTopMenu() == this)
			onKeyboardUpdate(graph.op.getKeyboard());
		if (deathCount > 0 && ++deathCount == ANIMATION_DURATION * (1 + MENU_CLOSE_WAIT_RATIO))
			dead = true;
		if (liveCount > 0 && --liveCount == 0)
			style.noHit = false;
	}

	function onKeyboardUpdate(keyboard:Keyboard):Void {
		if (keyboard.isKeyDown(Escape)) {
			close();
		}
	}

	override function draw(g:Graphics) {
		var deathCountOffset = ANIMATION_DURATION * MENU_CLOSE_WAIT_RATIO;
		var deathRatio = (deathCount - deathCountOffset).max(0) / ANIMATION_DURATION;
		var liveRatio = liveCount / ANIMATION_DURATION;
		var t = 1 - deathRatio - liveRatio;
		t = 1 - t;
		t = t * t * t * t;
		t = 1 - t;
		g.fill(1, 1, 1, 0.9 * t);
		g.rect(0, 0, width, height, Fill);
		if (t < 1) {
			var pivotY = wrapper.element.boundary.y + wrapper.element.boundary.h * 0.5;
			g.translate(width * 0.5, pivotY);
			g.scale(1, t);
			g.translate(-width * 0.5, -pivotY);
		}
	}
}

private abstract MenuRow(Array<Sprite>) from Array<Sprite> to Array<Sprite> {
	@:from
	static inline function fromSprite(s:Sprite):MenuRow {
		return [s];
	}

	@:from
	static inline function fromInheritedArray<A:Sprite>(a:Array<A>):MenuRow {
		return a.map(a -> cast a);
	}
}
