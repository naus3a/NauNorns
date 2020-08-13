Engine_ResDrone : CroneEngine {
  var <synth;
  
  *new { arg context, doneCallback;
          ^super.new(context, doneCallback);
  }
  
  alloc{
    synth = {
      arg out,
          fundFreq = 50,
          res1 = 4.5,
          res2 = 2.3,
          res3 = 1.9,
          res4 = 1.5,
          ns1 = 0.05,
          ns2 = 0.06,
          ns3 = 0.056,
          ns4 = 0.07,
          spread = 0,
          revMix = 0.33,
          revRoom = 0.5,
          revDamp = 0.5,
          delSec = 0.2;
      
      var det = fundFreq*spread;
      var drone1 = DFM1.ar(SinOsc.ar(fundFreq,0,0.1),
                            fundFreq*2,
                            LFNoise1.kr(ns1).range(0.9,res1),
                            1,0,0.0003,0.5);
      var drone2 = DFM1.ar(SinOsc.ar((fundFreq*2)+det,0,0.1),
                            (fundFreq*2*2)+det,
                            LFNoise1.kr(ns2).range(0.9,res2),
                            1,0,0.0003,0.5);
      var drone3 = DFM1.ar(SinOsc.ar((fundFreq*3)+det,0,0.1),
                            (fundFreq*2*3)+det,
                            LFNoise1.kr(ns3).range(0.9,res3),
                            1,0,0.0003,0.5);
      var drone4 = DFM1.ar(SinOsc.ar((fundFreq*4)+det,0,0.1),
                            (fundFreq*2*4)+det,
                            LFNoise1.kr(ns4).range(0.9,res4),
                            1,0,0.0003,0.5);
			var sig = drone1+drone2+drone3+drone4;
			sig = DelayL.kr(sig, 10, delSec, 1, sig);
			sig = FreeVerb.ar(sig, revMix, revRoom, revDamp);
			Out.ar(out, (sig).dup);
    }.play(args: [\out, context.out_b], target: context.xg);
    
    //commands
    
    this.addCommand("hz", "f", { arg msg;
			synth.set(\fundFreq, msg[1]);
		});
		
		this.addCommand("res1", "f", { arg msg;
			synth.set(\res1, msg[1]);
		});
		this.addCommand("res2", "f", { arg msg;
			synth.set(\res2, msg[1]);
		});
		this.addCommand("res3", "f", { arg msg;
			synth.set(\res3, msg[1]);
		});
		this.addCommand("res4", "f", { arg msg;
			synth.set(\res4, msg[1]);
		});
		
		this.addCommand("ns1", "f", { arg msg;
			synth.set(\ns1, msg[1]);
		});
		this.addCommand("ns2", "f", { arg msg;
			synth.set(\ns2, msg[1]);
		});
		this.addCommand("ns3", "f", { arg msg;
			synth.set(\ns3, msg[1]);
		});
		this.addCommand("ns4", "f", { arg msg;
			synth.set(\ns4, msg[1]);
		});
		
		this.addCommand("spread", "f", { arg msg;
		  synth.set(\spread, msg[1]);
		});
		
		this.addCommand("revMix", "f", { arg msg;
		  synth.set(\revMix, msg[1]);
		});
		this.addCommand("revRoom", "f", { arg msg;
		  synth.set(\revRoom, msg[1]);
		});
		this.addCommand("revDamp", "f", { arg msg;
		  synth.set(\revDamp, msg[1]);
		});
		
		this.addCommand("delSec", "f", { arg msg;
		  synth.set(\delSec, msg[1]);
		});
  }
  
  free{
    synth.free;
  }
}