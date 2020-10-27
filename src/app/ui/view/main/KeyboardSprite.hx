package app.ui.view.main;

import app.graphics.Graphics;
import app.ui.core.Element;

using Lambda;

class KeyboardSprite extends Sprite {
	final whiteKeys:Array<Float> = []; // x, y, w, h
	final whiteKeysBound:Array<Float> = []; // x, y, w, h
	final whiteKeysIndex:Array<Int> = [];
	final blackKeys:Array<Float> = []; // x, y, w, h
	final blackKeysBound:Array<Float> = []; // x, y, w, h
	final blackKeysIndex:Array<Int> = [];

	public final keysPressed:Array<Bool> = [];

	public var numTotalKeys(default, null):Int;

	var stroke:Float;
	var baseOctave:Gen<Int>;
	var op:MainOperator;

	var prevPressed:Bool = false;
	var prevFreqIndex:Int = -1;

	public function new(baseOctave:Gen<Int>, op:MainOperator) {
		super();
		this.baseOctave = baseOctave;
		this.op = op;

		style.size.set(Percent(100), Percent(20));
	}

	override function update() {
		updateLayout();
		hitTest();

		var index = keysPressed.indexOf(true);
		var pressed = index != -1;

		if (pressed && !prevPressed) {
			op.attack();
		}
		if (pressed) {
			var freqIndex = (baseOctave() - 4) * 12 + (index - 9);
			if (freqIndex != prevFreqIndex) {
				var time = 0.001;
				if (!prevPressed) {
					time = 0;
				}
				var freq = 440 * Math.pow(2, freqIndex / 12);
				op.setFrequency(freq, time);
			}
			prevFreqIndex = freqIndex;
		}

		if (!pressed && prevPressed) {
			op.release();
		}

		prevPressed = pressed;
	}

	extern inline function forEachKey(keys:Array<Float>, f:(i:Int, x:Float, y:Float, w:Float, h:Float) -> Void):Void {
		var numKeys = keys.length >> 2;
		for (i in 0...numKeys) {
			var x = keys[i << 2 | 0];
			var y = keys[i << 2 | 1];
			var w = keys[i << 2 | 2];
			var h = keys[i << 2 | 3];
			f(i, x, y, w, h);
		}
	}

	function hitTest():Void {
		keysPressed.resize(numTotalKeys);

		var p = pointerManager.primaryPointer;
		var blackHit = false;
		forEachKey(blackKeysBound, (i, x, y, w, h) -> {
			var hit = p != null && p.isDown(0) && p.x >= x && p.x < x + w && p.y >= y && p.y < y + h;
			keysPressed[blackKeysIndex[i]] = hit;
			blackHit = blackHit || hit;
		});
		forEachKey(whiteKeysBound, (i, x, y, w, h) -> {
			var hit = !blackHit && p != null && p.isDown(0) && p.x >= x && p.x < x + w && p.y >= y && p.y < y + h;
			keysPressed[whiteKeysIndex[i]] = hit;
		});
	}

	function updateLayout():Void {
		stroke = 1.5;
		var blackKeyWidthRatio:Float = 0.6;
		var blackKeyHeightRatio:Float = 0.5;
		var blackKeyHitWidthScale:Float = 1.5;
		var keyWidth:Float = 24;
		var numKeys:Int = Math.ceil((width - stroke) / keyWidth);
		if (numKeys > 100)
			numKeys = 100;
		keyWidth = (width - stroke) / numKeys;

		whiteKeys.resize(0);
		blackKeys.resize(0);
		whiteKeysBound.resize(0);
		blackKeysBound.resize(0);
		whiteKeysIndex.resize(0);
		blackKeysIndex.resize(0);

		inline function whiteKey(index:Int, x:Float, y:Float, w:Float, h:Float):Void {
			whiteKeys.push(x);
			whiteKeys.push(y);
			whiteKeys.push(w + stroke);
			whiteKeys.push(h);
			whiteKeysBound.push(x + stroke * 0.5);
			whiteKeysBound.push(y + stroke);
			whiteKeysBound.push(w);
			whiteKeysBound.push(h - stroke * 2);
			whiteKeysIndex.push(index);
		}

		inline function blackKey(index:Int, centerX:Float, y:Float, w:Float, h:Float):Void {
			blackKeys.push(centerX - w * 0.5);
			blackKeys.push(y);
			blackKeys.push(w);
			blackKeys.push(h);
			blackKeysBound.push(centerX - blackKeyHitWidthScale * w * 0.5);
			blackKeysBound.push(y + stroke);
			blackKeysBound.push(w * blackKeyHitWidthScale);
			blackKeysBound.push(h - stroke * 2);
			blackKeysIndex.push(index);
		}

		var blackKeyExists = [true, true, false, true, true, true, false];

		// hit test
		var index = 0;
		for (i in 0...numKeys) {
			whiteKey(index, keyWidth * i, 0, keyWidth, height);
			index++;
			if (i < numKeys - 1 && blackKeyExists[i % blackKeyExists.length]) {
				var blackCenter = keyWidth * (i + 1) + 0.5 * stroke;
				var blackWidth = keyWidth * blackKeyWidthRatio;
				blackKey(index, blackCenter, 0, blackWidth, height * blackKeyHeightRatio);
				index++;
			}
		}
		numTotalKeys = index;
	}

	override function draw(g:Graphics) {
		g.fill(0.5, 0.5, 0.5);
		g.rect(0, 0, width, height, Fill);

		var st = stroke;
		var firstKey = true;
		forEachKey(whiteKeys, (i, x, y, w, h) -> {
			g.fill(0, 0, 0);
			g.rect(x, y, w, h, Fill);
			var pressed = keysPressed[whiteKeysIndex[i]];
			if (pressed)
				g.fill(1, 0.6, 0.6);
			else
				g.fill(1, 1, 1);
			g.rect(x + st, y + st, w - st * 2, h - st * 2, Fill);
			if (!pressed) {
				var shadowH = w * 0.6;
				g.fill(0.8, 0.8, 0.8);
				g.rect(x + st, y + h - shadowH + st, w - st * 2, shadowH - st * 2, Fill);
			}
			if (i % 7 == 0) {
				g.fill(0, 0, 0);
				g.textAlign(Center);
				g.text("C" + Std.int(baseOctave() + i / 7), x + w * 0.5, y + h * (pressed ? 0.75 : 0.7), Fill);
			}
		});
		forEachKey(blackKeys, (i, x, y, w, h) -> {
			g.fill(0, 0, 0);
			g.rect(x, y, w, h, Fill);
			var pressed = keysPressed[blackKeysIndex[i]];
			if (pressed)
				g.fill(0.6, 0, 0);
			else
				g.fill(0, 0, 0);
			g.rect(x + st, y + st, w - st * 2, h - st * 2, Fill);
			if (!pressed) {
				var shadowH = w * 0.8;
				g.fill(0.4, 0.4, 0.4);
				g.rect(x + st, y + h - shadowH + st, w - st * 2, shadowH - st * 2, Fill);
			}
		});
	}
}
