package app;

import graph.NodeType;
import synth.EnvelopeData;
import synth.NodeRole;
import synth.NumberData;

using StringTools;

class NodeList {
	public static final FREQUENCY = n("Frequency", "f", Normal(false, true), Frequency, [], []);
	public static final OSCILLATOR = n("Oscillator", "sin", Normal(false, true), Oscillator(Sine), [ip("freq", 440), ip("gain",
		0.5), ip("detune", 0.0)], []);
	public static final OUTPUT = n("Output", "out", Normal(true, false), Destination, [], []);
	public static final DELAY = n("Delay", "del", Normal(true, true), Delay, [ip("time", 0.2)], []);
	public static final FILTER = n("Filter", "LPF", Normal(true, true), Filter(LowPass), [ip("freq", 350), ip("Q", 1), ip("gain", 0)], []);
	public static final COMPRESSOR = n("Compressor", "cmp", Normal(true, true), Compressor, [], []);
	public static final ENVELOPE = n("Envelope", "env", Normal(false, true), Envelope(new EnvelopeData(0.05, 0.1, 0.8, 0.1)), [], []);
	public static final NUMBER = numberOfValue(0.0);
	public static final ADD = n("Addition", "+", Small, BinOp(Add), [], []);
	public static final MULT = n("Multiplication", "×", Small, BinOp(Mult), [], []);
	public static final DUPL = n("Duplication", "", Small, Dupl, [], []);

	public static inline function numberOfValue(value:Float):NodeInfo {
		return n("Number", "", Normal(false, true), Number(new NumberData(value)), [], []);
	}

	extern static inline function ip(name:String, defaultValue:Null<Float> = null):NodeInputParamInfo {
		return new NodeInputParamInfo(name, defaultValue);
	}

	extern static inline function op(name:String):NodeOutputParamInfo {
		return new NodeOutputParamInfo(name);
	}

	extern static inline function n(fullName:String, labelName:String, type:NodeType, NodeRole:NodeRole,
			inParams:Array<NodeInputParamInfo>, outParams:Array<NodeOutputParamInfo>):NodeInfo {
		return new NodeInfo(fullName, labelName, type, NodeRole, inParams, outParams);
	}
}
