class PaperClip {
  
  final int NUM_CLIPS = 3;
  ArrayList <Clip> clips = new ArrayList();
  
  PaperClip() {
    
    for(int i=0; i < NUM_CLIPS; i++) {
      clips.add(new Clip());
    }  
  
  }
  
}



class Clip {
  
    Box soundBox;
    int touchThreshold;
    
    Clip() {
      
    }
    
    Clip(Box b) {
      this.soundBox = b;
    }
    
    Box getBox() {
      return soundBox;
    }
    
    void setBox(Box b) {
      this.soundBox = b;  
    }
    
    void isPressed() {
        
    }
}
