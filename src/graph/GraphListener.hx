package graph;

interface GraphListener {
	function onNodeCreated(id:Int, setting:NodeSetting):Void;
	function onNodeDestroyed(id:Int):Void;
	function onSocketCreated(id:Int, nodeId:Int, type:SocketType):Void;
	function onSocketDestroyed(id:Int):Void;
	function onSocketConnected(id1:Int, id2:Int):Void;
	function onSocketDisconnected(id1:Int, id2:Int):Void;
	function onNodeUpdated(id:Int):Void;
	function onWaveDataRequest(arrayOut:Array<Float>):Void;
}
