package app.ui.view.main.graph.history;

class GraphHistory {
	public static inline final MAX_SIZE:Int = 100;

	final maxSize:Int;
	final dataStack:Array<HistoryPoint>;
	var currentIndex:Int;

	public function new(maxSize:Int = MAX_SIZE) {
		this.maxSize = maxSize;
		dataStack = [];
		currentIndex = -1;
	}

	public function addSnapshot(hp:HistoryPoint):Void {
		if (currentIndex == dataStack.length - 1)
			dataStack.push(hp);
		else {
			dataStack.resize(currentIndex + 1);
			dataStack.push(hp);
		}
		currentIndex = dataStack.length - 1;

		if (dataStack.length > maxSize) {
			dataStack.splice(0, 1);
			currentIndex--;
		}
	}

	public function canUndo():Bool {
		return currentIndex > 0;
	}

	public function canRedo():Bool {
		return currentIndex < dataStack.length - 1;
	}

	public function undo():HistoryPoint {
		if (!canUndo())
			throw "cannot undo";
		return dataStack[--currentIndex];
	}

	public function redo():HistoryPoint {
		if (!canRedo())
			throw "cannot redo";
		return dataStack[++currentIndex];
	}
}
