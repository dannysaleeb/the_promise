// tuning
s.boot

// In/Out
(
Server.default.options.inDevice_("Macbook Pro Microphone");
Server.default.options.outDevice_("External Headphones");
)

// function to build the tuning_system
(
~makeTuning = {
	arg fund=31.midicps;
	var tuning_system, stack_one;
	tuning_system = Dictionary.new(4);
	tuning_system.put(\0, [fund]);

	// insert fifths above fundamental in original stack within tuning system
	3.do({
		arg num;
		tuning_system[\0] = tuning_system[\0].add((tuning_system[\0][tuning_system[\0].size - 1] * 3) / 2)
	});

	// add two more stacks based on that one and each subsequent stack
	2.do({
		arg num;
		tuning_system.put((num + 1).asSymbol, (tuning_system[(num).asSymbol] * 5) / 4);
	});
	tuning_system
}
)

// earth music instrument
(
SynthDef(\earth,
	{
		arg outbus = 0, freq = 100, amp = 0.5, att = 0.5, rel=0.5, frameSize = 3, envSize = 0.75, t_gate = 1.0;
		var out = 0, vol=0.6;
		// Could sculpt the signal so that it's more interesting ...
		var sig = SinOsc.ar(freq);
		// The envelope on the output ...
		out = EnvGen.ar(
			//
			Env.new([0,1,0], [(\dur.ir(1) * \stretch.ir(1) * envSize * att), (\dur.ir(1) * \stretch.ir(1) * envSize * rel)], curve: \sin),
			gate: t_gate,
			doneAction: 2
		) * amp * sig * vol;
		Out.ar(outbus, out);
	}
).add
)

// Seed instrument YAY
(
SynthDef(\earthseed,
	{
		arg outbus = 0, freq = 100, amp = 0.5, att = 0.5, rel=0.5, frameSize = 3, envSize = 0.75, t_gate = 1.0;
		var out = 0, vol=0.6;
		// Could sculpt the signal so that it's more interesting ...
		var sig = SinOsc.ar(freq);
		// The envelope on the output ...
		out = EnvGen.ar(
			//
			Env.new([0,1,0], [(\dur.ir(1) * \stretch.ir(1) * envSize * att), (\dur.ir(1) * \stretch.ir(1) * envSize * rel)], curve: \sin),
			gate: t_gate,
			doneAction: 2
		) * Dust.ar(12) * sig * vol;
		Out.ar(outbus, RLPF.ar(out, freq, 0.01));
	}
).add
)

(
SynthDef(\earthseedsuck,
	{
		arg outbus = 0, freq = 100, amp = 0.5, att = 0.5, rel=0.5, frameSize = 3, envSize = 0.75, t_gate = 1.0;
		var out = 0, vol=0.6;
		// Could sculpt the signal so that it's more interesting ...
		var sig = SinOsc.ar(Line.ar(freq, freq / 8, 20));
		// The envelope on the output ...
		out = EnvGen.ar(
			//
			Env.new([0,1,0], [(\dur.ir(1) * \stretch.ir(1) * envSize * att), (\dur.ir(1) * \stretch.ir(1) * envSize * rel)], curve: \sin),
			gate: t_gate,
			doneAction: 2
		) * Dust.ar(12) * sig * vol;
		Out.ar(outbus, RLPF.ar(out, Line.ar(freq, freq / 8, 20), 0.01));
	}
).add
)

