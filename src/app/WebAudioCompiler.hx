package app;

import js.lib.Float32Array;
import js.html.audio.AnalyserNode;
import graph.GraphListener;
import graph.NodeSetting;
import graph.SocketType;
import js.html.audio.AudioContext;
import js.html.audio.AudioNode;
import js.html.audio.AudioParam;
import js.html.audio.AudioProcessingEvent;
import js.html.audio.BiquadFilterNode;
import js.html.audio.DelayNode;
import js.html.audio.GainNode;
import js.html.audio.OscillatorNode;
import js.lib.WeakMap;

using app.WebAudioCompiler.AudioNodeTools;

class AudioNodeTools {
	static var mapN:WeakMap<Map<AudioNode, Bool>> = new WeakMap();
	static var mapP:WeakMap<Map<AudioParam, Bool>> = new WeakMap();

	public static function connectSafe(src:AudioNode, ?targetNode:AudioNode, ?targetParam:AudioParam):Void {
		if (!mapN.has(src))
			mapN.set(src, new Map());
		if (!mapP.has(src))
			mapP.set(src, new Map());
		if (targetNode != null) {
			mapN.get(src).set(targetNode, true);
			src.connect(targetNode);
		}
		if (targetParam != null) {
			mapP.get(src).set(targetParam, true);
			src.connect(targetParam);
		}
	}

	public static function disconnectSafe(src:AudioNode, ?targetNode:AudioNode, ?targetParam:AudioParam):Void {
		if (!mapN.has(src))
			mapN.set(src, new Map());
		if (!mapP.has(src))
			mapP.set(src, new Map());
		if (targetNode != null) {
			mapN.get(src).remove(targetNode);
			src.disconnect(targetNode);
		}
		if (targetParam != null) {
			mapP.get(src).remove(targetParam);
			src.disconnect(targetParam);
		}
		if (targetNode == null && targetParam == null) {
			mapN.get(src).clear();
			mapP.get(src).clear();
			src.disconnect();
		}
		for (n in mapN.get(src).keys()) {
			src.connect(n);
		}
		for (p in mapP.get(src).keys()) {
			src.connect(p);
		}
	}
}

private class NodeData {
	public var id:Int;
	public var setting:NodeSetting;
	public var target:NodeTarget;

	public function new(id:Int, setting:NodeSetting, target:NodeTarget) {
		this.id = id;
		this.setting = setting;
		this.target = target;
	}
}

private class SocketData {
	public var id:Int;
	public var nodeId:Int;
	public var type:SocketType;
	public var target:SocketTarget;

	public function new(id:Int, nodeId:Int, type:SocketType, target:SocketTarget) {
		this.id = id;
		this.nodeId = nodeId;
		this.type = type;
		this.target = target;
	}
}

private enum SocketTarget {
	Node(n:NodeTarget);
	Param(p:AudioParam);
}

private enum NodeTarget {
	Node(n:AudioNode);
	MultiNode(n:MultiNode);
}

// pseudo-AudioNode for multiplication
private class MultiNode {
	public var inputs:Array<AudioNode>;
	public var output:GainNode;

	var ctx:AudioContext;
	var nodes:Array<GainNode>;

	public var mul:Bool;

	var const:GainNode;

	public function new(ctx:AudioContext, mul:Bool) {
		this.ctx = ctx;
		this.mul = mul;
		inputs = [];
		output = ctx.createGain();
		output.gain.value = 0;
		const = ConstNode.make(ctx, mul ? 1 : 0);
		const.connectSafe(output);

		nodes = [];
	}

	public function connectInput(input:AudioNode) {
		inputs.push(input);
		updateInputs();
	}

	public function disconnectInput(input:AudioNode) {
		inputs.remove(input);
		input.disconnectSafe();
		updateInputs();
	}

	public function updateInputs():Void {
		for (n in inputs)
			n.disconnectSafe();
		for (n in nodes) {
			n.disconnectSafe();
		}
		nodes = [];
		if (mul) {
			const.gain.value = 1;
			var lastNode:GainNode = output;
			for (n in inputs) {
				var gain = ctx.createGain();
				lastNode.gain.value = 0;
				gain.connectSafe(lastNode.gain);
				nodes.push(gain);
				lastNode = gain;
				n.connectSafe(lastNode);
			}
		} else {
			const.gain.value = 0;
			output.gain.value = 1;
			for (n in inputs) {
				n.connectSafe(output);
			}
		}
	}
}

