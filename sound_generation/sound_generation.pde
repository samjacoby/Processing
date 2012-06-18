import ddf.minim.* ;
import ddf.minim.signals.*;
import ddf.minim.effects.*;

Minim minim;
AudioOutput au_out;
SquareWave sqw;
LowPassSP lpass;



float[] notes;
int counter = 0;

void setup() {
  minim = new Minim(this);
  au_out = minim.getLineOut();
  sqw = new SquareWave(440, 1, 44100);
  lpass = new LowPassSP(200, 44100);
  au_out.addSignal(sqw);
  au_out.addEffect(lpass);
  
  notes = new float[8];
  notes[0] = 261.63 ;
  notes[1] = 293.67 ;
  notes[2] = 329.63 ;
  notes[3] = 349.23 ;
  notes[4] = 391.99 ;
  notes[5] = 440 ;
  notes[6] = 493.88 ;
  notes[7] = 523.25 ;
  counter = 0 ;
  frameRate(1) ;    // slow it down so each pitch is held for 1 second

}

void draw() {
  
  sqw.setFreq(notes[counter]);
  counter++ ;
  if (counter >= 7)
    counter = 0 ;
}