(
// Earth music playback
~stretch_1 = 1;
~stretch_2 = 1;
~stretch_3 = 1;
~stretch_4 = 1;
~stretch_5 = 1;
~stretch_6 = 1;
~dur = 4;
~envSize = 0.75;

p = Pbindef(
	\p,
	\instrument, \earth,
	\freq, Pfunc{~tuning_system[\0][0]},
	\amp, 0.8,
	\dur, Pfunc({ ~dur }),
	\stretch, 1,
	\envSize, Pfunc({ ~envSize }),
	\att, 0.2,
	\rel, 0.8,
	\outbus, 50,
).play(TempoClock(62/60));

q = Pbindef(
	\q,
	\instrument, \earth,
	\freq, Pfunc{~tuning_system[\0][1]},
	\amp, 0.4,
	\dur, Pfunc({ ~dur }),
	\stretch, 1,
	\envSize, Pfunc({ ~envSize }),
	\att, 0.2,
	\rel, 0.8,
	\outbus, 51,
).play(TempoClock(62/60));

r =  Pbindef(
	\r,
	\instrument, \earth,
	\freq, Pfunc{~tuning_system[\1][0] * 2},
	\amp, 0.2,
	\dur, Pfunc({ ~dur }),
	\stretch, 1,
	\envSize, Pfunc({ ~envSize }),
	\att, 0.2,
	\rel, 0.8,
	\outbus, 52,
).play(TempoClock(62/60));

t = Pbindef(
	\t,
	\instrument, \earth,
	\freq, Pfunc{~tuning_system[\0][0] * 4},
	\amp, 0.1,
	\dur, Pfunc({ ~dur }),
	\stretch, 1,
	\envSize, Pfunc({ ~envSize }),
	\att, 0.2,
	\rel, 0.8,
	\outbus, 53,
).play(TempoClock(62/60));

u = Pbindef(
	\u,
	\instrument, \earth,
	\freq, Pfunc{~tuning_system[\2][1]},
	\amp, 0.05,
	\dur, Pfunc({ ~dur }),
	\stretch, 1,
	\envSize, Pfunc({ ~envSize }),
	\att, 0.2,
	\rel, 0.8,
	\outbus, 54,
).play(TempoClock(62/60));

v = Pbindef(
	\v,
	\instrument, \earth,
	\freq, Pfunc{~tuning_system[\2][3]},
	\amp, 0.025,
	\dur, Pfunc({ ~dur }),
	\stretch, 1,
	\envSize, Pfunc({ ~envSize }),
	\att, 0.2,
	\rel, 0.8,
	\outbus, 55,
).play(TempoClock(62/60));

z = Monitor.new;
z.play(fromIndex: 50, fromNumChannels: 6, toIndex: 0, toNumChannels: 2);

// RECORD
/*~rec_duration = nil;
~stereo_rec.record(bus: 0, duration: ~rec_duration);
~multitrack_1_rec.record(bus: 50, duration: ~rec_duration);
~multitrack_2_rec.record(bus: 51,  duration: ~rec_duration);
~multitrack_3_rec.record(bus: 52, duration: ~rec_duration);
~multitrack_4_rec.record(bus: 53, duration: ~rec_duration);
~multitrack_5_rec.record(bus: 54, duration: ~rec_duration);
~multitrack_6_rec.record(bus: 55, duration: ~rec_duration);*/
)

// Now get the frequency to dip down to meet the earth ...
// It dips, but now the frequency values also need to dip in the Pbindefs... so make Pseq.

(
// SEEDS music playback
~stretch_1 = 1;
~stretch_2 = 1;
~stretch_3 = 1;
~stretch_4 = 1;
~stretch_5 = 1;
~stretch_6 = 1;
~dur = 4;
~envSize = 0.75;

~freq_mul = 8;

p = Pbindef(
	\p,
	\instrument, \earthseedsuck,
	\freq, Pfunc{(~tuning_system[\0][0]) * ~freq_mul},
	\amp, 0.8,
	\dur, Pfunc({ ~dur }),
	\stretch, 1,
	\envSize, Pfunc({ ~envSize }),
	\att, 0.2,
	\rel, 0.8,
	\outbus, 50,
).play(TempoClock(62/60));

q = Pbindef(
	\q,
	\instrument, \earthseedsuck,
	\freq, Pfunc{(~tuning_system[\0][1]) * ~freq_mul},
	\amp, 0.4,
	\dur, Pfunc({ ~dur }),
	\stretch, 1,
	\envSize, Pfunc({ ~envSize }),
	\att, 0.2,
	\rel, 0.8,
	\outbus, 51,
).play(TempoClock(62/60));

r =  Pbindef(
	\r,
	\instrument, \earthseedsuck,
	\freq, Pfunc{(~tuning_system[\1][0] * 2) * ~freq_mul},
	\amp, 0.2,
	\dur, Pfunc({ ~dur }),
	\stretch, 1,
	\envSize, Pfunc({ ~envSize }),
	\att, 0.2,
	\rel, 0.8,
	\outbus, 52,
).play(TempoClock(62/60));

t = Pbindef(
	\t,
	\instrument, \earthseedsuck,
	\freq, Pfunc{(~tuning_system[\0][0] * 4) * ~freq_mul},
	\amp, 0.1,
	\dur, Pfunc({ ~dur }),
	\stretch, 1,
	\envSize, Pfunc({ ~envSize }),
	\att, 0.2,
	\rel, 0.8,
	\outbus, 53,
).play(TempoClock(62/60));

u = Pbindef(
	\u,
	\instrument, \earthseedsuck,
	\freq, Pfunc{(~tuning_system[\2][1]) * ~freq_mul},
	\amp, 0.05,
	\dur, Pfunc({ ~dur }),
	\stretch, 1,
	\envSize, Pfunc({ ~envSize }),
	\att, 0.2,
	\rel, 0.8,
	\outbus, 54,
).play(TempoClock(62/60));

v = Pbindef(
	\v,
	\instrument, \earthseedsuck,
	\freq, Pfunc{(~tuning_system[\2][3]) * ~freq_mul},
	\amp, 0.025,
	\dur, Pfunc({ ~dur }),
	\stretch, 1,
	\envSize, Pfunc({ ~envSize }),
	\att, 0.2,
	\rel, 0.8,
	\outbus, 55,
).play(TempoClock(62/60));

z = Monitor.new;
z.play(fromIndex: 50, fromNumChannels: 6, toIndex: 0, toNumChannels: 2);

// RECORD
/*~rec_duration = nil;
~stereo_rec.record(bus: 0, duration: ~rec_duration);
~multitrack_1_rec.record(bus: 50, duration: ~rec_duration);
~multitrack_2_rec.record(bus: 51,  duration: ~rec_duration);
~multitrack_3_rec.record(bus: 52, duration: ~rec_duration);
~multitrack_4_rec.record(bus: 53, duration: ~rec_duration);
~multitrack_5_rec.record(bus: 54, duration: ~rec_duration);
~multitrack_6_rec.record(bus: 55, duration: ~rec_duration);*/
)
// STOP ALL Pbinds
// F: 29 (41); Bb: 34; Eb: 39
// Ab: 32; Db: 37; F#: 30; B: 35
// E: 28; A: 33;
(
[p, q, r, t, u, v].do({
	arg item;
	item.stop
})
)

