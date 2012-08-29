import ddf.minim.*;
import processing.serial.*;

// Final vars
final int NUM_CLIPS = 3;
final int THRESHOLD = 500;
final boolean DEBUG = true;

Minim m;

// Keep track of exciting things
ArrayList <Box> boxes = new ArrayList();
TapSample[] s = new TapSample[NUM_CLIPS];
Serial myPort; 

int sample_number;
int screen_x, screen_y;     

// Global Triggers
Boolean recording = false;
Boolean ready = false;
Boolean useSerial = true;
Boolean pressed = false;
boolean serial = true;


Box myBox;

// Serial globals
byte read_val;
byte[] byteArray = new byte[10];

void setup() {
  
  int i = 0;
  
  screen_x = 400;
  screen_y = 400;
  
  size(screen_x, screen_y);
  
  m = new Minim(this);  
  
  sample_number = 0;  
  s[sample_number] = new TapSample(m);
  
  
  // Initialize PaperClip
  PaperClip paperClip = new PaperClip();

  // Are we working with serial or not?  
  if(serial) {
    
    println(Serial.list());
    String portName = Serial.list()[0];
    
    try {
    
       myPort = new Serial(this, portName, 9600);   
    
    } catch(Exception e) {
      
       println(e); 
       println("Running without serial input.");
       
    }
  }
}

byte[] inBuffer = new byte[1];
int[] capVal = null;

void draw() {
    
    Box b;
    byte inByte = 0;
    
    background(173, 238, 238);
    
    if(serial) {
  
      inByte = (byte) serialRead();
      
      if(ready && (inByte != -1)) {
        checkTouch(inByte); 
        }
      }
    
    
    for(int i=0; i < boxes.size(); i++) {
      
      b = boxes.get(i);
    
      if(b.mouseIsOver() && mousePressed) {
        
        b.f_color = random_color();
        b.trigger();
        
      }
      
      b.drawBox();
    }


}

color random_color() {
  return color(random(255), random(255), random(255));
}

void checkTouch(byte capVal) {
    if((capVal & 1) != 0) {
      s[0].clip.trigger();

    } 
  
    if((capVal & 2) != 0 ) {
        s[1].clip.trigger();
      
    }
    if((capVal & 4) != 0) {
      
      s[2].clip.trigger();
    }
    
    
}

int serialRead() {
  
  int inByte = -1;
  if ( myPort.available() > 0) {  // If data is available,

    inByte = myPort.read();
 
  }
  
  return inByte;
}



void keyReleased()
{ 
  
  
  if(key==' ') {   
   
   
   
    if(recording) {
      
       println("stop recording");
      
       color c = color(random(255),random(255),random(255));
       myBox.f_color = c;
       myBox.drawBox(30, 30);
            
       s[sample_number].endRecording();
       myBox.setSample(s[sample_number]);
        if(sample_number == (NUM_CLIPS - 1)) {
      
       ready = true;
      } 
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
    } catch(NullPointerException e) {
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