private class ConstNode {
	public static function make(ctx:AudioContext, x:Float = 1.0):GainNode {
		var buf = ctx.createBuffer(1, 256, ctx.sampleRate);
		buf.getChannelData(0).fill(1);
		var one = ctx.createBufferSource();
		one.buffer = buf;
		one.loop = true;
		one.start();
		var gain = ctx.createGain();
		one.connectSafe(gain);
		gain.gain.value = x;
		return gain;
	}
}

class WebAudioCompiler implements GraphListener {
	var ctx:AudioContext;
	var suspended:Bool;
	var nodeMap:Map<Int, NodeData> = new Map();
	var socketMap:Map<Int, SocketData> = new Map();
	var dest:AudioNode;
	var masterGain:GainNode;
	var analyzer:AnalyserNode;
	var startedOnce:Bool;
	var lastFrequency:Float;

	public function new() {
		ctx = untyped __js__("new (window.AudioContext || window.webkitAudioContext)()");
		ctx.suspend();

		var compressor = ctx.createDynamicsCompressor();
		var saturator = ctx.createScriptProcessor(1024);
		saturator.addEventListener("audioprocess", function(e:AudioProcessingEvent):Void {
			var inL = e.inputBuffer.getChannelData(0);
			var inR = e.inputBuffer.getChannelData(1);
			var outL = e.outputBuffer.getChannelData(0);
			var outR = e.outputBuffer.getChannelData(1);
			inline function saturate(x:Float):Float {
				return Math.isNaN(x) ? 0 : x < -1 ? -1 : x > 1 ? 1 : x;
			}
			for (i in 0...1024) {
				outL[i] = saturate(inL[i]);
				outR[i] = saturate(inR[i]);
			}
		});
		masterGain = ctx.createGain();
		masterGain.gain.value = 0.0;
		var hiddenGain = ctx.createGain();
		hiddenGain.gain.value = 0.8;
		compressor.connectSafe(saturator);
		saturator.connectSafe(masterGain);
		masterGain.connectSafe(hiddenGain);
		hiddenGain.connectSafe(ctx.destination);
		dest = saturator;

		analyzer = ctx.createAnalyser();
		masterGain.connectSafe(analyzer);

		startedOnce = false;
		suspended = true;
		lastFrequency = 0;
	}

	function playStartSound():Void {
		var oscs = [
			ctx.createOscillator(),
			ctx.createOscillator(),
			ctx.createOscillator(),
			ctx.createOscillator()
		];
		oscs[0].type = SQUARE;
		oscs[1].type = SQUARE;
		oscs[2].type = SAWTOOTH;
		oscs[3].type = SAWTOOTH;
		oscs[0].frequency.value = 220;
		oscs[1].frequency.value = 220 * (1 + 1 / 3);
		oscs[2].frequency.value = 220 * (1 + 2 / 3);
		oscs[3].frequency.value = 440;
		var gain = ctx.createGain();
		for (osc in oscs) {
			osc.connect(gain);
			osc.start();
		}
		var time = ctx.currentTime;
		gain.gain.setValueAtTime(0, time);
		gain.gain.linearRampToValueAtTime(0.5, time + 1.0);
		gain.gain.linearRampToValueAtTime(0, time + 2.0);
		var compl = ctx.createDynamicsCompressor();
		gain.connect(compl);
		compl.connect(ctx.destination);
		compl.connect(analyzer);
	}

	public function start() {
		if (suspended) {
			var time = ctx.currentTime;
			var gain = masterGain.gain;
			if (!startedOnce) {
				startedOnce = true;

				ctx.resume();
				playStartSound();

				gain.setValueAtTime(0, time);
				gain.linearRampToValueAtTime(0, time + 1.5);
				gain.linearRampToValueAtTime(1, time + 2.0);
			} else {
				gain.setValueAtTime(gain.value, time);
				gain.linearRampToValueAtTime(1, time + 0.01);
			}
			suspended = false;
		}
	}

