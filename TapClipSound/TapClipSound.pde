import ddf.minim.*;
import processing.serial.*;

final boolean DEBUG = true;

// Final vars
final int NUM_CLIPS = 3;
final int THRESHOLD = 500;

final byte PRESS = (byte) 0x33;
final byte VALUE = (byte) 0xCC;
final byte END = (byte) 0xFF;


int lastCheck = 0;

Minim m;

// Keep track of exciting things
ArrayList <SoundBox> boxes = new ArrayList();
TapSample[] s = new TapSample[NUM_CLIPS];
Serial myPort; 

int sample_number;
int screen_x, screen_y;     

// Global Triggers
boolean recording = false;
boolean useSerial = true;
boolean pressed = false;
boolean serial = true;


SoundBox myBox;
PaperClip paperClip;

// Serial globals
byte read_val;
byte[] byteArray = new byte[10];

void setup() {
  
  int i = 0;
  
  screen_x = 800;
  screen_y = 800;
  
  size(screen_x, screen_y);
  //size(displayWidth, displayHeight);
  
  background(102);


  m = new Minim(this);  
  
  sample_number = 0;  
  s[sample_number] = new TapSample(m);
  
  // Initialize PaperClip
  paperClip = new PaperClip(m);

  // Are we working with serial or not?  
  if(serial) {
    
    println(Serial.list());
    String portName = Serial.list()[0];
    
    try {
    
       myPort = new Serial(this, portName, 9600);   
       myPort.bufferUntil(END);
       
    } catch(Exception e) {
      
       println(e); 
       println("Running without serial input.");
       
    }
  }
}

int eH = 50;
int eW = 50;

void draw() {
    
    SoundBox b;
    Clip c;
    byte inByte = 0;
    
    Iterator <Clip> clips = paperClip.getClipsIter();
    
    int i = 1;
    while(clips.hasNext()) {
       c = clips.next(); 
       if(c.isRecording) {
                  fill(209, 25, 25);
       } else if(c.isPressed) {
          fill(255,255,255);
       } else if(c.isPlaying()){
         fill(159, 179, 207);
       } else {
         fill(0,0,0);
       }
       ellipse( i * (width/(paperClip.numClips() + 1)), (height/2), eH, eW);
       i++;
    }
    

}

void keyReleased() { 
  
  if(key==' ') {   
   
    if(recording) {
      
       println("stop recording");
      
       color c = color(random(255),random(255),random(255));
       myBox.f_color = c;
       myBox.drawBox(30, 30);
            
       s[sample_number].endRecording();
       myBox.setSample(s[sample_number]);

       sample_number = (sample_number + 1) % NUM_CLIPS;
       recording = false;
      
    } else {
      
        println("start recording");
  
        s[sample_number] = new TapSample(m);    
  
        myBox = new SoundBox(int(random(screen_x)), int(random(screen_y)));

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

void stop() {
  m.stop();
  super.stop();
}

/*
 *  Utiiities
 *
 */
 
 
color random_color() {
  return color(random(255), random(255), random(255));
}

void serialEvent(Serial p) {
  byte[] inBuffer = new byte[10];
  int num = p.readBytes(inBuffer);
  if(num == 7 && inBuffer[6] == END) { 
      paperClip.update(inBuffer);
  }
}


