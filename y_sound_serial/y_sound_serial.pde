/* Mostly Generic Make-Sound-From-Analog-Input
 * 
 * Reads in a bare number on the analog input and maps it 
 * to a sound for fun and profit.
 *
 * Prepared for CS4HS 2012, Chicago. 
 *
 * Sam Jacoby <sjacoby@media.mit.edu>
 *
 */


import ddf.minim.* ;
import ddf.minim.signals.* ;
import ddf.minim.effects.* ;
import processing.serial.*;

import java.util.regex.*;


Serial myPort;
Minim minim;
AudioOutput au_out ;
SineWave snw ;
LowPassSP lpass ;


void setup() {

  minim = new Minim(this) ;
  au_out = minim.getLineOut() ;
  
  myPort = new Serial(this, Serial.list()[0], 9600);
  myPort.bufferUntil('\n');
  
  // create a SquareWave with a frequency of 440 Hz, 
  // an amplitude of 1 and the same sample rate as out

  snw = new SineWave(440, 1, 44100);

  // now we can attach the square wave and the ﬁlter to our output
  au_out.addSignal(snw);
}

void stop() {
  super.stop() ;
}

void draw() {
  // just keep plugging along
}


/*
 * Validate input to make sure the serial port doesn't spit out anything unpleasant. 
 *
 */
 
private static final Pattern NUMBERS = Pattern.compile("\\d+");
boolean isNumeric(String text) {
        return Pattern.compile("\\d+").matcher(text).matches();
}

/*
 * Overwrite the default serialEvent handler to do something
 * a little bit more interesting, namely, grab some numbers.
 */
void serialEvent(Serial myPort) {
    // declare a variable to  store our sensor value
    int val;
    // lets read in our data
    String inString = trim(myPort.readStringUntil('\n'));
     
    println("Sensor value: " + inString); 
    // It needs to be sanitized
    if(isNumeric(inString)) {
      val = Integer.parseInt(trim(inString));
      snw.setFreq(val * 10);
    }
}

void keyPressed() {
  if ( key == 'm' ) {
    if ( au_out.isMuted() ) {
      au_out.unmute();
    } else {
      au_out.mute();
    }
  }
}
