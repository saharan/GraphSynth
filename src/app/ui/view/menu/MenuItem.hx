package app.ui.view.menu;

import app.ui.view.color.StaticColor;
import app.graphics.Graphics;
import app.ui.core.layout.FlexLayout;

class MenuItem extends Underlined {
	var label:Label;
	var bullet:Bool;

	public function new(text:Gen<String>, onClick:Void->Void, bullet:Bool) {
		super(text, () -> {
			onClick();
			selectedCount = 1;
		});
		this.bullet = bullet;
		textScale = Menu.FONT_SIZE;

		pointerPolicy = Free;
		style.margin.all(Zero);
		label = new Label(text, bullet ? Left : Center, Auto, Auto, () -> textScale);
		label.style.grow = 1;
		if (bullet)
			label.style.margin.left = Px(Menu.ITEM_HEIGHT);
		layout = new FlexLayout(X);
		addChild(label);
	}

	override function draw(g:Graphics) {
		if (state.match(Hover | Pressed) || selectedCount > 0) {
			g.fill(0.6, 0, 0);
			label.fillColor = [0.4, 0, 0];
		} else {
			g.fill(0, 0, 0);
			label.fillColor = StaticColor.black();
		}
		if (bullet) {
			var maxCircleR = Menu.ITEM_HEIGHT * 0.5;
			g.circle(maxCircleR, height * 0.5, switch state {
				case Default | Hover | PressedOut:
					3;
				case Pressed:
					4;
			}, Fill);
			if (selectedCount > 0) {
				var t = selectedCount / Menu.ANIMATION_DURATION;
				t = t > 1 ? 1 : t;
				g.fill(0.6, 0, 0, 1 - t * t);
				g.circle(maxCircleR, height * 0.5, 4 + t * 4, Fill);
			}
		}
		super.draw(g);
	}
}
