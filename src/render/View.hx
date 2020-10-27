package render;

import app.graphics.Graphics;
import app.ui.SizePeek;

using common.FloatTools;

class View {
	public static inline final MIN_SCALE:Float = 0.1;
	public static inline final MAX_SCALE:Float = 10;
	public static inline final DEFAULT_SCALE:Float = 2;

	public final sizePeek:SizePeek;

	final data:ViewData;

	public var centerX(get, set):Float;
	public var centerY(get, set):Float;
	public var scale(get, set):Float;

	public function new(sizePeek:SizePeek) {
		this.sizePeek = sizePeek;
		data = new ViewData();
	}

	extern inline function get_centerX():Float {
		return data.centerX;
	}

	extern inline function set_centerX(v:Float):Float {
		return data.centerX = v;
	}

	extern inline function get_centerY():Float {
		return data.centerY;
	}

	extern inline function set_centerY(v:Float):Float {
		return data.centerY = v;
	}

	extern inline function get_scale():Float {
		return data.scale;
	}

	extern inline function set_scale(s:Float):Float {
		var scale = data.scale;
		scale = s.clamp(MIN_SCALE, MAX_SCALE);
		if (!Math.isFinite(data.scale))
			scale = DEFAULT_SCALE;
		return data.scale = scale;
	}

	public function getData():ViewData {
		return data.copy();
	}

	public function setData(data:ViewData):Void {
		centerX = data.centerX;
		centerY = data.centerY;
		scale = data.scale;
	}

	public inline function worldX(screenX:Float):Float {
		return (screenX - sizePeek.getW() * 0.5) / scale + centerX;
	}

	public inline function worldY(screenY:Float):Float {
		return (screenY - sizePeek.getH() * 0.5) / scale + centerY;
	}

	public inline function screenX(worldX:Float):Float {
		return (worldX - centerX) * scale + sizePeek.getW() * 0.5;
	}

	public inline function screenY(worldY:Float):Float {
		return (worldY - centerY) * scale + sizePeek.getH() * 0.5;
	}

	public inline function computeCenterX(screenX:Float, worldX:Float):Float {
		return worldX - (screenX - sizePeek.getW() * 0.5) / scale;
	}

	public inline function computeCenterY(screenY:Float, worldY:Float):Float {
		return worldY - (screenY - sizePeek.getH() * 0.5) / scale;
	}

	public function centering(screenX:Float, screenY:Float, worldX:Float, worldY:Float):Void {
		centerX = computeCenterX(screenX, worldX);
		centerY = computeCenterY(screenY, worldY);
	}

	public function applyTransform(g:Graphics):Void {
		g.translate(sizePeek.getW() * 0.5, sizePeek.getH() * 0.5);
		g.scale(scale, scale);
		g.translate(-centerX, -centerY);
	}
}
