import ddf.minim.* ;
import ddf.minim.signals.* ;
import ddf.minim.effects.* ;

Minim minim;
AudioOutput au_out ;
SquareWave sqw ;
LowPassSP lpass ;

void setup() {

  size(400,600) ;
  minim = new Minim(this) ;
  au_out = minim.getLineOut() ;

  
  // create a SquareWave with a frequency of 440 Hz, 
  // an amplitude of 1 and the same sample rate as out

  sqw = new SquareWave(440, 1, 44100);

  // create a LowPassSP ﬁlter with a cutoff frequency of 200 Hz 
  // that expects audio with the same sample rate as out

  lpass = new LowPassSP(200, 44100);

  // now we can attach the square wave and the ﬁlter to our output

  au_out.addSignal(sqw);
  au_out.addEffect(lpass);

}

void stop() {
  super.stop() ;
}

void draw() {
  sqw.setFreq(mouseY);
}

void keyPressed() {

  if ( key == 'm' ) {

    if ( au_out.isMuted() )

    {

      au_out.unmute();

    } else {
      au_out.mute();
    }
  }
}
