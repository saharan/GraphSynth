package app.task;

class TaskRunner {
	var tasks:Array<Task>;

	public function new() {
		tasks = [];
	}

	public function add(task:Int->TaskResult):Void {
		tasks.push(new Task(task));
	}

	public function process():Void {
		tasks = tasks.filter(task -> switch (task.func(task.count++)) {
			case Keep: true;
			case Delete: false;
		});
	}
}
