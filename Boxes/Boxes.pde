import ddf.minim.*;

Minim m;
SoundClip[] s = new SoundClip[6];
int sample_number;

void setup() {
  
  size(400, 400);
  
  m = new Minim(this);  
  
  sample_number = 0;
  s[0] = new SoundClip(m);
  
}

void draw() {
      
}

void keyReleased()
{ 
  if(key==' ') {    
  if(s[sample_number].isRecording()) {
    
    println("stop recording");
    fill(255,100,100);
   
    Box myBox = new Box(200, 200);
    myBox.drawBox(200,200);  
    
    s[sample_number].endRecording();
    sample_number = (sample_number + 1) % 6;
    s[sample_number] = new SoundClip(m);
    
  } else {
    
    println("start recording");
    
     fill(100,100,100);
     Box myBox = new Box(200, 200);
     myBox.drawBox(200,200);
     
     s[sample_number].record(); 
  }
  } else {
  
  int val = (int) key;
  println("playing " + val);
  val = val % 6;
  println(val);
  s[val].clip.play(0);
  }
}

void stop()
{
  // always close Minim audio classes when you are done with them
  m.stop();
  
  super.stop();
}

/*
 *
 * Sound Box
 *
 * This represents a box of some kind.
 */

class Box {

    float x, y;
    
    Box(float x, float y) {
      this.x = x;
      this.y = y;
    }

    public void drawBox(float width, float height) {
        rectMode(CENTER); 
        rect(this.x, this.y, width, height);
    }
}

