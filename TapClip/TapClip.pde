import ddf.minim.*;
import processing.serial.*;
import javax.swing.JFileChooser;


final boolean DEBUG = true;

// Final vars
final int NUM_CLIPS = 3;
final int THRESHOLD = 500;

final byte PRESS = (byte) 0x33;
final byte VALUE = (byte) 0xCC;
final byte END = (byte) 0xFF;

String[] serialPorts; // list of serial ports


long lastSerial = 0;
long TIMEOUT_SERIAL = 1000;

int lastCheck = 0;

Minim m;

// Keep track of exciting things
ArrayList <PaperClip> pages = new ArrayList();
TapSample[] s = new TapSample[NUM_CLIPS];
Serial myPort; 

int sample_number;
int screen_x, screen_y;     

// Global Triggers
boolean recording = false;
boolean useSerial = true;
boolean pressed = false;
boolean serial = true;
boolean saveFile = false;
boolean openFile = false;

PaperClip paperClip;

// Serial globals
byte read_val;
byte[] byteArray = new byte[10];

void setup() {

  frame.setTitle("TapClip v.1");

  int i = 0;
  
  screen_x = 1280;
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
    
    serialPorts = Serial.list();
    println(serialPorts);
    String portName = serialPorts[0];
    
    try {
    
       myPort = new Serial(this, portName, 9600);   
       myPort.bufferUntil(END);
       
    } catch(Exception e) {
      
       println(e); 
       println("Running without serial input.");
       
    }
  }
}



color[] colors = {random_color(), random_color(), random_color(), random_color(), random_color()};

void draw() {
    
    int eH = 75;
    int eW = 75;

    background(102);
    
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
         fill(255);
    
    
       } else {
         fill(colors[i-1]);
       }

       if(c.hasSample()){
         ellipse( i * (width/(paperClip.numClips() + 1)), (height/2), eH, eW);
       } else if(!c.isPressed) {
          fill(0);
          ellipse( i * (width/(paperClip.numClips() + 1)), (height/2), 25, 25);

       } else {
          ellipse( i * (width/(paperClip.numClips() + 1)), (height/2), 25, 25);
       }

       i++;
       
    }
    
    saveFile();
    openFile();
    //serialOpen();

}

void serialOpen() {
  if(Serial.list()[0] != serialPorts[0] && Serial.list().length == serialPorts.length) {
    println("new serial!");
    myPort.clear();
    myPort.stop();
    myPort = new Serial(this, Serial.list()[0], 9600);   
    myPort.bufferUntil(END);
  }  
}
  
void keyReleased() {   
  String filepath = "";
  String [] filenames = new String[paperClip.numClips()];
  if(key == ENTER) {
    return;
  }
  if(key == 's') {
     saveFile = true;
    
  }
  if(key == 'o') {
    openFile = true;
   
  }
   
 /* if(key=='o') {   
     JFileChooser chooser = new JFileChooser();
     File dataDir = new File(sketchPath, "sounds");
     if (!dataDir.exists()) {
        dataDir.mkdirs();
     }
     chooser.setSelectedFile(dataDir); 

     chooser.setFileFilter(chooser.getAcceptAllFileFilter());
      int returnVal = chooser.showOpenDialog(null);
      if (returnVal == JFileChooser.APPROVE_OPTION) {
        println("You chose to open this file: " + chooser.getSelectedFile().getName());
      }
      try {
      File file = chooser.getSelectedFile();
      } catch(Exception e) {
        println("Failed to open this file.");
      }
  }*/
 
/*    if(recording) {
      
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
  }*/
}


void openFile() {
  
  if(openFile) {
     String filepath = "";
    String [] filenames = new String[paperClip.numClips()];
    openFile = false;
     filepath = selectInput(); 
    if(filepath  == null) {
      println("No input file was selected...");
    } else {
      println("Opening file " + filepath);
      filenames = loadStrings(filepath);
      println(filenames);
      paperClip = new PaperClip(m, filenames);
    }
  }  
}

void saveFile() {
  
  if(saveFile) {
    
    saveFile = false;
    String filepath = "";
    String [] filenames = new String[paperClip.numClips()];
    filepath = selectOutput();
  
    if (filepath == null) {
      println("No output file was selected...");
    } else {
      println("Saving to " + filepath);
      Iterator <Clip> clips = paperClip.getClipsIter();
      int i = 0;  
      while(clips.hasNext()) {
         Clip c = clips.next(); 
         if(c.hasSample()) {
             filenames[i] = c.getFilename();
         } else {
           filenames[i] = "none";
         }
         i++;
      }
      saveStrings(filepath, filenames);
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
  return color(random(100), random(255), random(255));
}

void serialEvent(Serial p) {
  byte[] inBuffer = new byte[12];
  int num = p.readBytes(inBuffer);
  if(num == 7 && inBuffer[6] == END) { 
      paperClip.update(inBuffer);
  }
}