	public function stop():Void {
		if (!suspended) {
			var time = ctx.currentTime;
			var gain = masterGain.gain;
			gain.setValueAtTime(gain.value, time);
			gain.linearRampToValueAtTime(0, time + 0.01);
			suspended = true;
		}
	}

	public function attack():Void {
		for (n in nodeMap) {
			switch (n.setting.role) {
				case Envelope(env):
					var gain = cast(getNodeOf(n.id), GainNode).gain;
					var time = ctx.currentTime;
					gain.cancelScheduledValues(time);
					gain.setValueAtTime(gain.value, time);
					gain.linearRampToValueAtTime(1, time + env.a);
					gain.linearRampToValueAtTime(env.s, time + env.a + env.d);
				case _:
			}
		}
	}

	public function release():Void {
		for (n in nodeMap) {
			switch (n.setting.role) {
				case Envelope(env):
					var gain = cast(getNodeOf(n.id), GainNode).gain;
					var time = ctx.currentTime;
					gain.cancelScheduledValues(time);
					gain.setValueAtTime(gain.value, time);
					gain.linearRampToValueAtTime(0, time + env.r);
				case _:
			}
		}
	}

	public function setFrequency(f:Float, t:Float):Void {
		lastFrequency = f;
		for (n in nodeMap) {
			switch (n.setting.role) {
				case Frequency:
					var gain = cast(getNodeOf(n.id), GainNode).gain;
					var time = ctx.currentTime;
					gain.cancelScheduledValues(time);
					gain.setValueAtTime(gain.value, time);
					gain.linearRampToValueAtTime(f, time + t);
				case _:
			}
		}
	}

	public function onNodeCreated(id:Int, setting:NodeSetting):Void {
		trace("node created: " + id);
		var target:NodeTarget = switch (setting.role) {
			case Frequency:
				Node(ConstNode.make(ctx, lastFrequency));
			case Number(num):
				Node(ConstNode.make(ctx, num.value));
			case Dupl:
				MultiNode(new MultiNode(ctx, false));
			case BinOp(type):
				MultiNode(new MultiNode(ctx, switch (type) {
					case Add: false;
					case Mult: true;
				}));
			case Oscillator(type):
				var osc = ctx.createOscillator();
				osc.start();
				osc.type = switch (type) {
					case Sine: SINE;
					case Sawtooth: SAWTOOTH;
					case Square: SQUARE;
					case Triangle: TRIANGLE;
				}
				Node(osc);
			case Delay:
				Node(ctx.createDelay(5));
			case Envelope(_):
				Node(ConstNode.make(ctx, 0));
			case Destination:
				Node(dest);
			case Filter(type):
				var bq = ctx.createBiquadFilter();
				bq.type = switch (type) {
					case LowPass: LOWPASS;
					case HighPass: HIGHPASS;
					case BandPass: BANDPASS;
					case BandStop: NOTCH;
					case LowShelf: LOWSHELF;
					case HighShelf: HIGHSHELF;
					case Peak: PEAKING;
				};
				Node(bq);
			case Compressor:
				Node(ctx.createDynamicsCompressor());
			case None:
				throw "this should not be created";
		}
		nodeMap[id] = new NodeData(id, setting, target);
	}

	public function onNodeDestroyed(id:Int):Void {
		trace("node destroyed: " + id);
		nodeMap.remove(id);
	}

	function getNodeOf(id:Int):Any {
		return switch (nodeMap[id].target) {
			case Node(n): return n;
			case MultiNode(n): return n;
		};
	}

