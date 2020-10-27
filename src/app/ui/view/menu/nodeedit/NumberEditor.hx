package app.ui.view.menu.nodeedit;

import app.ui.core.layout.FlexLayout;
import app.ui.view.Slider.SliderType;
import app.ui.view.main.graph.GraphWrapper;
import app.ui.view.menu.dialogue.CalcEnterDialog;

using common.FloatTools;

class NumberEditor {
	final graph:GraphWrapper;
	final menu:Menu;
	final labelName:String;
	final fullName:String;
	final range:NumberRange;
	final oneLine:Bool;
	final initialValue:Float;
	final onChanged:Float->Void;

	final minTextLength:Int;
	final maxTextLength:Int;

	var sliderTypes:Array<SliderType>;
	var sliderScales:Array<Float>;
	var sliders:Array<Slider>;

	var slidersWrapper:Sprite;
	var labelWrapper:Sprite;

	var text:String;
	var negated:Bool;

	var insideUpdate:Bool = false;

	public function new(graph:GraphWrapper, menu:Menu, labelName:String, fullName:String, range:NumberRange, oneLine:Bool,
			initialValue:Float, onChanged:Float->Void) {
		this.graph = graph;
		this.menu = menu;
		this.labelName = labelName;
		this.fullName = fullName;
		this.range = range;
		this.oneLine = oneLine;
		this.initialValue = initialValue;
		this.onChanged = onChanged;

		minTextLength = 5;
		maxTextLength = oneLine ? 6 : 10;

		negated = initialValue < 0;

		initSliders();
		initLabel();

		if (oneLine) {
			menu.addRow([menu.label(labelName), labelWrapper, slidersWrapper], sliders.length);
		} else {
			menu.addRow([labelWrapper, slidersWrapper], sliders.length);
		}

		update(initialValue.abs());
	}

	function initSliders():Void {
		switch range {
			case Real:
				sliderTypes = [Logarithmic(3), Logarithmic(3), Logarithmic(3), Logarithmic(3)];
				sliderScales = [1, 10, 100, 1000];
			case Hz | Sec:
				sliderTypes = [Logarithmic(10)];
				sliderScales = [1];
			case Level:
				sliderTypes = [Linear];
				sliderScales = [1];
		}

		var min = range.min();
		var max = range.max();
		var absInitial = initialValue.abs();
		sliders = [for (i in 0...sliderTypes.length) {
			new Slider(X, min / sliderScales[i], max / sliderScales[i], absInitial, sliderTypes[i], updateBySlider);
		}];

		for (s in sliders) {
			s.style.size.h = Px(Menu.ITEM_HEIGHT);
			s.style.margin.top = Px(Menu.ITEM_MARGIN);
		}
		sliders[0].style.margin.top = Zero;

		slidersWrapper = new Sprite();
		slidersWrapper.style.grow = 2.4;
		slidersWrapper.layout = new FlexLayout(Y);
		for (s in sliders)
			slidersWrapper.addChild(s);
	}

	function initLabel():Void {
		labelWrapper = new Sprite();
		labelWrapper.layout = new FlexLayout(Y);

		var signed = range.signed();
		var checkbox = if (signed) {
			menu.checkBox("negative", flag -> {
				negated = flag;
				update(sliders[0].value);
			}, negated);
		} else {
			null;
		}
		var nameLabel = menu.label(fullName);
		var valueLabel = menu.item(() -> text, () -> {
			graph.op.openMenu(new CalcEnterDialog(graph, fullName, v -> if (v != null) {
				if (signed) {
					negated = v < 0;
					if (negated)
						v = -v;
					checkbox.setSelected(negated);
				} else {
					if (v < 0)
						v = 0;
				}
				update(v.clamp(range.min(), range.max()));
			}));
		}, false, false);
		if (!oneLine) {
			labelWrapper.addChild(nameLabel);
		}
		labelWrapper.addChild(valueLabel);
		if (!oneLine && signed) {
			checkbox.style.margin.top = Auto;
			labelWrapper.addChild(checkbox);
		}
		if (!oneLine) {
			var cs = labelWrapper.children;
			cs[0].style.margin.top = Auto;
			cs[cs.length - 1].style.margin.bottom = Auto;
		}
	}

	function updateBySlider(absVal:Float):Void {
		if (sliders == null)
			return;
		if (insideUpdate)
			return; // prevent infinite recursion
		var truncation = if (absVal < 1) {
			10;
		} else if (absVal < 10) {
			100;
		} else if (absVal < 100) {
			1000;
		} else if (absVal < 1000) {
			10000;
		} else if (absVal < 10000) {
			100000;
		} else {
			1000000;
		}
		var intAbsVal = Math.round(absVal * 10000);
		intAbsVal = Std.int(intAbsVal / truncation + 0.5) * truncation;
		update(intAbsVal / 10000);
	}

	function update(absVal:Float):Void {
		if (sliders == null)
			return;
		if (insideUpdate)
			throw "unexpected recursive update";
		var value = negated ? -absVal : absVal;
		insideUpdate = true;
		for (s in sliders) {
			s.setValue(absVal);
		}
		text = updateText(value);
		onChanged(value);
		insideUpdate = false;
	}

	static function toFixed(v:Float):String {
		var intVal = Math.round(v * 10000);
		var res = Std.string(intVal / 10000);
		if (res.indexOf(".") == -1)
			res += ".0";
		return res;
	}

	function updateText(value:Float):String {
		var res = toFixed(value);
		while (res.length < minTextLength) {
			res += "0";
		}
		if (res.length > maxTextLength)
			res = res.substr(0, maxTextLength);
		return res;
	}
}
