package app.task;

class Task {
	public var count:Int;
	public var func:Int->TaskResult;

	public function new(func:Int->TaskResult) {
		this.func = func;
		count = 0;
	}
}
