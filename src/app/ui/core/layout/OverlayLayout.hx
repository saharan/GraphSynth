package app.ui.core.layout;

using common.ArrayTools;
using common.FloatTools;

class OverlayLayout extends Layout {
	public function new() {
		super();
	}

	override function getContentSize(axis:Axis):Float {
		return children.mapMax(c -> c.getBoundarySize(axis, 0, true)).or(0);
	}

	override function getMinContentSize(axis:Axis):Float {
		return children.mapMax(c -> c.getMinBoundarySize(axis, 0, true)).or(0);
	}

	override function getMaxContentSize(axis:Axis):Float {
		return Math.POSITIVE_INFINITY;
	}

	static function process(axis:Axis, parent:Element, e:Element):Void {
		var parentStart = parent.contentStart(axis);
		var parentSize = parent.contentSize(axis);
		var margin = e.style.margin;
		var margins = [margin.start(axis), margin.end(axis)];
		var autoMarginType = (margins[0] == Auto ? 1 : 0) | (margins[1] == Auto ? 2 : 0);
		var marginSizes = margins.map(m -> m.toLength(Zero).calc(parentSize));
		var marginSum = marginSizes[0] + marginSizes[1];
		var sizeSpecified = e.style.size.along(axis) != Auto;

		// compute align
		var align:AlignInline = switch (autoMarginType) {
			case 0 | 2:
				Start;
			case 1:
				End;
			case _: // 3
				Center;
		}

		// determine size
		var contentSize = e.getBoundarySize(axis, parentSize, false);
		var minSize = e.getMinBoundarySize(axis, parentSize, false);
		var maxSize = e.getMaxBoundarySize(axis, parentSize, false);
		var size = if (sizeSpecified) {
			contentSize;
		} else {
			(parentSize - marginSum).min(contentSize);
		}
		size = size.clamp(minSize, maxSize);

		// determine spaces
		var freeSpace = parentSize - (size + marginSum);
		var startSpace = switch align {
			case Stretch | Start:
				0;
			case Center:
				freeSpace / 2;
			case End:
				freeSpace;
		}

		// set
		e.boundary.setAlong(axis, parentStart + marginSizes[0] + startSpace, size);
	}

	override function run() {
		for (c in children) {
			process(X, target, c);
			process(Y, target, c);
		}
	}
}