	public function onSocketCreated(id:Int, nodeId:Int, type:SocketType):Void {
		trace("socket created: " + id);
		var node = nodeMap[nodeId];
		var target:SocketTarget = switch (type) {
			case Normal(I):
				Node(node.target);
			case Normal(O):
				var terminal = ctx.createGain();
				switch (node.target) {
					case Node(n): n.connectSafe(terminal);
					case MultiNode(n): n.output.connectSafe(terminal);
				}
				Node(Node(terminal));
			case Param(I, name):
				Param(switch (node.setting.role) {
					case Oscillator(_):
						var osc = cast(getNodeOf(nodeId), OscillatorNode);
						switch (name) {
							case "freq":
								osc.frequency;
							case "detune":
								osc.detune;
							case _:
								throw "!?";
						}
					case Delay:
						var del = cast(getNodeOf(nodeId), DelayNode);
						switch (name) {
							case "time":
								del.delayTime;
							case _:
								throw "!?";
						}
					case Filter(_):
						var bq = cast(getNodeOf(nodeId), BiquadFilterNode);
						switch (name) {
							case "freq":
								bq.frequency;
							case "Q":
								bq.Q;
							case "gain":
								bq.gain;
							case _:
								throw "!?";
						}
					case _:
						throw "not implemented yet";
				});
			case Param(O, _):
				throw "output param not supported";
			case Module(_):
				throw "this should never happen";
		}
		socketMap[id] = new SocketData(id, nodeId, type, target);
	}

	public function onSocketDestroyed(id:Int):Void {
		trace("socket destroyed: " + id);
		var s = socketMap[id];
		if (s.type.match(Normal(O))) {
			var terminal = switch (s.target) {
				case Node(n): switch (n) {
						case Node(n): n;
						case _: throw "!?";
					}
				case _: throw "!?";
			}
			switch (nodeMap[s.nodeId].target) {
				case Node(n):
					n.disconnectSafe(terminal);
				case MultiNode(n):
					n.output.connectSafe(terminal);
			}
		}
		socketMap.remove(id);
	}

	public function onSocketConnected(id1:Int, id2:Int):Void {
		trace("connected: " + id1 + "->" + id2);
		var s1 = socketMap[id1];
		var s2 = socketMap[id2];
		switch (s1.target) {
			case Node(nt):
				switch (nt) {
					case Node(n):
						switch (s2.target) {
							case Node(nt2):
								switch (nt2) {
									case Node(n2):
										n.connectSafe(n2);
									case MultiNode(n2):
										n2.connectInput(n);
								}
							case Param(p2):
								n.connectSafe(p2);
								p2.value = 0;
						}
					case MultiNode(_):
						throw "cannot connect directly from multinode";
				}
			case Param(_):
				throw "cannot connect from param";
		}
	}

	public function onSocketDisconnected(id1:Int, id2:Int):Void {
		trace("disconnected: " + id1 + "->" + id2);
		var s1 = socketMap[id1];
		var s2 = socketMap[id2];
		switch (s1.target) {
			case Node(nt):
				switch (nt) {
					case Node(n):
						switch (s2.target) {
							case Node(nt2):
								switch (nt2) {
									case Node(n2):
										n.disconnectSafe(n2);
									case MultiNode(n2):
										n2.disconnectInput(n);
								}
							case Param(p2):
								n.disconnectSafe(p2);
								p2.value = p2.defaultValue;
						}
					case MultiNode(_):
						throw "cannot disconnect directly from multinode";
				}
			case Param(_):
				throw "cannot disconnect from param";
		}
	}

	public function onNodeUpdated(id:Int):Void {
		var n = nodeMap[id];
		switch (n.setting.role) {
			case Number(num):
				var gain = cast(getNodeOf(id), GainNode);
				gain.gain.value = num.value;
			case Oscillator(type):
				var osc = cast(getNodeOf(id), OscillatorNode);
				osc.type = switch (type) {
					case Sine: SINE;
					case Sawtooth: SAWTOOTH;
					case Square: SQUARE;
					case Triangle: TRIANGLE;
				}
			case BinOp(type):
				var multi = cast(getNodeOf(id), MultiNode);
				multi.mul = switch (type) {
					case Add: false;
					case Mult: true;
				};
				multi.updateInputs();
			case _:
		}
	}

	final waveDataBuffer:Float32Array = new Float32Array(1024);

	public function onWaveDataRequest(outArray:Array<Float>):Void {
		if (suspended) {
			return;
		}

		var outSize = 256;

		analyzer.getFloatTimeDomainData(waveDataBuffer);
		for (i in 0...outSize) {
			outArray.push(waveDataBuffer[i]);
		}
	}
}
