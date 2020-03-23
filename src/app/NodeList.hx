package app;

import graph.NodeSetting;
import graph.NodeType;
import haxe.ds.Either;
import synth.EnvelopeData;
import synth.NodeRole;
import synth.NumberData;

using StringTools;

abstract Eith<L, R>(Either<L, R>) from Either<L, R> to Either<L, R> {
	@:from
	static inline function fromL<L, R>(l:L):Eith<L, R> {
		return Left(l);
	}

	@:from
	static inline function fromR<L, R>(r:R):Eith<L, R> {
		return Right(r);
	}
}

class NodeList {
	public static final FREQUENCY = n("input frequency", "f", Normal(false, true), Frequency, [], []);
	public static final OSCILLATOR = n("oscillator", "sin", Normal(false, true), Oscillator(Sine), ["freq", "detune"], []);
	public static final OUTPUT = n("output", "out", Normal(true, false), Destination, [], []);
	public static final DELAY = n("delay", "del", Normal(true, true), Delay, ["time"], []);
	public static final FILTER = n("filter", "LPF", Normal(true, true), Filter(LowPass), ["freq", "Q", "gain"], []);
	public static final COMPRESSOR = n("compressor", "cmp", Normal(true, true), Compressor, [], []);

	static function changeValue(values:Array<Float>, sign:Int, current:Float):Float {
		var index:Int = 0;
		var minDiff:Float = 1e6;
		for (i in 0...values.length) {
			var diff = Math.abs(current - values[i]);
			if (diff < minDiff) {
				minDiff = diff;
				index = i;
			}
		}
		index += sign;
		index = index < 0 ? 0 : index > values.length - 1 ? values.length - 1 : index;
		return values[index];
	}

	static function changeValueText(prefix:String, values:Array<Float>, sign:Int, current:Float):String {
		var currentStr = prefix + " " + Std.string(current);
		if (sign == -1)
			currentStr = "".rpad(" ", currentStr.length);
		return currentStr + " -> " + changeValue(values, sign, current);
	}

	extern static inline function getEnv(n:NodeSetting):EnvelopeData {
		return switch (n.role) {
			case Envelope(env): env;
			case _: throw "!?";
		}
	}

	public static final ENVELOPE = n("envelope", "env", Normal(false, true), Envelope(new EnvelopeData(0.05, 0.1, 0.8, 0.1)), [], []);

	extern static inline function getNum(n:NodeSetting):NumberData {
		return switch (n.role) {
			case Number(num): num;
			case _: throw "!?";
		}
	}

	public static final NUMBER = n("number", "", Normal(false, true), Number(new NumberData(0.0)), [], []);

	public static final ADD = n("addition", "+", Small, BinOp(Add), [], []);
	public static final MULT = n("multiplication", "×", Small, BinOp(Mult), [], []);
	public static final DUPL = n("duplication", "", Small, Dupl, [], []);

	extern static inline function n(fullName:String, labelName:String, type:NodeType, NodeRole:NodeRole, inParams:Array<String>,
			outParams:Array<String>):NodeInfo {
		return new NodeInfo(fullName, labelName, type, NodeRole, inParams, outParams);
	}
}
