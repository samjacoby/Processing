import ddf.minim.*;

Minim m;

SoundClip[] s = new SoundClip[6];

int sample_number;
int screen_x, screen_y;     

Boolean recording = false;
Box myBox;

void setup() {
  
  screen_x = 400;
  screen_y = 400;
  
  size(screen_x, screen_y);
  
  m = new Minim(this);  
  
  sample_number = 0;  
  s[sample_number] = new SoundClip(m);
}

void draw() {
      
}

void keyReleased()
{ 
  
  
  if(key==' ') {    
   
    if(recording) {
      
       println("stop recording");
      
       color c = color(random(255),random(255),random(255));
       myBox.f_color = c;
       myBox.drawBox(30,30);
            
       s[sample_number].endRecording();
      
       sample_number = (sample_number + 1) % 6;
       recording = false;
      
    } else {
      
      println("start recording");
      s[sample_number] = new SoundClip(m);    

      myBox = new Box(random(screen_x), random(screen_y));
      myBox.drawBox(30,30);
       
      s[sample_number].record(); 
      recording = true;
    }
  } else {
  
  int val = (int) key;
  println("playing " + val);
  val = val % 6;
  println(val);
  if(val < 0 | val > 5) {
    println("FAIL");
  }
  println("playing " + val);
  try {
    s[val].clip.trigger();
  }  catch(NullPointerException e) {
    println("uh oh");
  }  
}
}

void stop()
{
  // always close Minim audio classes when you are done with them
  m.stop();
  
  super.stop();
}


