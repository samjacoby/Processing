import ddf.minim.* ;
import ddf.minim.signals.*;
import ddf.minim.effects.*;
import processing.serial.*;

/*
 * This code was developed by Kanjuan Qui <kanjun@mit.edu>
 *
 *
 * Later modified by Sam Jacoby <sjacoby@media.mit.edu> for use
 * at CS4HS Chicago 2012. 
 */ 

Minim minim;
AudioOutput out;
Serial myPort;

SineWave mSine;
MyNote mNote;

// http://www.phy.mtu.edu/~suits/notefreqs.html


void setup() {
  
  // declare size of drawing field
  size(512, 200, P3D);
  // print a list of available serial ports (useful for debugging conneciton problems)
  println(Serial.list());
  // open new serial conneciton on the selected connection
  myPort = new Serial(this, Serial.list()[0], 9600);
  // don't do anything until you see a <newline>, that is, this fellow '\n'
  myPort.bufferUntil('\n');
  
  // declare an instance of the audio library
  minim = new Minim(this);
  // and an audio output (the library is not smart enough to know _where_ we want to send the sound. 
  // we tell it here.
  out = minim.getLineOut(Minim.STEREO);
  
}

void draw() {
  background(0);
  stroke(255);
  
  /* draw the output waveforms, 'cus they look fancy. This can be commented
   * out without any consequence whatsoever.
   *
   * this bit of code is courtesy of Kanjun Qiu <kanjun@mit.edu>
   */
   
  for(int i = 0; i < out.bufferSize() - 1; i++) {
    float x1 = map(i, 0, out.bufferSize(), 0, width);
    float x2 = map(i+1, 0, out.bufferSize(), 0, width);
    line(x1, 50 + out.left.get(i)*50, x2, 50 + out.left.get(i+1)*50);
    line(x1, 150 + out.right.get(i)*50, x2, 150 + out.right.get(i+1)*50);
  }
  
}


/* Out program doesn't really know what to do with a SerialEvent, so we tell it what 
 * to do here, by defining our own version of serialEvent. This is like telling our
 * system what to when its picking up the 'phone'.
 */
 void serialEvent(Serial myPort) {
   // we'll store the value of our note here
   float pitch = 0;
   // and here's our note.
   MyNote note;
   // get the ASCII string:
   String inString = myPort.readStringUntil('\n'); 
   if (inString != null) {   
     inString = trim(inString);
     pitch = float(inString);
     println(pitch);
     note = new MyNote(pitch, 0.3);
   
   }
 }
 
 /* Shutdown this show */
 void stop() {
  out.close();
  minim.stop();
  super.stop();
  exit();
 }
 

void keyPressed() {
  if ( key == 's' ) {
    stop();
  }
}
 

/* It's difficult to make a computer-generated sound that actually sounds _good_.
 * This sounds nice, because it generates a sine wave (which sounds good, unlike, say
 * a square wave or a triangle wave, which are naturally, square-er and triangl-er.)
 * 
 * Thanks to Kanjun again. 
 */

class MyNote implements AudioSignal
{
     private float freq;
     private float level;
     private float alph;
     private SineWave sine;
     
     MyNote(float pitch, float amplitude)
     {
         freq = pitch;
         level = amplitude;
         sine = new SineWave(freq, level, out.sampleRate());
         alph = .9;  // Decay constant for the envelope
         out.addSignal(this);
     }

     void updateLevel()
     {
         // Called once per buffer to decay the amplitude away
         level = level * alph;
         sine.setAmp(level);
         // This also handles stopping this oscillator when its level is very low.
         if (level < 0.01) {
             out.removeSignal(this);
         }
         // this will lead to destruction of the object, since the only active
         // reference to it is from the LineOut
     }

     void generate(float [] samp)
     {
         // generate the next buffer's worth of sinusoid
         sine.generate(samp);
         // decay the amplitude a little bit more
         updateLevel();
     }

    // AudioSignal requires both mono and stereo generate functions
    void generate(float [] sampL, float [] sampR)
    {
        sine.generate(sampL, sampR);
        updateLevel();
    }
}
