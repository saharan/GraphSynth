package app.ui.view.menu;

import app.ui.view.color.StaticColor;
import app.graphics.Graphics;
import app.ui.core.layout.FlexLayout;

class RadioButton extends Underlined {
	var label:Label;
	var selected:Bool;
	var group:Array<RadioButton> = [];

	public function new(text:Gen<String>, onSelected:Void->Void, initialSelected:Bool) {
		super(text, () -> {
			if (!selected) {
				for (rb in group) {
					rb.selected = false;
				}
				selected = true;
				selectedCount = 1;
				onSelected();
			}
		});
		selected = initialSelected;

		pointerPolicy = Free;
		style.margin.all(Zero);
		label = new Label(text, Left, Auto, Auto, Menu.FONT_SIZE);
		label.style.grow = 1;
		label.style.margin.left = Px(Menu.ITEM_HEIGHT * 1.2);
		layout = new FlexLayout(X);
		addChild(label);
	}

	public static function addGroup(group:Array<RadioButton>):Void {
		group = group.copy();
		for (g in group) {
			g.group = group;
		}
	}

	public function select():Void {
		onClick();
	}

	override function draw(g:Graphics) {
		if (state.match(Hover | Pressed) || selectedCount > 0) {
			g.fill(0.6, 0, 0);
			g.stroke(0.6, 0, 0);
			label.fillColor = [0.4, 0, 0];
		} else {
			g.fill(0, 0, 0);
			g.stroke(0, 0, 0);
			label.fillColor = StaticColor.black();
		}
		var maxCircleR = Menu.ITEM_HEIGHT * 0.5;
		var circleR = maxCircleR * 0.5 * switch state {
			case Default | Hover | PressedOut:
				1.2;
			case Pressed:
				1.0;
		}
		g.lineWidth(2);
		g.circle(maxCircleR, height * 0.5, circleR, Stroke);
		var innerCircleR = circleR - 2;
		if (selected)
			g.circle(maxCircleR, height * 0.5, innerCircleR, Fill);
		if (selectedCount > 0) {
			var t = selectedCount / Menu.ANIMATION_DURATION;
			t = t > 1 ? 1 : t;
			g.fill(0.6, 0, 0, 1 - t * t);
			var rs = (circleR + 2) + 4 * t;
			g.circle(maxCircleR, height * 0.5, rs, Fill);
		}
		super.draw(g);
	}
}
