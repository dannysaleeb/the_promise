// The model
play({SinOsc.ar(110) * RLPF.ar(Dust.ar([12,15]), LFNoise0.ar(1/[3,4], 1500, 1600), 0.02)});

// Seed instrument
(
SynthDef(\seed,
	{
		arg out = 0, freq1 = 440, freq2 = 880, freq3 = 220, freq4 = 110, freq5 = 660, freq6 = 770, dust_freq1 = 12, dust_freq2 = 15, dust_freq3 = 13, dust_freq4 = 11, dust_freq5 = 14, dust_freq6 = 10, dur1 = 2, dur2 = 4, dur3=3, dur4=1.5, dur5=2.5, dur6=3.5, rq = 0.01;
		var sig, env;
		sig = RLPF.ar(Dust.ar([dust_freq1, dust_freq2, dust_freq3, dust_freq4, dust_freq5, dust_freq6]), [freq1, freq2, freq3, freq4, freq5, freq6], rq);
		env = EnvGen.ar(Env.new([0,1,0], [0.01, [dur1, dur2, dur3, dur4, dur5, dur6], 0.01]), doneAction: Done.freeSelf);
		out = Splay(Out.ar(out, sig * env))
	}
).add
)

(
SynthDef(\earthseed,
	{
		arg out = 0, freq1 = 440, freq2 = 880, freq3 = 220, freq4 = 110, freq5 = 660, freq6 = 770, dust_freq1 = 12, dust_freq2 = 15, dust_freq3 = 13, dust_freq4 = 11, dust_freq5 = 14, dust_freq6 = 10, dur1 = 2, dur2 = 4, dur3=3, dur4=1.5, dur5=2.5, dur6=3.5, rq = 0.01;
		var sig, env;
		sig = RLPF.ar(Dust.ar([dust_freq1, dust_freq2, dust_freq3, dust_freq4, dust_freq5, dust_freq6]), [freq1, freq2, freq3, freq4, freq5, freq6], rq) * SinOsc.ar([freq1, freq2, freq3, freq4, freq5, freq6]);
		env = EnvGen.ar(Env.new([0,1,0], [0.01, [dur1, dur2, dur3, dur4, dur5, dur6], 0.01]), doneAction: Done.freeSelf);
		out = Splay(Out.ar(out, sig * env))
	}
).add
)

// Earth music instrument
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

// Function to build tuning
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

// Choose fundamental and build tuning
(
~fund = 38;
~tuning_system = ~makeTuning.value(~fund.midicps);
~freqs = ~tuning_system[\0]
)

// Maybe it would be better to have a synth that is somehow choosing notes from the freqs dict? Ask Federico...

// RUN SEED
(
var rq_vals_size = 20;
~rq_mod = Pgeom(0.15, 0.85, rq_vals_size).postln;
~rq_mod_list = ~rq_mod.asStream.all.postln;
~rq_mod_last_val = ~rq_mod_list[rq_vals_size - 1].postln;
// decrease dust_freq combined with dur to space out seeds
Pbindef(
	\seed_1,
	\instrument, \seed,
	\dust_freq1, 12,
	\dust_freq2, 15,
	\dust_freq3, 14,
	\dust_freq4, 13,
	\dust_freq5, 11,
	\dust_freq6, 10,
	\freq1, ~freqs[0] * 8,
	\freq2, ~freqs[1] * 8,
	\freq3, ~freqs[2] * 8,
	\freq4, ~freqs[3] * 8,
	\freq5, ~freqs[2] * 8,
	\freq6, ~freqs[1] * 8,
	\dur1, 2,
	\dur2, 3,
	\dur3, 2.5,
	\dur4, 3.5,
	\dur5, 1.5,
	\dur6, 1,
	\dur, 1,
	\rq, Pseq([~rq_mod, Pseq([~rq_mod_last_val], inf)], 1)
).play;
)

(
var rq_vals_size = 20;
~rq_mod = Pgeom(0.15, 0.85, rq_vals_size).postln;
~rq_mod_list = ~rq_mod.asStream.all.postln;
~rq_mod_last_val = ~rq_mod_list[rq_vals_size - 1].postln;
// decrease dust_freq combined with dur to space out seeds
Pbindef(
	\seed_1_eaten,
	\instrument, \earthseed,
	\dust_freq1, 12,
	\dust_freq2, 15,
	\dust_freq3, 14,
	\dust_freq4, 13,
	\dust_freq5, 11,
	\dust_freq6, 10,
	\freq1, ~freqs[0] * 8,
	\freq2, ~freqs[1] * 8,
	\freq3, ~freqs[2] * 8,
	\freq4, ~freqs[3] * 8,
	\freq5, ~freqs[2] * 8,
	\freq6, ~freqs[1] * 8,
	\dur1, 2,
	\dur2, 3,
	\dur3, 2.5,
	\dur4, 3.5,
	\dur5, 1.5,
	\dur6, 1,
	\dur, 1,
	\rq, Pseq([~rq_mod, Pseq([~rq_mod_last_val], inf)], 1)
).play;
)

// I want to decrease the frequency in a line ... server-wise ...

(
{
	var a, freq, trig;
	a = Drand(~freqs, inf);
	trig = Impulse.kr(4);
	freq = Demand.kr(trig, 0, a) * 2;
	SinOsc.ar(freq) * 0.1
}.play
)

Pgeom(0.15, 0.9, 20).asStream.all;
