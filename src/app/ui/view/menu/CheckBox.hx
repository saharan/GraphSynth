package app.ui.view.menu;

import app.ui.view.color.StaticColor;
import app.graphics.DrawMode;
import app.graphics.Graphics;
import app.ui.core.layout.FlexLayout;

class CheckBox extends Underlined {
	var label:Label;
	var selected:Bool;

	public function new(text:Gen<String>, onClick:(selected:Bool) -> Void, initialSelected:Bool) {
		super(text, () -> {
			selected = !selected;
			onClick(selected);
			selectedCount = 1;
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

	public function setSelected(selected:Bool):Void {
		if (this.selected != selected) {
			onClick();
		}
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
		var rectSize = maxCircleR * switch state {
			case Default | Hover | PressedOut:
				1.2;
			case Pressed:
				1.0;
		}
		g.lineWidth(2);
		rectCenter(g, maxCircleR, height * 0.5, rectSize, Stroke);
		var innerRectSize = rectSize - 4;
		if (selected)
			rectCenter(g, maxCircleR, height * 0.5, innerRectSize, Fill);
		if (selectedCount > 0) {
			var t = selectedCount / Menu.ANIMATION_DURATION;
			t = t > 1 ? 1 : t;
			g.fill(0.6, 0, 0, 1 - t * t);
			var rs = (rectSize + 2) + 4 * t;
			rectCenter(g, maxCircleR, height * 0.5, rs, Fill);
		}
		super.draw(g);
	}

	static function rectCenter(g:Graphics, x:Float, y:Float, wh:Float, mode:DrawMode):Void {
		g.rect(x - wh * 0.5, y - wh * 0.5, wh, wh, mode);
	}
}
