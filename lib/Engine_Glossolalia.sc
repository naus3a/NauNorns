Engine_Glossolalia : CroneEngine {
  var amp = 1;
  var <>formantIdx = 0;
  var <synth;
  
  *new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}
	
	alloc{
	  SynthDef(\Glossolalia, {
	    |inL, inR, out, amp=1, formantIdx=0|
	    
	    var fFreq = [
        [600,1040,2250,2450,2750], 
        [400,1620,2400,2800,3100],
        [250,1750,2600,3050,3340],
        [400,750,2400,2600,2900],
        [350,600,2400,2675,2950]
      ];
      var fAmps = [
        ([0 ,-7,-9,-9,-20]-6).dbamp,
        ([0 ,-12,-9,-12,-18]-6).dbamp,
        ([0 ,-30,-16,-22,-28]-6).dbamp,
        ([0 ,-11,-21,-20,-40]-6).dbamp,
        ([0 ,-20,-32,-28,-36]-6).dbamp
      ];
      var fBw = [
        [60,70,110,120,130],
        [40,80,100,120,120],
        [60,90,100,120,120],
        [40,80,100,120,120],
        [40,80,100,120,120]
      ];
      
      var carrier = WhiteNoise.ar();
      
      var fIdx = 0;
      
	    var sig = BPF.ar(carrier, fFreq[fIdx], fBw[fIdx]/fFreq[fIdx], fAmps[fIdx]);
	    sig = sig*amp;
	    
	    Out.ar(out, (sig).dup);
	  }).add;
	  
	  context.server.sync;
	  
	  synth = Synth.new(\Glossolalia, [
	          \inL, context.in_b[0].index,			
			      \inR, context.in_b[1].index,
			      \out, context.out_b.index,
			      \amp, 1,
			      \formantIdx, 0],
	          context.xg);
	          
	  this.addCommand("amp", "f", {|msg|
			synth.set(\amp, msg[1]);
		});
		
		this.addCommand("formantIdx", "i", {|msg|
			synth.set(\formantIdx, msg[1]);
		});
	}
	
	free{
	  synth.free;
	}
}