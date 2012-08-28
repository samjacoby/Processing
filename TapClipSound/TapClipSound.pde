import ddf.minim.*;
import processing.serial.*;

final int NUM_CLIPS = 3;
final int THRESHOLD = 500;
final boolean SERIAL = false;
final boolean DEBUG = true;



Minim m;

ArrayList <Box> boxes = new ArrayList();
TapSample[] s = new SoundClip[NUM_CLIPS];
Serial myPort; 

int sample_number;
int screen_x, screen_y;     

// Global Triggers
Boolean recording = false;
Boolean ready = false;
Boolean useSerial = true;
Boolean pressed = false;

Box myBox;

// Serial globals
byte read_val;
byte[] byteArray = new byte[10];

void setup() {
  
  screen_x = 400;
  screen_y = 400;
  
  size(screen_x, screen_y);
  
  m = new Minim(this);  
  
  sample_number = 0;  
  s[sample_number] = new TapSample(m);
  
  if(SERIAL) {
    println(Serial.list());
    String portName = Serial.list()[0];
    try {
    myPort = new Serial(this, portName, 9600);   
    } catch(Exception e) {
       println(e); 
       println("Running without serial input.");
       useSerial = false;
    }
  }
}

byte[] inBuffer = new byte[32];
int[] capVal = null;

void draw() {
    Box b;
    int numRead = 0;
    
    background(204, 128, 56);
    
    if(SERIAL) {
      numRead = serialRead(inBuffer);
      
      if (numRead > 0) {
        String myString = new String(inBuffer);
        capVal = int(split(trim(myString), ',')); 
      }    
      
      if(ready) {
        checkTouch(capVal); 
        }
      }
    
    
    for(int i=0; i < boxes.size(); i++) {
      
      b = boxes.get(i);
      if(b.mouseIsOver() && mousePressed) {
        b.f_color = color(random(255), random(255), random(255));
        b.sample.play();
      }
      
      b.drawBox();
    }


}

void checkTouch(int[] capVal) {
      println(capVal);
      for(int i = 0; i < capVal.length; i++) {
        if(capVal[i] > THRESHOLD) {
          s[i].clip.trigger();
        } 
      }
}

int serialRead(byte[] inBuffer) {
  int numRead = 0;
  if ( myPort.available() > 0) {  // If data is available,

    byte lf='\n';
    numRead = myPort.readBytesUntil(lf, inBuffer);
  }
  return numRead;
}



void keyReleased()
{ 
  
  
  if(key==' ') {   
   
    if(sample_number == (NUM_CLIPS - 1)) {
       ready = true;
    } 
   
    if(recording) {
      
       println("stop recording");
      
       color c = color(random(255),random(255),random(255));
       myBox.f_color = c;
       myBox.drawBox(30,30);
            
       s[sample_number].endRecording();
      
       sample_number = (sample_number + 1) % NUM_CLIPS;
       recording = false;
      
    } else {
      
      println("start recording");

      s[sample_number] = new TapSample(m);    

      myBox = new Box(int(random(screen_x)), int(random(screen_y)));
      boxes.add(myBox);
      myBox.drawBox(30,30);
       
      s[sample_number].record(); 
      recording = true;
    }
  } else {
  
  int val = (int) key;
  println("playing " + val);
  val = val % NUM_CLIPS;
  println(val);
  
  assert(val >= 0 | val < NUM_CLIPS);
  
  println("playing " + val);
  try {
    s[val].clip.trigger();
  }  catch(NullPointerException e) {
    println("uh oh");
  }  
}
}

void mousePressed() {
  pressed = !pressed; 
}

void stop()
{
  m.stop();
  super.stop();
}


