Engine_GendyTutorial : CroneEngine {
  var rez_x=100, rez_y=0.5, fill=50;
  var <synth;
	
  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    SynthDef(\GendyTutorial, {|inL, inR, out, rez_x=100, rez_y=0.5|
      var sound = {
        Resonz.ar( 
          Mix.fill(fill, { 
            var freq=rrand(50,560.3); 
            var numcps= rrand(2,20);
            Pan2.ar(Gendy1.ar(6.rand,6.rand,1.0.rand,1.0.rand,freq ,freq, 1.0.rand, 1.0.rand, numcps, SinOsc.kr(exprand(0.02,0.2), 0, numcps/2, numcps/2), 0.5/(fill.sqrt)), 1.0.rand2) 
          }),
          rez_x, 
          rez_y
        ); 
      };
      
      Out.ar(out, sound);
    }).add;

    context.server.sync;

    synth = Synth.new(\GendyTutorial, [
      \inL, context.in_b[0].index,			
      \inR, context.in_b[1].index,
      \out, context.out_b.index,
      \rez_x, 100,
      \rez_y, 0.5],
    context.xg);

    this.addCommand("x", "i", {|msg|
      synth.set(\rez_x, msg[1]);
    });
    
    this.addCommand("y", "f", {|msg|
      synth.set(\rez_y, msg[1]);
    }); 
  }

  free {
    synth.free;
  }
}