// LIVE CONTROLS
~tuning_system = ~makeTuning.value(31.midicps)
Pbindef(\v, \stretch, 1.01);
Pbindef(\u, \stretch, 0.98);
Pbindef(\p, \stretch, 1.05);
Pbindef(\q, \stretch, 1.1);
Pbindef(\r, \stretch, 1.2);
Pbindef(\t, \stretch, 0.9);
~envSize = 0.75;
~dur = 4;

Pbindef(\v, \stretch, 1);
Pbindef(\u, \stretch, 1);
Pbindef(\p, \stretch, 1);
Pbindef(\q, \stretch, 1);
Pbindef(\r, \stretch, 1);
Pbindef(\t, \stretch, 1);

// STOP ALL Pbinds
(
[p, q, r, t, u, v].do({
	arg item;
	item.stop
});
~tuning_system = ~makeTuning.value(36.midicps)
)
s.stopRecording
s.boot

(
// PREPARE FOR RECORD
~stereo_rec = Recorder.new(s);
~multitrack_1_rec = Recorder.new(s);
~multitrack_2_rec = Recorder.new(s);
~multitrack_3_rec = Recorder.new(s);
~multitrack_4_rec = Recorder.new(s);
~multitrack_5_rec = Recorder.new(s);
~multitrack_6_rec = Recorder.new(s);

~movement = "seedsuck";
~set = "all";

// Desktop record preparation
/*~stereo_rec.prepareForRecord("/Users/DanielSaleeb/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_stereo.wav", 2);
~multitrack_1_rec.prepareForRecord("/Users/DanielSaleeb/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_1.wav", 1);
~multitrack_2_rec.prepareForRecord("/Users/DanielSaleeb/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_2.wav", 1);
~multitrack_3_rec.prepareForRecord("/Users/DanielSaleeb/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_3.wav", 1);
~multitrack_4_rec.prepareForRecord("/Users/DanielSaleeb/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_4.wav", 1);
~multitrack_5_rec.prepareForRecord("/Users/DanielSaleeb/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_5.wav", 1);
~multitrack_6_rec.prepareForRecord("/Users/DanielSaleeb/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_6.wav", 1)*/

// Macbook Record Preparation
~stereo_rec.prepareForRecord("/Users/dannysaleeb/Library/CloudStorage/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_stereo.wav", 2);
~multitrack_1_rec.prepareForRecord("/Users/dannysaleeb/Library/CloudStorage/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_1.wav", 1);
~multitrack_2_rec.prepareForRecord("/Users/dannysaleeb/Library/CloudStorage/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_2.wav", 1);
~multitrack_3_rec.prepareForRecord("/Users/dannysaleeb/Library/CloudStorage/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_3.wav", 1);
~multitrack_4_rec.prepareForRecord("/Users/dannysaleeb/Library/CloudStorage/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_4.wav", 1);
~multitrack_5_rec.prepareForRecord("/Users/dannysaleeb/Library/CloudStorage/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_5.wav", 1);
~multitrack_6_rec.prepareForRecord("/Users/dannysaleeb/Library/CloudStorage/Dropbox/universe/work/The Promise/audio/Promise July Audio/Earth" +/+ ~movement +/+ "_6.wav", 1)
)

s.stopRecording;

// how do I speed it up and slow it down though? dur needs to be relative to the tempo ...

// I need to modulate such that the seeds are very bunched up and jittery -- they become more resonant and more spaced out as they get to the planting location ... then they are sucked into earth, and pitch ideally descends ... ?? So line down to lowest pitch ...

{SinOsc.ar(Line.ar(440, 110, 20, doneAction: 0), mul: 0.4)}.play;

s.reboot