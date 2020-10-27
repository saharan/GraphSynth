package app.ui.view.menu;

using common.ArrayTools;
using common.FloatTools;
using common.IntTools;


class EventStopper extends Sprite {
	var time:Int;

	public function new(time:Int) {
		super();
		style.size.set(Percent(100), Percent(100));
		stopEvent = true;
		this.time = time;
	}

	override function update() {
		if (--time <= 0) {
			dead = true;
		}
	}
}
