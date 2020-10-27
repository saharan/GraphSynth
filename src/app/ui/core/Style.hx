package app.ui.core;

import app.ui.core.layout.AlignInline;
import common.Maybe;

class Style {
	public var hitArea:HitArea = Box;
	public var noHit:Bool = false;

	public final size:Dimension = new Dimension(Auto, Auto);
	public final minSize:Dimension = new Dimension(Auto, Auto);
	public final maxSize:Dimension = new Dimension(Auto, Auto);
	public final margin:Margin = new Margin(Zero, Zero, Zero, Zero);
	public final padding:Padding = new Padding(Zero, Zero, Zero, Zero);
	
	public var boxSizing:BoxSizing = Content;
	public var grow:Float = 0;
	public var shrink:Float = 1;
	public var alignInline:Maybe<AlignInline> = null;

	public function new() {
	}
}
