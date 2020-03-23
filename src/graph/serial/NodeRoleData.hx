package graph.serial;

import synth.FilterType;
import synth.OscillatorType;

typedef NodeRoleData = {
	@:optional var frequency:NullData;
	@:optional var oscillator:OscillatorType;
	@:optional var destination:NullData;
	@:optional var delay:NullData;
	@:optional var filter:FilterType;
	@:optional var compressor:NullData;
	@:optional var envelope:EnvelopeData;
	@:optional var number:Float;
	@:optional var binOp:BinOpType;
	@:optional var dupl:NullData;
	@:optional var none:NullData;
}

typedef EnvelopeData = {
	var a:Float;
	var d:Float;
	var s:Float;
	var r:Float;
}
