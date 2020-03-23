package graph;

enum abstract PickFlag(Int) from Int to Int {
	var Node = v(0);
	var Cable = v(1);
	var Input = v(2);
	var Output = v(3);
	var InputParam = v(4);
	var OutputParam = v(5);
	
	var NonParam = Input | Output;
	var Param = InputParam | OutputParam;
	var Socket = NonParam | Param;
	var Connectable = Node | Cable | Param;
	var Removable = Node | Cable;
	var Configurable = Node | Param;
	var All = Node | Cable | Socket;

	extern static inline function v(a:Int):Int {
		return 1 << a;
	}
}
